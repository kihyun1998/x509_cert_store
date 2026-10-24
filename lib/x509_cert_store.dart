/// A Dart package for adding X.509 certificates to platform certificate stores.
///
/// It reaches the Windows and macOS stores over `dart:ffi`, with no Flutter
/// dependency, and provides a cross-platform API for adding X.509 certificates
/// with support for different certificate stores and addition behaviors.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:x509_cert_store/x509_cert_store.dart';
///
/// final certStore = X509CertStore();
///
/// final result = await certStore.addCertificate(
///   storeName: X509StoreName.my,
///   certificateBase64: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMI...',
///   addType: X509AddType.addNew,
/// );
///
/// switch (result) {
///   case X509Success():
///     print('Certificate added successfully');
///   case X509Failure(code: X509ErrorCode.alreadyExist):
///     print('Already exists');
///   case X509Failure(:final msg):
///     print('Error: $msg');
/// }
/// ```
///
/// ## Supported Platforms
///
/// - Windows (wincrypt certificate store)
/// - macOS (Keychain Services)
library;

// Export all public APIs
export 'src/x509_cert_store.dart';
export 'src/x509_res_result.dart';
export 'src/x509_store_enums.dart';
