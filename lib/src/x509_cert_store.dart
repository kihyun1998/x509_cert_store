import 'x509_cert_store_platform_interface.dart';
import 'x509_res_result.dart';
import 'x509_store_enums.dart' show X509AddType, X509StoreName;

/// A Flutter plugin for managing X.509 certificates in platform certificate stores.
///
/// This plugin provides a cross-platform API for adding X.509 certificates
/// to the operating system's certificate stores. It supports different certificate
/// stores (root, personal) and various addition behaviors (add new, replace existing).
///
/// ## Supported Platforms
///
/// - **macOS**: Uses Keychain Services and the `security` command-line tool
/// - **Windows**: Uses Windows Certificate Store APIs (planned)
/// - **Linux**: Uses system certificate stores (planned)
///
/// ## Certificate Stores
///
/// Different platforms organize certificates into various stores:
///
/// - **Root Store**: Contains trusted root certificate authorities
/// - **Personal Store (My)**: Contains user certificates and client authentication certificates
///
/// ## Usage Example
///
/// ```dart
/// import 'package:x509_cert_store/x509_cert_store.dart';
///
/// final certStore = X509CertStore();
///
/// // Add a certificate to the personal store (without trust settings)
/// final result = await certStore.addCertificate(
///   storeName: X509StoreName.my,
///   certificateBase64: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMI...',
///   addType: X509AddType.addNew,
/// );
///
/// // Add a trusted certificate to the root store
/// final trustedResult = await certStore.addCertificate(
///   storeName: X509StoreName.root,
///   certificateBase64: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMI...',
///   addType: X509AddType.addNew,
///   setTrusted: true,
/// );
///
/// if (result.isOk) {
///   print('Certificate added successfully');
/// } else if (result.hasError(X509ErrorCode.alreadyExist)) {
///   print('Certificate already exists in the store');
/// } else {
///   print('Error: ${result.msg}');
/// }
/// ```
class X509CertStore {
  /// Adds a certificate to the specified certificate store.
  ///
  /// This method attempts to add an X.509 certificate to the platform's
  /// certificate management system. The certificate must be provided as
  /// base64-encoded DER or PEM data.
  ///
  /// Parameters:
  /// - [storeName]: The target certificate store where the certificate should be added
  /// - [certificateBase64]: The certificate data encoded as base64 string
  /// - [addType]: Controls the behavior when a certificate with the same identity already exists
  /// - [setTrusted]: Whether to set the certificate as trusted (default: false)
  ///
  /// Returns a [Future] that resolves to an [X509ResValue] containing:
  /// - Success status ([X509ResValue.isOk])
  /// - Human-readable message ([X509ResValue.msg])
  /// - Machine-readable error code ([X509ResValue.code])
  ///
  /// ## Certificate Data Format
  ///
  /// The [certificateBase64] parameter should contain the certificate data
  /// encoded as a base64 string. Both DER and PEM formats are supported:
  ///
  /// ```dart
  /// // PEM format (with headers)
  /// final pemCert = '''
  /// -----BEGIN CERTIFICATE-----
  /// MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
  /// -----END CERTIFICATE-----
  /// ''';
  /// final base64Data = base64.encode(utf8.encode(pemCert));
  ///
  /// // DER format (binary data)
  /// final derBytes = await File('certificate.der').readAsBytes();
  /// final base64Data = base64.encode(derBytes);
  /// ```
  ///
  /// ## Error Handling
  ///
  /// The method returns detailed error information that can be used for
  /// programmatic error handling:
  ///
  /// ```dart
  /// final result = await certStore.addCertificate(...);
  ///
  /// if (!result.isOk) {
  ///   if (result.hasError(X509ErrorCode.alreadyExist)) {
  ///     // Handle duplicate certificate
  ///   } else if (result.hasError(X509ErrorCode.canceled)) {
  ///     // Handle user cancellation
  ///   } else {
  ///     // Handle other errors
  ///     print('Error ${result.code}: ${result.msg}');
  ///   }
  /// }
  /// ```
  ///
  /// ## Platform Considerations
  ///
  /// ### macOS
  /// - Certificates are added to the user's keychain by default
  /// - Root certificates require administrative privileges for system-wide trust
  /// - The plugin uses both Keychain Services API and the `security` command-line tool
  ///
  /// ### Windows (Future)
  /// - Will use Windows Certificate Store APIs
  /// - May require elevated privileges for certain operations
  ///
  /// ### Linux (Future)
  /// - Will integrate with system certificate stores
  /// - May vary by distribution
  Future<X509ResValue> addCertificate({
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
