import 'x509_cert_store_platform_interface.dart';

class X509CertStore {
  Future<String?> getPlatformVersion() {
    return X509CertStorePlatform.instance.getPlatformVersion();
  }

  Future<bool?> addCertificate(String certificateBase64) {
    return X509CertStorePlatform.instance.addCertificate(certificateBase64);
  }
}
