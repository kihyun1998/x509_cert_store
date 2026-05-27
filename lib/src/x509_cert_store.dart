import 'x509_cert_store_platform_interface.dart';
import 'x509_res_result.dart';
import 'x509_store_enums.dart' show X509AddType, X509StoreName;

/// A Flutter plugin for managing X.509 certificates in platform certificate
/// stores.
///
/// Provides a cross-platform API for adding X.509 certificates to the
/// operating system's certificate stores on Windows (wincrypt) and macOS
/// (Keychain Services).
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
  }) {
    return X509CertStorePlatform.instance.addCertificate(
      storeName: storeName,
      certificateBase64: certificateBase64,
      addType: addType,
      setTrusted: setTrusted,
    );
  }
}
