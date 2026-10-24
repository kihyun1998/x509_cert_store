import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:x509_cert_store/src/asn1/der.dart';
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

  group('malformed DER is rejected before the platform layer', () {
    Future<(X509Result, FakeBackend)> addDer(List<int> der) async {
      final backend = FakeBackend();
      final result = await X509CertStore.withBackend(backend).addCertificate(
        storeName: X509StoreName.my,
        certificateBase64: base64.encode(der),
        addType: X509AddType.addNew,
      );
      return (result, backend);
    }

    final cases = <String, List<int>>{
      'bytes that start with 0x30 but are not a certificate': [
        0x30, 0x03, 0x01, 0x02, 0x03, //
      ],
      'a truncated certificate':
          certificateDer.sublist(0, certificateDer.length ~/ 2),
      'a SEQUENCE whose declared length overruns the buffer': [
        0x30, 0x82, 0xFF, 0xFF, //
      ],
      'an indefinite-length SEQUENCE': [0x30, 0x80, 0x00, 0x00],
      'a subject that is not a SEQUENCE': _retag(certificateDer, tbs: 5),
      'a subjectPublicKeyInfo that is not a SEQUENCE':
          _retag(certificateDer, tbs: 6),
      'a signatureAlgorithm that is not a SEQUENCE':
          _retag(certificateDer, top: 1),
      'a signatureValue that is not a BIT STRING':
          _retag(certificateDer, top: 2),
    };

    for (final MapEntry(key: name, value: der) in cases.entries) {
      test('$name -> invalidFormat, backend never called', () async {
        final (result, backend) = await addDer(der);

        expect(
          result,
          const X509Failure(
            code: X509ErrorCode.invalidFormat,
            msg: 'Invalid certificate data',
          ),
        );
        expect(backend.callCount, 0);
      });
    }

    test('bytes after the certificate are ignored, as both platforms do',
        () async {
      final trailing = [...certificateDer, 0x00, 0x00, 0x00];
      final (result, backend) = await addDer(trailing);

      expect(result, isA<X509Success>());
      expect(backend.lastDer, trailing);
    });

    test('a v1 certificate, with no version field, reaches the backend',
        () async {
      final v1 = base64.decode(certificateV1Base64);
      final (result, backend) = await addDer(v1);

      expect(result, isA<X509Success>());
      expect(backend.callCount, 1);
      expect(backend.lastDer, v1);
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

/// [der] with the identifier octet of one element replaced by `0x04` (OCTET
/// STRING): a direct child of the `Certificate` when [top] is given, or of
/// the `TBSCertificate` when [tbs] is.
List<int> _retag(List<int> der, {int? top, int? tbs}) {
  final bytes = Uint8List.fromList(der);
  final children = Der.childrenOf(bytes, Der.read(bytes, 0)!)!;
  final element = tbs == null
      ? children[top!]
      : Der.childrenOf(bytes, children.first)![tbs];
  return bytes..[element.start] = 0x04;
}
