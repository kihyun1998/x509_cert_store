import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../backend.dart';
import '../x509_res_result.dart';
import '../x509_store_enums.dart'
    show X509AddType, X509ErrorCode, X509StoreName;
import 'crypt32.dart';

/// Windows backend: adds the certificate through wincrypt over FFI.
///
/// `setTrusted` is ignored, as it was in the C++ implementation - certificates
/// in the ROOT store are trusted by the system by definition.
class WindowsCertStore implements X509CertStoreBackend {
  @override
  Future<X509Result> addCertificate({
    required X509StoreName storeName,
    required Uint8List der,
    required X509AddType addType,
    required bool setTrusted,
  }) {
    final name = storeName.getString();
    final disposition = addType.getCode();

    // Adding to ROOT raises a modal system confirmation dialog, and the FFI
    // call blocks until it is dismissed. Running it on a worker isolate keeps
    // that off the caller's isolate; dismissing the dialog surfaces as
    // ERROR_CANCELLED.
    return Isolate.run(() => _addCertificateSync(name, der, disposition));
  }
}

/// The whole wincrypt sequence, synchronous, with every allocation and handle
/// released on all paths.
X509Result _addCertificateSync(String storeName, Uint8List der, int addType) {
  // An empty certificate would index past the end of the buffer below; the
  // caller already rejects empty input, so this is defence in depth.
  if (der.isEmpty) {
    return const X509Failure(
      code: X509ErrorCode.invalidFormat,
      msg: 'Certificate data is empty',
    );
  }

  final storeNamePtr = storeName.toNativeUtf8();
  final certBuffer = calloc<Uint8>(der.length);
  Pointer<Void> store = nullptr;
  Pointer<Void> certContext = nullptr;

  try {
    certBuffer.asTypedList(der.length).setAll(0, der);

    store = certOpenSystemStoreA(nullptr, storeNamePtr);
    if (store == nullptr) {
      final error = getLastError();
      return _failure('Failed to open certificate store', error);
    }

    certContext =
        certCreateCertificateContext(certEncodingTypes, certBuffer, der.length);
    if (certContext == nullptr) {
      final error = getLastError();
      return _failure('Failed to create certificate context', error);
    }

    final added = certAddCertificateContextToStore(
      store,
      certContext,
      addType,
      nullptr,
    );
    if (added == 0) {
      final error = getLastError();
      return _failure('Failed to add certificate to store', error);
    }

    return const X509Success();
  } finally {
    if (certContext != nullptr) certFreeCertificateContext(certContext);
    if (store != nullptr) certCloseStore(store, 0);
    calloc.free(certBuffer);
    calloc.free(storeNamePtr);
  }
}

/// Builds a failure from a raw Win32 error.
///
/// `nativeCode` is populated only for the `unknown` category: a caller that
/// matched a category already has the portable answer, and the raw value is
/// only useful for diagnosing codes this mapping does not cover.
X509Failure _failure(String message, int winError) {
  final category = _categoryFromWinError(winError);
  return X509Failure(
    code: category,
    msg: '$message (Win32 error $winError)',
    nativeCode: category == X509ErrorCode.unknown ? winError : null,
  );
}

X509ErrorCode _categoryFromWinError(int code) {
  switch (code) {
    case cryptEExists:
      return X509ErrorCode.alreadyExist;
    case errorCancelled:
      return X509ErrorCode.canceled;
    case errorAccessDenied:
      return X509ErrorCode.accessDenied;
    default:
      return X509ErrorCode.unknown;
  }
}
