import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x509_cert_store/x509_cert_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('io.github.kihyun1998/x509_cert_store');
  final certStore = X509CertStore();
  const dummyCertBase64 = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA';

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('addCertificate error-code mapping', () {
    test('CRYPT_E_EXISTS round-trips to hasError(alreadyExist)', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: '2148081669',
          message:
              'Failed to add certificate to store (Win32 error 2148081669)',
        );
      });

      final result = await certStore.addCertificate(
        storeName: X509StoreName.root,
        certificateBase64: dummyCertBase64,
        addType: X509AddType.addNew,
      );

      expect(result.isOk, isFalse);
      expect(result.code, '2148081669');
      expect(result.hasError(X509ErrorCode.alreadyExist), isTrue);
      expect(result.hasError(X509ErrorCode.canceled), isFalse);
    });

    test('ERROR_CANCELLED round-trips to hasError(canceled)', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: '1223',
          message: 'Failed to add certificate to store (Win32 error 1223)',
        );
      });

      final result = await certStore.addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: dummyCertBase64,
        addType: X509AddType.addNew,
      );

      expect(result.isOk, isFalse);
      expect(result.code, '1223');
      expect(result.hasError(X509ErrorCode.canceled), isTrue);
      expect(result.hasError(X509ErrorCode.alreadyExist), isFalse);
    });

    test('Successful native call returns isOk = true', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => true);

      final result = await certStore.addCertificate(
        storeName: X509StoreName.root,
        certificateBase64: dummyCertBase64,
        addType: X509AddType.addNew,
      );

      expect(result.isOk, isTrue);
      expect(result.code, 'SUCCESS');
    });
  });
}
