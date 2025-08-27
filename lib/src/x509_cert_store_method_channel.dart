import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'x509_cert_store_platform_interface.dart';
import 'x509_res_result.dart';
import 'x509_store_enums.dart' show X509StoreName, X509AddType;

/// An implementation of [X509CertStorePlatform] that uses method channels.
///
/// This implementation communicates with platform-specific native code
/// through Flutter's method channel mechanism. It handles serialization
/// of method calls and deserialization of responses.
///
/// The method channel protocol:
/// - Method name: 'addCertificate'
/// - Parameters: storeName (String), certificate (Uint8List), addType (int)
/// - Return: bool (true on success) or PlatformException on failure
class MethodChannelX509CertStore extends X509CertStorePlatform {
  /// The method channel used to interact with the native platform.
  ///
  /// This channel is used for all communication between the Dart code
  /// and the platform-specific native implementations.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('io.github.kihyun1998/x509_cert_store');

  @override
  Future<X509ResValue> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
  }) async {
    try {
      // Decode the base64 certificate data to bytes
      final certificateBytes = base64.decode(certificateBase64);

      // Invoke the native method with the certificate data
      await methodChannel.invokeMethod<bool>(
        'addCertificate',
        {
          'storeName': storeName.getString(),
          'certificate': certificateBytes,
          'addType': addType.getCode(),
        },
      );

      // If we reach this point, the operation succeeded
      return X509ResValue.success();
    } on PlatformException catch (error) {
      // Handle platform-specific errors from the native side
      // The error code is typically embedded in the error code field
      final errorCode = error.code;
      final errorMessage = error.message ?? 'Unknown platform error occurred';

      return X509ResValue.error(
        errorCode,
        'Failed to add certificate: $errorMessage',
      );
    } on FormatException catch (error) {
      // Handle base64 decoding errors
      return X509ResValue.error(
        'INVALID_FORMAT',
        'Invalid base64 certificate data: ${error.message}',
      );
    } catch (error) {
      // Handle any other unexpected errors
      return X509ResValue.error(
        'UNEXPECTED_ERROR',
        'An unexpected error occurred: $error',
      );
    }
  }
}
