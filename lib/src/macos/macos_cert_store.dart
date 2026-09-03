import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../asn1/certificate_fields.dart';
import '../backend.dart';
import '../x509_res_result.dart';
import '../x509_store_enums.dart'
    show X509AddType, X509ErrorCode, X509StoreName;
import 'core_foundation.dart';
import 'security.dart';
import 'trust.dart';

/// macOS backend: adds the certificate to the keychain through the Security
/// framework over FFI, then optionally configures trust.
///
/// Note on `storeName`: as in the Swift implementation, the keychain query
/// carries no `kSecUseKeychain`, so both `root` and `my` add to the user's
/// default keychain. The store name selects only the trust mechanism -
/// elevated (system keychain) versus unelevated. This preserves the existing
/// behaviour rather than changing it as part of the FFI migration.
class MacOsCertStore implements X509CertStoreBackend {
  @override
  Future<X509Result> addCertificate({
    required X509StoreName storeName,
    required Uint8List der,
    required X509AddType addType,
    required bool setTrusted,
  }) async {
    final disposition = addType.getCode();

    // Adding to the keychain can raise an authorization prompt and blocks
    // until it is answered, so it runs off the caller's isolate. The trust
    // step stays here because it is already async (Process), not blocking.
    final result =
        await Isolate.run(() => _addCertificateSync(der, disposition));

    if (result is X509Success && setTrusted) {
      await applyTrust(der, storeName);
    }
    return result;
  }
}

/// The whole Security framework sequence, synchronous, with every CF object
/// released on all paths.
X509Result _addCertificateSync(Uint8List der, int addType) {
  final fields = CertificateFields.parse(der);
  if (fields == null) {
    return const X509Failure(
      code: X509ErrorCode.invalidFormat,
      msg: 'Invalid certificate data',
    );
  }

  final certificate = _createCertificate(der);
  if (certificate == nullptr) {
    return const X509Failure(
      code: X509ErrorCode.invalidFormat,
      msg: 'Invalid certificate data',
    );
  }

  try {
    // Resolve the add disposition against what is already in the keychain.
    // `existing` is retained, so it stays valid after the CFArray it came
    // from is released.
    final existing = _findByIdentity(fields);
    if (existing != nullptr) {
      try {
        switch (addType) {
          case _certStoreAddNew:
            return const X509Failure(
              code: X509ErrorCode.alreadyExist,
              msg: 'Certificate already exists',
            );
          case _certStoreAddNewer:
            final existingFields = _fieldsOf(existing);
            // An unreadable or not-older incumbent means there is nothing to
            // do; the operation succeeds without touching the keychain.
            if (existingFields == null ||
                !fields.notBefore.isAfter(existingFields.notBefore)) {
              return const X509Success();
            }
            final newerDeleteStatus = _deleteCertificate(existing);
            if (newerDeleteStatus != errSecSuccess) {
              return _failure(newerDeleteStatus);
            }
          case _certStoreAddReplaceExisting:
            final replaceDeleteStatus = _deleteCertificate(existing);
            if (replaceDeleteStatus != errSecSuccess) {
              return _failure(replaceDeleteStatus);
            }
        }
      } finally {
        cfRelease(existing);
      }
    }

    final status = _addCertificate(certificate);
    if (status == errSecSuccess) return const X509Success();
    if (status == errSecDuplicateItem) {
      return const X509Failure(
        code: X509ErrorCode.alreadyExist,
        msg: 'Certificate already exists',
      );
    }
    return _failure(status);
  } finally {
    cfRelease(certificate);
  }
}

/// `CERT_STORE_ADD_*` dispositions, shared with Windows through
/// [X509AddType.getCode].
const int _certStoreAddNew = 1;
const int _certStoreAddReplaceExisting = 3;
const int _certStoreAddNewer = 6;

/// Builds a `SecCertificateRef` from DER, or `nullptr` when the data is not a
/// certificate the Security framework accepts.
Pointer<Void> _createCertificate(Uint8List der) {
  final data = _createData(der);
  if (data == nullptr) return nullptr;
  try {
    return secCertificateCreateWithData(nullptr, data);
  } finally {
    cfRelease(data);
  }
}

/// Searches every certificate in the keychain for one with the same
/// (issuer, serialNumber) identity as [target].
///
/// Returns a retained reference the caller must release, or `nullptr`.
Pointer<Void> _findByIdentity(CertificateFields target) {
  final query = _createDictionary(
    [kSecClass, kSecMatchLimit, kSecReturnRef],
    [kSecClassCertificate, kSecMatchLimitAll, kCFBooleanTrue],
  );
  if (query == nullptr) return nullptr;

  final resultPtr = calloc<Pointer<Void>>();
  try {
    final status = secItemCopyMatching(query, resultPtr);
    if (status != errSecSuccess) return nullptr;

    final array = resultPtr.value;
    if (array == nullptr) return nullptr;
    try {
      final count = cfArrayGetCount(array);
      for (var i = 0; i < count; i++) {
        final candidate = cfArrayGetValueAtIndex(array, i);
        if (candidate == nullptr) continue;
        final candidateFields = _fieldsOf(candidate);
        if (candidateFields == null) continue;
        if (candidateFields.hasSameIdentityAs(target)) {
          // Array elements are owned by the array, so retain before it goes.
          return cfRetain(candidate);
        }
      }
      return nullptr;
    } finally {
      cfRelease(array);
    }
  } finally {
    calloc.free(resultPtr);
    cfRelease(query);
  }
}

/// Reads a keychain certificate's DER back out and parses its identity
/// fields. Returns null for a certificate that will not re-encode or parse.
CertificateFields? _fieldsOf(Pointer<Void> certificate) {
  final data = secCertificateCopyData(certificate);
  if (data == nullptr) return null;
  try {
    final length = cfDataGetLength(data);
    final bytes = cfDataGetBytePtr(data);
    if (length <= 0 || bytes == nullptr) return null;
    // Copy out of CF-owned storage before the CFData is released.
    return CertificateFields.parse(
      Uint8List.fromList(bytes.asTypedList(length)),
    );
  } finally {
    cfRelease(data);
  }
}

int _addCertificate(Pointer<Void> certificate) {
  final query = _createDictionary(
    [kSecClass, kSecValueRef, kSecAttrAccessible],
    [kSecClassCertificate, certificate, kSecAttrAccessibleAfterFirstUnlock],
  );
  if (query == nullptr) return errSecDecode;
  try {
    return secItemAdd(query, nullptr);
  } finally {
    cfRelease(query);
  }
}

int _deleteCertificate(Pointer<Void> certificate) {
  final query = _createDictionary(
    [kSecClass, kSecValueRef],
    [kSecClassCertificate, certificate],
  );
  if (query == nullptr) return errSecDecode;
  try {
    return secItemDelete(query);
  } finally {
    cfRelease(query);
  }
}

/// Copies [bytes] into a `CFDataRef`. CFDataCreate copies the buffer, so the
/// native allocation is freed before returning.
Pointer<Void> _createData(Uint8List bytes) {
  final buffer = calloc<Uint8>(bytes.length);
  try {
    buffer.asTypedList(bytes.length).setAll(0, bytes);
    return cfDataCreate(nullptr, buffer, bytes.length);
  } finally {
    calloc.free(buffer);
  }
}

/// Builds a `CFDictionaryRef` with CFType key and value callbacks, so the
/// dictionary retains its entries for its own lifetime.
Pointer<Void> _createDictionary(
  List<Pointer<Void>> keys,
  List<Pointer<Void>> values,
) {
  assert(keys.length == values.length);
  final count = keys.length;
  final keysArray = calloc<Pointer<Void>>(count);
  final valuesArray = calloc<Pointer<Void>>(count);
  try {
    for (var i = 0; i < count; i++) {
      keysArray[i] = keys[i];
      valuesArray[i] = values[i];
    }
    return cfDictionaryCreate(
      nullptr,
      keysArray,
      valuesArray,
      count,
      kCFTypeDictionaryKeyCallBacks,
      kCFTypeDictionaryValueCallBacks,
    );
  } finally {
    calloc.free(keysArray);
    calloc.free(valuesArray);
  }
}

/// Builds a failure from an `OSStatus`, preserving the raw value only for the
/// `unknown` category - a matched category already gives the caller the
/// portable answer.
X509Failure _failure(int status) {
  final category = _categoryFromOSStatus(status);
  return X509Failure(
    code: category,
    msg: 'Security framework error: $status',
    nativeCode: category == X509ErrorCode.unknown ? status : null,
  );
}

X509ErrorCode _categoryFromOSStatus(int status) {
  switch (status) {
    case errSecDuplicateItem:
      return X509ErrorCode.alreadyExist;
    case errSecUserCanceled:
      return X509ErrorCode.canceled;
    case errSecAuthFailed:
      return X509ErrorCode.accessDenied;
    case errSecDecode:
      return X509ErrorCode.invalidFormat;
    default:
      return X509ErrorCode.unknown;
  }
}
