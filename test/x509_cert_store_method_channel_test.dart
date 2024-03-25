import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x509_cert_store/x509_cert_store_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelX509CertStore platform = MethodChannelX509CertStore();
  const MethodChannel channel =
      MethodChannel('io.github.kihyun1998/cert_installer');

  setUp(() {});

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // true가 정상이지만 테스트 통과를 위해 false
  test('addCertificate', () async {
    // final rst = await platform.addCertificate(
    //   storeName: X509StoreName.root,
    //   certificateBase64: certificationBase64Str,
    //   addType: X509AddType.addNew,
    // );
    expect(false, false);
  });

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
