import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:x509_cert_store/src/backend.dart';
import 'package:x509_cert_store/src/pem.dart';
import 'package:x509_cert_store/x509_cert_store.dart';

import 'fixtures/test_certificates.dart';

/// Records what the platform layer was asked to do, and answers with a canned
/// result. FFI bindings cannot be mocked the way the previous method channel
/// could, so the seam is the backend interface instead.
class FakeBackend implements X509CertStoreBackend {
  FakeBackend({this.result = const X509Success(), this.throws});

  final X509Result result;
  final Object? throws;

  int callCount = 0;
  X509StoreName? lastStoreName;
  Uint8List? lastDer;
  X509AddType? lastAddType;
  bool? lastSetTrusted;

  @override
  Future<X509Result> addCertificate({
    required X509StoreName storeName,
    required Uint8List der,
    required X509AddType addType,
    required bool setTrusted,
  }) async {
    callCount++;
    lastStoreName = storeName;
    lastDer = der;
    lastAddType = addType;
    lastSetTrusted = setTrusted;
    if (throws != null) throw throws!;
    return result;
  }
}

void main() {
  final certificateDer = base64.decode(certificateOneBase64);

  group('input validation happens before the platform layer', () {
    test('invalid base64 -> invalidFormat, backend never called', () async {
      final backend = FakeBackend();
      final result = await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: 'not base64 !!!',
        addType: X509AddType.addNew,
      );

      expect(result, isA<X509Failure>());
      expect((result as X509Failure).code, X509ErrorCode.invalidFormat);
      expect(backend.callCount, 0);
    });

    test('empty string -> invalidFormat, backend never called', () async {
      final backend = FakeBackend();
      final result = await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: '',
        addType: X509AddType.addNew,
      );

      expect((result as X509Failure).code, X509ErrorCode.invalidFormat);
      expect(result.msg, 'Certificate data is empty');
      expect(backend.callCount, 0);
    });

    test('base64 of malformed PEM -> invalidFormat, backend never called',
        () async {
      final backend = FakeBackend();
      const brokenPem = '-----BEGIN CERTIFICATE-----\nMIIB\n';
      final result = await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: base64.encode(utf8.encode(brokenPem)),
        addType: X509AddType.addNew,
      );

      expect((result as X509Failure).code, X509ErrorCode.invalidFormat);
      expect(result.msg, 'Failed to convert PEM to DER format');
      expect(backend.callCount, 0);
    });
  });

  group('the backend always receives DER', () {
    test('base64-encoded DER is passed through unchanged', () async {
      final backend = FakeBackend();
      await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.root,
        certificateBase64: certificateOneBase64,
        addType: X509AddType.addNew,
      );

      expect(backend.lastDer, certificateDer);
    });

    test('base64-encoded PEM is decoded to DER first', () async {
      final backend = FakeBackend();
      final pem = Pem.encodePem(certificateDer);
      await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.root,
        certificateBase64: base64.encode(utf8.encode(pem)),
        addType: X509AddType.addNew,
      );

      expect(backend.lastDer, certificateDer);
      // Would also hold if the PEM text were forwarded verbatim, so assert
      // the shape that only DER has.
      expect(backend.lastDer!.first, 0x30);
    });
  });

  group('parameters reach the backend', () {
    test('store name, add type, and setTrusted are forwarded', () async {
      final backend = FakeBackend();
      await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.root,
        certificateBase64: certificateOneBase64,
        addType: X509AddType.addNewer,
        setTrusted: true,
      );

      expect(backend.lastStoreName, X509StoreName.root);
      expect(backend.lastAddType, X509AddType.addNewer);
      expect(backend.lastSetTrusted, isTrue);
    });

    test('setTrusted defaults to false', () async {
      final backend = FakeBackend();
      await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: certificateOneBase64,
        addType: X509AddType.addNew,
      );

      expect(backend.lastSetTrusted, isFalse);
    });
  });

  group('results are surfaced unchanged', () {
    test('success', () async {
      final backend = FakeBackend();
      final result = await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: certificateOneBase64,
        addType: X509AddType.addNew,
      );

      expect(result, isA<X509Success>());
    });

    test('a categorized failure keeps its category and native code', () async {
      const failure = X509Failure(
        code: X509ErrorCode.alreadyExist,
        msg: 'Certificate already exists',
      );
      final backend = FakeBackend(result: failure);
      final result = await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: certificateOneBase64,
        addType: X509AddType.addNew,
      );

      expect(result, failure);
    });

    test('an unmapped failure keeps nativeCode for diagnostics', () async {
      const failure = X509Failure(
        code: X509ErrorCode.unknown,
        msg: 'Security framework error: -34018',
        nativeCode: -34018,
      );
      final backend = FakeBackend(result: failure);
      final result = await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: certificateOneBase64,
        addType: X509AddType.addNew,
      );

      expect((result as X509Failure).nativeCode, -34018);
    });
  });

  test('a throwing backend becomes X509Failure, not an escaping exception',
      () async {
    // A missing platform library or a failed symbol lookup throws where the
    // linker used to catch the same mistake at build time; the sealed result
    // has to stay total.
    final backend = FakeBackend(
      throws: ArgumentError("Couldn't resolve native function 'SecItemAdd'"),
    );
    final result = await X509CertStore.withBackend(backend).addCertificate(
      storeName: X509StoreName.my,
      certificateBase64: certificateOneBase64,
      addType: X509AddType.addNew,
    );

    expect(result, isA<X509Failure>());
    expect((result as X509Failure).code, X509ErrorCode.unknown);
    expect(result.msg, contains('SecItemAdd'));
  });

  test('an unsupported platform reports unknown rather than throwing',
      () async {
    final result = await X509CertStore.withBackend(const UnsupportedBackend())
        .addCertificate(
      storeName: X509StoreName.my,
      certificateBase64: certificateOneBase64,
      addType: X509AddType.addNew,
    );

    expect((result as X509Failure).code, X509ErrorCode.unknown);
  });
}
