import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'backend.dart';
import 'pem.dart';
import 'x509_res_result.dart';
import 'x509_store_enums.dart' show X509AddType, X509ErrorCode, X509StoreName;

/// A Dart package for managing X.509 certificates in platform certificate
/// stores.
///
/// Provides a cross-platform API for adding X.509 certificates to the
/// operating system's certificate stores on Windows (wincrypt) and macOS
/// (Keychain Services). Both are reached through `dart:ffi`, so the package
/// ships no compiled native code.
///
/// ## Usage
///
/// ```dart
/// final certStore = X509CertStore();
///
/// final result = await certStore.addCertificate(
///   storeName: X509StoreName.my,
///   certificateBase64: 'MIIBIj...',
///   addType: X509AddType.addNew,
/// );
///
/// switch (result) {
///   case X509Success():
///     print('Certificate added');
///   case X509Failure(code: X509ErrorCode.alreadyExist):
///     print('Already exists');
///   case X509Failure(code: X509ErrorCode.canceled):
///     print('User canceled');
///   case X509Failure(code: X509ErrorCode.accessDenied):
///     print('Admin privileges required');
///   case X509Failure(code: X509ErrorCode.invalidFormat):
///     print('Invalid certificate format');
///   case X509Failure(code: X509ErrorCode.unknown, nativeCode: var n):
///     print('Unmapped failure (native: $n)');
/// }
/// ```
class X509CertStore {
  /// Creates a store bound to the host platform's backend.
  X509CertStore() : _backend = createPlatformBackend();

  /// Creates a store bound to [backend].
  ///
  /// FFI bindings cannot be mocked the way the previous method channel could,
  /// so tests substitute a backend here instead.
  @visibleForTesting
  X509CertStore.withBackend(X509CertStoreBackend backend) : _backend = backend;

  final X509CertStoreBackend _backend;

  /// Adds a certificate to the specified certificate store.
  ///
  /// Returns an [X509Result] — pattern-match on the result to handle
  /// success and failure cases.
  ///
  /// Parameters:
  /// - [storeName]: The target certificate store
  /// - [certificateBase64]: The certificate as base64-encoded DER or PEM
  /// - [addType]: How to handle certificates with the same identity
  /// - [setTrusted]: Whether to configure as trusted
  ///   (macOS only; ignored on Windows)
  Future<X509Result> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
    bool setTrusted = false,
  }) async {
    // Decoding and PEM normalization happen above the platform seam, so the
    // two invalid-input paths below behave identically on every platform and
    // are unit-testable without touching the certificate store.
    final Uint8List decoded;
    try {
      decoded = base64.decode(certificateBase64);
    } on FormatException catch (error) {
      return X509Failure(
        code: X509ErrorCode.invalidFormat,
        msg: 'Invalid base64 certificate data: ${error.message}',
      );
    }

    if (decoded.isEmpty) {
      return const X509Failure(
        code: X509ErrorCode.invalidFormat,
        msg: 'Certificate data is empty',
      );
    }

    final der = Pem.normalizeToDer(decoded);
    if (der == null) {
      return const X509Failure(
        code: X509ErrorCode.invalidFormat,
        msg: 'Failed to convert PEM to DER format',
      );
    }

    try {
      return await _backend.addCertificate(
        storeName: storeName,
        der: der,
        addType: addType,
        setTrusted: setTrusted,
      );
    } catch (error) {
      // A failed FFI symbol lookup or a missing platform library surfaces as
      // an exception. Keep the sealed result total rather than letting it
      // escape to the caller.
      return X509Failure(
        code: X509ErrorCode.unknown,
        msg: 'An unexpected error occurred: $error',
      );
    }
  }
}
