import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'x509_cert_store_platform_interface.dart';
import 'x509_res_result.dart';
import 'x509_store_enums.dart' show X509StoreName, X509AddType, X509ErrorCode;

/// An implementation of [X509CertStorePlatform] that uses method channels.
///
/// Method-channel protocol:
/// - Method name: `addCertificate`
/// - Parameters: `storeName` (String), `certificate` (Uint8List), `addType` (int), `setTrusted` (bool)
/// - Success: returns `true`
/// - Failure: throws `PlatformException` where `code` is one of the
///   category keys (`"canceled"`, `"alreadyExist"`, `"accessDenied"`,
///   `"invalidFormat"`, `"unknown"`), and `details` is a map that may
///   contain `nativeCode` (int). Categorical mapping at the native layer
///   is filled in by a follow-up slice; until then native plugins emit
///   `code: "unknown"` with `nativeCode` populated.
class MethodChannelX509CertStore extends X509CertStorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('io.github.kihyun1998/x509_cert_store');

  @override
  Future<X509Result> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
    bool setTrusted = false,
  }) async {
    try {
      final certificateBytes = base64.decode(certificateBase64);

      final added = await methodChannel.invokeMethod<bool>(
        'addCertificate',
        {
          'storeName': storeName.getString(),
          'certificate': certificateBytes,
          'addType': addType.getCode(),
          'setTrusted': setTrusted,
        },
      );

      if (added == true) {
        return const X509Success();
      }

      // Native side signals failure by throwing a PlatformException; a
      // non-true return without an exception is unexpected, so surface it as
      // an unknown failure rather than reporting a false success.
      return const X509Failure(
        code: X509ErrorCode.unknown,
        msg:
            'Native addCertificate returned a non-true result without an error',
      );
    } on PlatformException catch (error) {
      return _failureFromPlatformException(error);
    } on FormatException catch (error) {
      return X509Failure(
        code: X509ErrorCode.invalidFormat,
        msg: 'Invalid base64 certificate data: ${error.message}',
      );
    } catch (error) {
      return X509Failure(
        code: X509ErrorCode.unknown,
        msg: 'An unexpected error occurred: $error',
      );
    }
  }

  X509Failure _failureFromPlatformException(PlatformException error) {
    final categoryKey = error.code;
    final msg = error.message ?? 'Unknown platform error occurred';

    int? nativeCode;
    final details = error.details;
    if (details is Map) {
      final raw = details['nativeCode'];
      if (raw is int) {
        nativeCode = raw;
      }
    }

    return X509Failure(
      code: _parseCategory(categoryKey),
      msg: msg,
      nativeCode: nativeCode,
    );
  }

  X509ErrorCode _parseCategory(String key) {
    switch (key) {
      case 'canceled':
        return X509ErrorCode.canceled;
      case 'alreadyExist':
        return X509ErrorCode.alreadyExist;
      case 'accessDenied':
        return X509ErrorCode.accessDenied;
      case 'invalidFormat':
        return X509ErrorCode.invalidFormat;
      default:
        return X509ErrorCode.unknown;
    }
  }
}
