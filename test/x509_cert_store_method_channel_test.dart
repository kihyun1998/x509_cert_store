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

  group('addCertificate result mapping', () {
    test('Success path returns X509Success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => true);

      final result = await certStore.addCertificate(
        storeName: X509StoreName.root,
        certificateBase64: dummyCertBase64,
        addType: X509AddType.addNew,
      );

      expect(result, isA<X509Success>());
    });

    test('Native returns false without throwing → X509Failure(unknown)',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => false);

      final result = await certStore.addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: dummyCertBase64,
        addType: X509AddType.addNew,
      );

      expect(result, isA<X509Failure>());
      expect((result as X509Failure).code, X509ErrorCode.unknown);
    });

    test(
        'PlatformException(code: "unknown", details: {nativeCode: N}) '
        '→ X509Failure(code: unknown, nativeCode: N)', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: 'unknown',
          message: 'Failed to add certificate (Win32 error 2148081669)',
          details: {'nativeCode': 2148081669},
        );
      });

      final result = await certStore.addCertificate(
        storeName: X509StoreName.root,
        certificateBase64: dummyCertBase64,
        addType: X509AddType.addNew,
      );

      expect(result, isA<X509Failure>());
      final failure = result as X509Failure;
      expect(failure.code, X509ErrorCode.unknown);
      expect(failure.nativeCode, 2148081669);
    });

    test('PlatformException without details → nativeCode is null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: 'unknown',
          message: 'Missing arguments',
        );
      });

      final result = await certStore.addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: dummyCertBase64,
        addType: X509AddType.addNew,
      );

      expect(result, isA<X509Failure>());
      final failure = result as X509Failure;
      expect(failure.code, X509ErrorCode.unknown);
      expect(failure.nativeCode, isNull);
    });

    test(
        'Each category key on PlatformException.code maps to the matching X509ErrorCode',
        () async {
      final cases = {
        'canceled': X509ErrorCode.canceled,
        'alreadyExist': X509ErrorCode.alreadyExist,
        'accessDenied': X509ErrorCode.accessDenied,
        'invalidFormat': X509ErrorCode.invalidFormat,
        'unknown': X509ErrorCode.unknown,
        'garbage': X509ErrorCode.unknown, // unrecognized key falls back
      };

      for (final entry in cases.entries) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: entry.key, message: 'test');
        });

        final result = await certStore.addCertificate(
          storeName: X509StoreName.my,
          certificateBase64: dummyCertBase64,
          addType: X509AddType.addNew,
        );

        expect(result, isA<X509Failure>(), reason: 'key=${entry.key}');
        expect((result as X509Failure).code, entry.value,
            reason: 'key=${entry.key}');
      }
    });

    test('Bad base64 input → X509Failure(invalidFormat)', () async {
      final result = await certStore.addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: '!!!not-base64!!!',
        addType: X509AddType.addNew,
      );

      expect(result, isA<X509Failure>());
      expect((result as X509Failure).code, X509ErrorCode.invalidFormat);
    });

    test('Mapped categories carry nativeCode = null (per #5 contract)',
        () async {
      final cases = {
        'canceled': X509ErrorCode.canceled,
        'alreadyExist': X509ErrorCode.alreadyExist,
        'accessDenied': X509ErrorCode.accessDenied,
        'invalidFormat': X509ErrorCode.invalidFormat,
      };

      for (final entry in cases.entries) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(
            code: entry.key,
            message: 'test',
            details: const {'nativeCode': null},
          );
        });

        final result = await certStore.addCertificate(
          storeName: X509StoreName.my,
          certificateBase64: dummyCertBase64,
          addType: X509AddType.addNew,
        );

        expect(result, isA<X509Failure>(), reason: 'key=${entry.key}');
        final failure = result as X509Failure;
        expect(failure.code, entry.value, reason: 'key=${entry.key}');
        expect(failure.nativeCode, isNull, reason: 'key=${entry.key}');
      }
    });
  });

  group('X509Result pattern matching', () {
    // Compile-time guarantee: the switch below must cover X509Success and
    // every X509ErrorCode value to satisfy the sealed-type exhaustiveness
    // checker. If a new X509ErrorCode is added without updating this test,
    // the file will fail to compile.
    String describe(X509Result r) {
      switch (r) {
        case X509Success():
          return 'success';
        case X509Failure(code: X509ErrorCode.canceled):
          return 'canceled';
        case X509Failure(code: X509ErrorCode.alreadyExist):
          return 'alreadyExist';
        case X509Failure(code: X509ErrorCode.accessDenied):
          return 'accessDenied';
        case X509Failure(code: X509ErrorCode.invalidFormat):
          return 'invalidFormat';
        case X509Failure(code: X509ErrorCode.unknown):
          return 'unknown';
      }
    }

    test('exhaustive switch covers success and all five error categories', () {
      expect(describe(const X509Success()), 'success');
      expect(
        describe(const X509Failure(code: X509ErrorCode.canceled, msg: '')),
        'canceled',
      );
      expect(
        describe(const X509Failure(code: X509ErrorCode.alreadyExist, msg: '')),
        'alreadyExist',
      );
      expect(
        describe(const X509Failure(code: X509ErrorCode.accessDenied, msg: '')),
        'accessDenied',
      );
      expect(
        describe(const X509Failure(code: X509ErrorCode.invalidFormat, msg: '')),
        'invalidFormat',
      );
      expect(
        describe(const X509Failure(
          code: X509ErrorCode.unknown,
          msg: '',
          nativeCode: 42,
        )),
        'unknown',
      );
    });
  });
}
