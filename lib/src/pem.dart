import 'dart:convert';
import 'dart:typed_data';

/// PEM/DER helpers shared by both platform backends.
///
/// The public API accepts a base64 string that decodes either to raw DER
/// bytes or to PEM text. Normalization used to live in the native layers
/// (`ConvertPemToDer` in C++, `prepareCertificateData` in Swift); it is pure
/// byte manipulation, so it now runs once in Dart for both platforms.
abstract final class Pem {
  static const _beginMarker = '-----BEGIN CERTIFICATE-----';
  static const _endMarker = '-----END CERTIFICATE-----';

  /// Returns [input] as DER, decoding it from PEM first when it is PEM text.
  ///
  /// Returns null when the input is empty or looks like PEM but cannot be
  /// decoded; callers surface that as [X509ErrorCode.invalidFormat].
  ///
  /// A DER certificate always starts with 0x30 (an ASN.1 SEQUENCE tag), so a
  /// leading 0x30 is taken as "already DER" without attempting a UTF-8
  /// decode. This mirrors the check the Windows plugin performed.
  static Uint8List? normalizeToDer(Uint8List input) {
    if (input.isEmpty) return null;
    if (input[0] == 0x30) return input;

    final String text;
    try {
      text = utf8.decode(input);
    } on FormatException {
      // Not valid UTF-8, so it cannot be PEM. Pass it through and let the
      // platform certificate parser reject it.
      return input;
    }

    if (!text.contains(_beginMarker)) return input;
    return decodePem(text);
  }

  /// Decodes the first certificate block out of PEM [text]. Returns null when
  /// the markers are missing or malformed, or the body is not valid base64.
  static Uint8List? decodePem(String text) {
    final beginIndex = text.indexOf(_beginMarker);
    if (beginIndex < 0) return null;
    final bodyStart = beginIndex + _beginMarker.length;

    final endIndex = text.indexOf(_endMarker, bodyStart);
    // Guards a malformed PEM where END precedes BEGIN, which underflowed the
    // substring length in the previous C++ implementation.
    if (endIndex < 0) return null;

    final body = text
        .substring(bodyStart, endIndex)
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .replaceAll(' ', '')
        .replaceAll('\t', '');
    if (body.isEmpty) return null;

    try {
      final der = base64.decode(body);
      return der.isEmpty ? null : der;
    } on FormatException {
      return null;
    }
  }

  /// Encodes DER bytes as PEM text, wrapped at 64 characters.
  ///
  /// Used on macOS to write a temporary file for `security add-trusted-cert`,
  /// which only accepts a file path.
  static String encodePem(Uint8List der) {
    final base64Text = base64.encode(der);
    final buffer = StringBuffer('$_beginMarker\n');
    for (var i = 0; i < base64Text.length; i += 64) {
      final end = i + 64 < base64Text.length ? i + 64 : base64Text.length;
      buffer.writeln(base64Text.substring(i, end));
    }
    buffer.writeln(_endMarker);
    return buffer.toString();
  }
}
