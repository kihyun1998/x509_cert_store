import 'package:flutter_test/flutter_test.dart';
import 'package:x509_cert_store/x509_cert_store.dart';
import 'package:x509_cert_store/x509_cert_store_platform_interface.dart';
import 'package:x509_cert_store/x509_cert_store_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockX509CertStorePlatform
    with MockPlatformInterfaceMixin
    implements X509CertStorePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final X509CertStorePlatform initialPlatform = X509CertStorePlatform.instance;

  test('$MethodChannelX509CertStore is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelX509CertStore>());
  });

  test('getPlatformVersion', () async {
    X509CertStore x509CertStorePlugin = X509CertStore();
    MockX509CertStorePlatform fakePlatform = MockX509CertStorePlatform();
    X509CertStorePlatform.instance = fakePlatform;

    expect(await x509CertStorePlugin.getPlatformVersion(), '42');
  });
}
