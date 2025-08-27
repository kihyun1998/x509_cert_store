/// A Flutter plugin for managing X.509 certificates in platform certificate stores.
///
/// This plugin provides a cross-platform API for adding X.509 certificates
/// to the operating system's certificate stores with support for different
/// certificate stores and addition behaviors.
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
/// if (result.isOk) {
///   print('Certificate added successfully');
/// } else {
///   print('Error: ${result.msg}');
/// }
/// ```
///
/// ## Supported Platforms
///
/// - macOS (Keychain integration)
/// - Windows (planned)
/// - Linux (planned)
library x509_cert_store;

// Export all public APIs
export 'src/x509_cert_store.dart';
export 'src/x509_res_result.dart';
export 'src/x509_store_enums.dart';
