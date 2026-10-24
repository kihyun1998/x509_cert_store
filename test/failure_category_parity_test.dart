import 'package:test/test.dart';
import 'package:x509_cert_store/src/macos/macos_cert_store.dart';
import 'package:x509_cert_store/src/macos/security.dart';
import 'package:x509_cert_store/src/windows/crypt32.dart';
import 'package:x509_cert_store/src/windows/windows_cert_store.dart';
import 'package:x509_cert_store/x509_cert_store.dart';

/// One failure condition, with the native code each platform reports for it
/// and the category both must map it to.
typedef Condition = ({
  String name,
  int winError,
  int osStatus,
  X509ErrorCode category,
});

/// Every failure condition both platform backends report natively.
const List<Condition> conditions = [
  (
    name: 'the certificate is already in the store',
    winError: cryptEExists,
    osStatus: errSecDuplicateItem,
    category: X509ErrorCode.alreadyExist,
  ),
  (
    name: 'the user dismissed the prompt',
    winError: errorCancelled,
    osStatus: errSecUserCanceled,
    category: X509ErrorCode.canceled,
  ),
  (
    name: 'the caller lacks permission',
    winError: errorAccessDenied,
    osStatus: errSecAuthFailed,
    category: X509ErrorCode.accessDenied,
  ),
  (
    name: 'the platform cannot decode the certificate',
    winError: 0x8009310B, // CRYPT_E_ASN1_BADTAG
    osStatus: errSecDecode,
    category: X509ErrorCode.invalidFormat,
  ),
];

/// The `CRYPT_E_ASN1_*` values whose `winerror.h` message describes malformed
/// input, by name.
const Map<String, int> asn1MalformedInput = {
  'CRYPT_E_ASN1_EOD': 0x80093102,
  'CRYPT_E_ASN1_CORRUPT': 0x80093103,
  'CRYPT_E_ASN1_LARGE': 0x80093104,
  'CRYPT_E_ASN1_CONSTRAINT': 0x80093105,
  'CRYPT_E_ASN1_BADREAL': 0x8009310A,
  'CRYPT_E_ASN1_BADTAG': 0x8009310B,
  'CRYPT_E_ASN1_CHOICE': 0x8009310C,
  'CRYPT_E_ASN1_RULE': 0x8009310D,
  'CRYPT_E_ASN1_UTF8': 0x8009310E,
  'CRYPT_E_ASN1_NOEOD': 0x80093202,
};

/// The other `CRYPT_E_ASN1_*` values, which do not describe the input.
const Map<String, int> asn1NotInput = {
  'CRYPT_E_ASN1_ERROR': 0x80093100,
  'CRYPT_E_ASN1_INTERNAL': 0x80093101,
  'CRYPT_E_ASN1_MEMORY': 0x80093106,
  'CRYPT_E_ASN1_OVERFLOW': 0x80093107,
  'CRYPT_E_ASN1_BADPDU': 0x80093108,
  'CRYPT_E_ASN1_BADARGS': 0x80093109,
  'CRYPT_E_ASN1_PDU_TYPE': 0x80093133,
  'CRYPT_E_ASN1_NYI': 0x80093134,
  'CRYPT_E_ASN1_EXTENDED': 0x80093201,
};

void main() {
  group('both platforms put the same condition in the same category', () {
    for (final condition in conditions) {
      test(condition.name, () {
        final windows = failureFromWinError('op', condition.winError);
        final macos = failureFromOSStatus(condition.osStatus);

        expect(windows.code, condition.category);
        expect(macos.code, condition.category);
        expect(windows.nativeCode, isNull);
        expect(macos.nativeCode, isNull);
      });
    }
  });

  test('every category but unknown is mapped on both platforms', () {
    final covered = {
      for (final condition in conditions) condition.category,
      X509ErrorCode.unknown,
    };
    expect(covered, containsAll(X509ErrorCode.values));
  });

  group('Windows ASN.1 errors', () {
    for (final MapEntry(key: name, value: code) in asn1MalformedInput.entries) {
      test('$name is invalidFormat', () {
        final failure = failureFromWinError('op', code);
        expect(failure.code, X509ErrorCode.invalidFormat);
        expect(failure.nativeCode, isNull);
      });
    }

    for (final MapEntry(key: name, value: code) in asn1NotInput.entries) {
      test('$name stays unknown', () {
        final failure = failureFromWinError('op', code);
        expect(failure.code, X509ErrorCode.unknown);
        expect(failure.nativeCode, code);
      });
    }
  });

  group('an unmapped code is unknown and keeps the code', () {
    test('Windows', () {
      const unmapped = 0x80093106; // CRYPT_E_ASN1_MEMORY
      final failure = failureFromWinError('op', unmapped);
      expect(failure.code, X509ErrorCode.unknown);
      expect(failure.nativeCode, unmapped);
    });

    test('macOS', () {
      const unmapped = -34018; // errSecMissingEntitlement
      final failure = failureFromOSStatus(unmapped);
      expect(failure.code, X509ErrorCode.unknown);
      expect(failure.nativeCode, unmapped);
    });
  });
}
