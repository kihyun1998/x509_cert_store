import 'package:x509_cert_store/x509_cert_store_enum.dart';
import 'package:x509_cert_store/x509_cert_store_return_class.dart';

import 'x509_cert_store_platform_interface.dart';

class X509CertStore {
  Future<String?> getPlatformVersion() {
    return X509CertStorePlatform.instance.getPlatformVersion();
  }

  Future<X509ResValue> addCertificate(
      {required X509StoreName storeName, required String certificateBase64}) {
    return X509CertStorePlatform.instance.addCertificate(
      storeName: storeName,
      certificateBase64: certificateBase64,
    );
  }
}
