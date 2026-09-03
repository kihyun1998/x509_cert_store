import 'dart:io';
import 'dart:typed_data';

import 'macos/macos_cert_store.dart';
import 'windows/windows_cert_store.dart';
import 'x509_res_result.dart';
import 'x509_store_enums.dart' show X509AddType, X509ErrorCode, X509StoreName;

/// The seam between the public API and the platform FFI calls.
///
/// FFI bindings cannot be mocked the way a method channel could, so the
/// platform work sits behind this interface and tests substitute a fake.
/// Input normalization (base64, PEM/DER) happens above the seam, so a backend
/// always receives DER bytes.
abstract interface class X509CertStoreBackend {
  Future<X509Result> addCertificate({
    required X509StoreName storeName,
    required Uint8List der,
    required X509AddType addType,
    required bool setTrusted,
  });
}

/// Returns the backend for the host platform.
X509CertStoreBackend createPlatformBackend() {
  if (Platform.isWindows) return WindowsCertStore();
  if (Platform.isMacOS) return MacOsCertStore();
  return const UnsupportedBackend();
}

/// Backend for platforms with no certificate store integration.
///
/// Reports `unknown` rather than throwing, so a consumer running on an
/// unsupported platform gets the same [X509Failure] handling as any other
/// failure instead of an exception escaping [X509Result].
class UnsupportedBackend implements X509CertStoreBackend {
  const UnsupportedBackend();

  @override
  Future<X509Result> addCertificate({
    required X509StoreName storeName,
    required Uint8List der,
    required X509AddType addType,
    required bool setTrusted,
  }) async {
    return X509Failure(
      code: X509ErrorCode.unknown,
      msg: 'x509_cert_store does not support ${Platform.operatingSystem}',
    );
  }
}
