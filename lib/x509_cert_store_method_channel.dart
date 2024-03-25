import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'x509_cert_store_platform_interface.dart';

/// An implementation of [X509CertStorePlatform] that uses method channels.
class MethodChannelX509CertStore extends X509CertStorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('x509_cert_store');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
