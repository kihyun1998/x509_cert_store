import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'x509_cert_store_platform_interface.dart';

/// An implementation of [X509CertStorePlatform] that uses method channels.
class MethodChannelX509CertStore extends X509CertStorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('io.github.kihyun1998/cert_installer');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> addCertificate(String certificateBase64) async {
    try {
      final certificateBytes = base64.decode(certificateBase64);
      final result = await methodChannel.invokeMethod<bool>(
        'addCertificate',
        {'certificate': certificateBytes},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      log("Failed to add certificate : ${e.message}.");
      return false;
    }
  }
}
