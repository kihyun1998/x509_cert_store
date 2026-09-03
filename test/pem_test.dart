import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:x509_cert_store/src/pem.dart';

import 'fixtures/test_certificates.dart';

/// PEM/DER handling used to be implemented twice - `ConvertPemToDer` in C++
/// and `prepareCertificateData` in Swift - and neither was reachable from a
/// host test. It is now one Dart implementation shared by both backends.
void main() {
  final certificateDer = base64.decode(certificateOneBase64);

  group('normalizeToDer', () {
    test('passes DER through untouched', () {
      expect(Pem.normalizeToDer(certificateDer), certificateDer);
    });

    test('decodes PEM text to the same DER', () {
      final pemBytes = utf8.encode(Pem.encodePem(certificateDer));
      expect(Pem.normalizeToDer(Uint8List.fromList(pemBytes)), certificateDer);
    });

    test('accepts PEM with CRLF line endings', () {
      final pem = Pem.encodePem(certificateDer).replaceAll('\n', '\r\n');
      expect(
        Pem.normalizeToDer(Uint8List.fromList(utf8.encode(pem))),
        certificateDer,
      );
    });

    test('accepts PEM with surrounding text', () {
      final pem = 'issued by the test CA\n'
          '${Pem.encodePem(certificateDer)}'
          'trailing notes\n';
      expect(
        Pem.normalizeToDer(Uint8List.fromList(utf8.encode(pem))),
        certificateDer,
      );
    });

    test('rejects empty input', () {
      expect(Pem.normalizeToDer(Uint8List(0)), isNull);
    });

    test('rejects PEM with no END marker', () {
      const pem = '-----BEGIN CERTIFICATE-----\nMIIB\n';
      expect(Pem.normalizeToDer(Uint8List.fromList(utf8.encode(pem))), isNull);
    });

    test('rejects PEM whose END marker precedes BEGIN', () {
      // The C++ implementation computed `endPos - beginPos` here, which
      // underflowed size_t and threw out of substr.
      const pem = '-----END CERTIFICATE-----\nMIIB\n'
          '-----BEGIN CERTIFICATE-----\n';
      expect(Pem.normalizeToDer(Uint8List.fromList(utf8.encode(pem))), isNull);
    });

    test('rejects PEM with an empty body', () {
      const pem = '-----BEGIN CERTIFICATE-----\n\n-----END CERTIFICATE-----\n';
      expect(Pem.normalizeToDer(Uint8List.fromList(utf8.encode(pem))), isNull);
    });

    test('rejects PEM whose body is not base64', () {
      const pem = '-----BEGIN CERTIFICATE-----\n'
          '!!!not base64!!!\n'
          '-----END CERTIFICATE-----\n';
      expect(Pem.normalizeToDer(Uint8List.fromList(utf8.encode(pem))), isNull);
    });

    test('passes non-UTF-8 bytes through for the platform to reject', () {
      // 0xFF is never a valid UTF-8 lead byte, and not the 0x30 that starts
      // DER either. Normalization must not throw on it.
      final garbage = Uint8List.fromList([0xFF, 0xFE, 0xFD]);
      expect(Pem.normalizeToDer(garbage), garbage);
    });
  });

  group('encodePem', () {
    test('round-trips through normalizeToDer', () {
      final pem = Pem.encodePem(certificateDer);
      expect(
        Pem.normalizeToDer(Uint8List.fromList(utf8.encode(pem))),
        certificateDer,
      );
    });

    test('wraps the body at 64 characters', () {
      final lines = Pem.encodePem(certificateDer).trim().split('\n');
      final body = lines.sublist(1, lines.length - 1);
      expect(body, isNotEmpty);
      for (final line in body) {
        expect(line.length, lessThanOrEqualTo(64));
      }
      // Everything but the final line must be exactly full.
      for (final line in body.sublist(0, body.length - 1)) {
        expect(line.length, 64);
      }
    });

    test('emits both markers', () {
      final pem = Pem.encodePem(certificateDer);
      expect(pem, startsWith('-----BEGIN CERTIFICATE-----\n'));
      expect(pem.trimRight(), endsWith('-----END CERTIFICATE-----'));
    });
  });
}
