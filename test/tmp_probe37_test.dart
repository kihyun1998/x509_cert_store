@TestOn('windows')
library;

// TEMPORARY probe for #37 - never merged. Calls only
// CertCreateCertificateContext / CertFreeCertificateContext; no store is
// opened or written.
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import 'package:x509_cert_store/src/asn1/certificate_fields.dart';
import 'package:x509_cert_store/src/asn1/der.dart';
import 'package:x509_cert_store/src/windows/crypt32.dart';

import 'fixtures/test_certificates.dart';

String hex(int v) => '0x${v.toRadixString(16).padLeft(8, '0').toUpperCase()}';

void main() {
  test('probe #37: CertCreateCertificateContext codes', () {
    ensureBindingsResolved();
    final der = base64.decode(certificateOneBase64);
    final top = Der.childrenOf(der, Der.read(der, 0)!)!;
    final tbsFields = Der.childrenOf(der, top[0])!;
    final cases = <String, Uint8List>{
      'original': der,
      'subject tag -> 0x04': Uint8List.fromList(der)
        ..[tbsFields[5].start] = 0x04,
      'SPKI tag -> 0x04': Uint8List.fromList(der)..[tbsFields[6].start] = 0x04,
      'signatureAlgorithm tag -> 0x04': Uint8List.fromList(der)
        ..[top[1].start] = 0x04,
      'signatureValue tag -> 0x04': Uint8List.fromList(der)
        ..[top[2].start] = 0x04,
      'trailing 3 bytes': Uint8List.fromList([...der, 0, 0, 0]),
      'v1 fixture': base64.decode(certificateV1Base64),
      '30 03 01 02 03 (rejected above the seam since 3.0.1)':
          Uint8List.fromList([0x30, 0x03, 0x01, 0x02, 0x03]),
    };
    for (final MapEntry(key: name, value: bytes) in cases.entries) {
      final parses = CertificateFields.parse(bytes) != null;
      final buf = calloc<Uint8>(bytes.length);
      buf.asTypedList(bytes.length).setAll(0, bytes);
      final ctx =
          certCreateCertificateContext(certEncodingTypes, buf, bytes.length);
      final err = ctx == nullptr ? getLastError() : 0;
      if (ctx != nullptr) certFreeCertificateContext(ctx);
      calloc.free(buf);
      print('PROBE37 | $name | parse=${parses ? 'accept' : 'reject'} | '
          'context=${ctx == nullptr ? 'reject ${hex(err)} ($err)' : 'accept'}');
    }
  });

  test('probe #37: winerror.h CRYPT_E_ASN1_* on this runner', () {
    final root = Directory(r'C:\Program Files (x86)\Windows Kits\10\Include');
    final versions = root.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    final header = File('${versions.last.path}\\shared\\winerror.h');
    print('PROBE37H | ${header.path}');
    final lines = header.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (RegExp(r'#define\s+CRYPT_E_ASN1_\w+').hasMatch(lines[i]) ||
          RegExp(r'#define\s+CRYPT_E_(BAD_ENCODE|UNKNOWN_ALGO|BAD_LEN|INVALID_MSG_TYPE|OSS_ERROR)\b')
              .hasMatch(lines[i])) {
        print('PROBE37H | ${lines[i].trim()}');
      }
    }
  });
}
