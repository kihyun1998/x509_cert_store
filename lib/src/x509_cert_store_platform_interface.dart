import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'x509_cert_store_method_channel.dart';
import 'x509_res_result.dart';
import 'x509_store_enums.dart' show X509StoreName, X509AddType;

/// The interface that platform-specific implementations of `x509_cert_store`
/// must implement.
///
/// Platform implementations should *extend* this class rather than implement
/// it, so non-breaking changes can be added to the interface in the future.
abstract class X509CertStorePlatform extends PlatformInterface {
  /// Constructs an [X509CertStorePlatform].
  X509CertStorePlatform() : super(token: _token);

  static final Object _token = Object();

  static X509CertStorePlatform _instance = MethodChannelX509CertStore();

  /// The default instance of [X509CertStorePlatform] to use.
  static X509CertStorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own class
  /// that extends [X509CertStorePlatform] when they register themselves.
  static set instance(X509CertStorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Adds a certificate to the specified certificate store.
  ///
  /// Returns an [X509Result] — either [X509Success] or [X509Failure].
  /// Consumers should pattern-match on the result to handle each case
  /// exhaustively.
  ///
  /// Parameters:
  /// - [storeName]: The target certificate store (root, my)
  /// - [certificateBase64]: The certificate data encoded as base64
  /// - [addType]: Controls the addition behavior
  /// - [setTrusted]: Whether to set the certificate as trusted
  ///   (macOS only; ignored on Windows)
  Future<X509Result> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
    bool setTrusted = false,
  }) {
    throw UnimplementedError('addCertificate() has not been implemented.');
  }
}
