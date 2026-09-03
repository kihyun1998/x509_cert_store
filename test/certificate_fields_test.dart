import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:x509_cert_store/src/asn1/certificate_fields.dart';

import 'fixtures/test_certificates.dart';

/// These cover the parsing that replaced `SecCertificateCopyValues`,
/// `SecCertificateCopyNormalizedIssuerSequence`, and
/// `SecCertificateCopySerialNumberData`. Before the FFI migration the same
/// logic was only reachable on a macOS host; it now runs anywhere.
void main() {
  final certificateOne = base64.decode(certificateOneBase64);
  final certificateTwo = base64.decode(certificateTwoBase64);

  group('parse', () {
    test('reads the serial number of a real certificate', () {
      final fields = CertificateFields.parse(certificateOne)!;
      expect(fields.serialNumber, certificateOneSerial);
    });

    test('reads a different serial from the second certificate', () {
      final fields = CertificateFields.parse(certificateTwo)!;
      expect(fields.serialNumber, certificateTwoSerial);
    });

    test('reads notBefore from the UTCTime encoding', () {
      final fields = CertificateFields.parse(certificateOne)!;
      expect(fields.notBefore, certificateNotBefore);
      expect(fields.notBefore.isUtc, isTrue);
    });

    test('returns the issuer as a DER SEQUENCE, markers included', () {
      final fields = CertificateFields.parse(certificateOne)!;
      expect(fields.issuerDer.first, 0x30);
      // Long enough to hold "x509 cert store test CA" plus the O= attribute.
      expect(fields.issuerDer.length, greaterThan(20));
    });

    test(
        'both fixtures are self-signed with the same subject, so their '
        'issuer encodings are byte-identical', () {
      final one = CertificateFields.parse(certificateOne)!;
      final two = CertificateFields.parse(certificateTwo)!;
      expect(one.issuerDer, two.issuerDer);
    });
  });

  group('parse rejects malformed input', () {
    test('empty input', () {
      expect(CertificateFields.parse(Uint8List(0)), isNull);
    });

    test('a non-certificate byte string', () {
      expect(
        CertificateFields.parse(Uint8List.fromList([1, 2, 3, 4, 5])),
        isNull,
      );
    });

    test('a truncated certificate', () {
      final truncated =
          Uint8List.sublistView(certificateOne, 0, certificateOne.length ~/ 2);
      expect(CertificateFields.parse(truncated), isNull);
    });

    test('a SEQUENCE whose declared length overruns the buffer', () {
      // 0x30 0x82 0xFF 0xFF says "SEQUENCE of 65535 bytes" in a 4-byte buffer.
      final overrun = Uint8List.fromList([0x30, 0x82, 0xFF, 0xFF]);
      expect(CertificateFields.parse(overrun), isNull);
    });

    test('an indefinite-length SEQUENCE, which DER forbids', () {
      final indefinite = Uint8List.fromList([0x30, 0x80, 0x00, 0x00]);
      expect(CertificateFields.parse(indefinite), isNull);
    });
  });

  group('hasSameIdentityAs', () {
    test('a certificate matches itself', () {
      final a = CertificateFields.parse(certificateOne)!;
      final b = CertificateFields.parse(certificateOne)!;
      expect(a.hasSameIdentityAs(b), isTrue);
    });

    test('same issuer with a different serial is a different identity', () {
      final one = CertificateFields.parse(certificateOne)!;
      final two = CertificateFields.parse(certificateTwo)!;
      // Guards against an identity check that only compares the issuer: these
      // two fixtures share an issuer and differ only in serial number.
      expect(one.issuerDer, two.issuerDer);
      expect(one.serialNumber, isNot(two.serialNumber));
      expect(one.hasSameIdentityAs(two), isFalse);
    });

    test('same serial under a different issuer is a different identity', () {
      final one = CertificateFields.parse(certificateOne)!;
      final impostor = CertificateFields(
        issuerDer: Uint8List.fromList([0x30, 0x03, 0x02, 0x01, 0x00]),
        serialNumber: Uint8List.fromList(certificateOneSerial),
        notBefore: certificateNotBefore,
      );
      expect(one.hasSameIdentityAs(impostor), isFalse);
    });

    test('identity ignores notBefore', () {
      final one = CertificateFields.parse(certificateOne)!;
      final renewed = CertificateFields(
        issuerDer: one.issuerDer,
        serialNumber: one.serialNumber,
        notBefore: one.notBefore.add(const Duration(days: 365)),
      );
      expect(one.hasSameIdentityAs(renewed), isTrue);
    });
  });
}
