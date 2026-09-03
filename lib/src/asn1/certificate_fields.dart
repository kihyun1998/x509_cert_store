import 'dart:typed_data';

import 'der.dart';

/// ASN.1 identifier octets for the elements this parser walks.
const int _tagInteger = 0x02;
const int _tagUtcTime = 0x17;
const int _tagGeneralizedTime = 0x18;
const int _tagSequence = 0x30;
const int _tagContext0 = 0xA0;

/// The three certificate fields the store operations need.
///
/// The macOS backend previously obtained these from the Security framework
/// (`SecCertificateCopyNormalizedIssuerSequence`,
/// `SecCertificateCopySerialNumberData`, and `SecCertificateCopyValues`).
/// They are all present in the certificate's own DER, so parsing them here
/// removes the only Security API whose FFI signature would have required
/// walking a nested CFDictionary.
class CertificateFields {
  /// The DER encoding of the issuer `Name`, identifier octet included.
  ///
  /// Certificate identity is compared as (issuer, serialNumber), which RFC
  /// 5280 defines over the encoded name.
  final Uint8List issuerDer;

  /// The content octets of the `serialNumber` INTEGER.
  final Uint8List serialNumber;

  /// The `notBefore` half of the validity period, in UTC.
  final DateTime notBefore;

  const CertificateFields({
    required this.issuerDer,
    required this.serialNumber,
    required this.notBefore,
  });

  /// True when [other] denotes the same certificate identity.
  bool hasSameIdentityAs(CertificateFields other) =>
      _bytesEqual(issuerDer, other.issuerDer) &&
      _bytesEqual(serialNumber, other.serialNumber);

  /// Parses [der], returning null when it is not a well-formed certificate.
  ///
  /// Walks only as far as `validity`, so trailing structure (subject,
  /// extensions, signature) is never inspected:
  ///
  ///     Certificate     ::= SEQUENCE { tbsCertificate, signatureAlgorithm,
  ///                                    signatureValue }
  ///     TBSCertificate  ::= SEQUENCE { [0] version DEFAULT v1,
  ///                                    serialNumber, signature, issuer,
  ///                                    validity, subject, ... }
  ///     Validity        ::= SEQUENCE { notBefore, notAfter }
  static CertificateFields? parse(Uint8List der) {
    final certificate = Der.read(der, 0);
    if (certificate == null || certificate.tag != _tagSequence) return null;

    final topLevel = Der.childrenOf(der, certificate);
    if (topLevel == null || topLevel.isEmpty) return null;

    final tbs = topLevel.first;
    if (tbs.tag != _tagSequence) return null;

    final fields = Der.childrenOf(der, tbs);
    if (fields == null) return null;

    // `version` is [0] EXPLICIT and defaults to v1, so it is absent from most
    // v1 certificates. Everything after it shifts by one when it is present.
    final base =
        (fields.isNotEmpty && fields.first.tag == _tagContext0) ? 1 : 0;
    // serialNumber, signature, issuer, validity.
    if (fields.length < base + 4) return null;

    final serial = fields[base];
    final issuer = fields[base + 2];
    final validity = fields[base + 3];
    if (serial.tag != _tagInteger) return null;
    if (issuer.tag != _tagSequence) return null;
    if (validity.tag != _tagSequence) return null;

    final validityFields = Der.childrenOf(der, validity);
    if (validityFields == null || validityFields.isEmpty) return null;

    final notBefore = _parseTime(der, validityFields.first);
    if (notBefore == null) return null;

    return CertificateFields(
      issuerDer: issuer.bytesOf(der),
      serialNumber: serial.contentOf(der),
      notBefore: notBefore,
    );
  }

  /// Parses a UTCTime or GeneralizedTime element. DER requires both to end in
  /// 'Z', so only the UTC forms are accepted; anything else returns null.
  static DateTime? _parseTime(Uint8List buffer, DerElement element) {
    final String text;
    try {
      text = String.fromCharCodes(element.contentOf(buffer));
    } on ArgumentError {
      return null;
    }
    if (!text.endsWith('Z')) return null;
    final digits = text.substring(0, text.length - 1);

    final int year;
    final String remainder;
    switch (element.tag) {
      case _tagUtcTime:
        // YYMMDDHHMMSSZ. RFC 5280: YY >= 50 is 19YY, otherwise 20YY.
        if (digits.length < 10) return null;
        final shortYear = int.tryParse(digits.substring(0, 2));
        if (shortYear == null) return null;
        year = shortYear >= 50 ? 1900 + shortYear : 2000 + shortYear;
        remainder = digits.substring(2);
      case _tagGeneralizedTime:
        // YYYYMMDDHHMMSSZ.
        if (digits.length < 12) return null;
        final fullYear = int.tryParse(digits.substring(0, 4));
        if (fullYear == null) return null;
        year = fullYear;
        remainder = digits.substring(4);
      default:
        return null;
    }

    // MMDDHHMM, with SS present in the DER form and absent in the shortest
    // legal BER form.
    final month = int.tryParse(remainder.substring(0, 2));
    final day = int.tryParse(remainder.substring(2, 4));
    final hour = int.tryParse(remainder.substring(4, 6));
    final minute = int.tryParse(remainder.substring(6, 8));
    final second =
        remainder.length >= 10 ? int.tryParse(remainder.substring(8, 10)) : 0;
    if (month == null ||
        day == null ||
        hour == null ||
        minute == null ||
        second == null) {
      return null;
    }

    return DateTime.utc(year, month, day, hour, minute, second);
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
