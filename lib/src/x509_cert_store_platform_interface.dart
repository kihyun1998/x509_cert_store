import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'x509_cert_store_method_channel.dart';
import 'x509_res_result.dart';
import 'x509_store_enums.dart' show X509StoreName, X509AddType;

/// The interface that platform-specific implementations of x509_cert_store must implement.
///
/// Platform implementations should extend this class rather than implement it,
/// since extending allows for non-breaking changes to be added to the interface.
///
/// This interface defines the contract for managing X.509 certificates across
/// different platforms (Windows, macOS, Linux, etc.).
abstract class X509CertStorePlatform extends PlatformInterface {
  /// Constructs a X509CertStorePlatform.
  X509CertStorePlatform() : super(token: _token);

  static final Object _token = Object();

  static X509CertStorePlatform _instance = MethodChannelX509CertStore();

  /// The default instance of [X509CertStorePlatform] to use.
  ///
  /// Defaults to [MethodChannelX509CertStore].
  static X509CertStorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [X509CertStorePlatform] when
  /// they register themselves.
  static set instance(X509CertStorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Adds a certificate to the specified certificate store.
  ///
  /// This method attempts to add an X.509 certificate to the platform's
  /// certificate store system. The behavior when a certificate with the same
  /// identity already exists is controlled by the [addType] parameter.
  ///
  /// Parameters:
  /// - [storeName]: The target certificate store (root, my, etc.)
  /// - [certificateBase64]: The certificate data encoded as base64
  /// - [addType]: Controls the addition behavior (add new, replace existing, etc.)
  /// - [setTrusted]: Whether to set the certificate as trusted (default: false)
  ///
  /// Returns a [Future] that completes with an [X509ResValue] indicating
  /// whether the operation succeeded or failed. On failure, the result
  /// contains error details that can be used for troubleshooting.
  ///
  /// Common failure scenarios:
  /// - Certificate already exists (when using [X509AddType.addNew])
  /// - Invalid certificate data format
  /// - Insufficient permissions to access the target store
  /// - Platform-specific security policy violations
  ///
  /// Example:
  /// ```dart
  /// // Add certificate without trust settings
  /// final result = await X509CertStorePlatform.instance.addCertificate(
  ///   storeName: X509StoreName.my,
  ///   certificateBase64: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMI...',
  ///   addType: X509AddType.addNew,
  /// );
  ///
  /// // Add certificate and set as trusted
  /// final trustedResult = await X509CertStorePlatform.instance.addCertificate(
  ///   storeName: X509StoreName.root,
  ///   certificateBase64: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMI...',
  ///   addType: X509AddType.addNew,
  ///   setTrusted: true,
  /// );
  ///
  /// if (result.isOk) {
  ///   print('Certificate added successfully');
  /// } else {
  ///   print('Failed to add certificate: ${result.msg}');
  /// }
  /// ```
  Future<X509ResValue> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
    bool setTrusted = false,
  }) {
    throw UnimplementedError('addCertificate() has not been implemented.');
  }
}
