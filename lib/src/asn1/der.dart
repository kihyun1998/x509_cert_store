import 'dart:typed_data';

/// One DER-encoded TLV (tag-length-value) element, described as a window into
/// the buffer it was read from rather than a copy.
class DerElement {
  /// The identifier octet, e.g. 0x30 for a constructed SEQUENCE.
  final int tag;

  /// Offset of the first content byte.
  final int contentStart;

  /// Length of the content, in bytes.
  final int contentLength;

  /// Offset of the identifier octet, i.e. the start of the whole element.
  final int start;

  /// Length of the whole element: identifier + length octets + content.
  final int totalLength;

  const DerElement({
    required this.tag,
    required this.contentStart,
    required this.contentLength,
    required this.start,
    required this.totalLength,
  });

  /// Offset one past the final byte of this element.
  int get end => start + totalLength;

  /// True when bit 6 of the identifier octet is set, i.e. the content is
  /// itself a sequence of DER elements.
  bool get isConstructed => (tag & 0x20) != 0;

  /// A copy of the content bytes.
  Uint8List contentOf(Uint8List buffer) =>
      Uint8List.sublistView(buffer, contentStart, contentStart + contentLength);

  /// A copy of the whole element, identifier and length octets included.
  ///
  /// X.509 name comparison is defined over the encoded form, so the issuer is
  /// compared as this full element rather than as its content.
  Uint8List bytesOf(Uint8List buffer) =>
      Uint8List.sublistView(buffer, start, end);
}

/// A deliberately small DER reader: enough to walk an X.509 certificate for
/// three fields, and nothing else.
///
/// Every entry point returns null rather than throwing, because the input is
/// untrusted certificate data and a malformed certificate is an expected
/// outcome (reported as `invalidFormat`), not an exceptional one.
abstract final class Der {
  /// Reads the element beginning at [offset], or null when the bytes are not
  /// a well-formed DER element that fits inside [buffer].
  static DerElement? read(Uint8List buffer, int offset) {
    // Identifier octet plus at least one length octet.
    if (offset < 0 || offset + 2 > buffer.length) return null;

    final tag = buffer[offset];
    // High-tag-number form (tag bits all set) is not used anywhere in the
    // certificate structure this reader walks.
    if ((tag & 0x1F) == 0x1F) return null;

    final firstLengthByte = buffer[offset + 1];
    int contentStart;
    int contentLength;

    if (firstLengthByte < 0x80) {
      // Short form: the length octet is the length.
      contentStart = offset + 2;
      contentLength = firstLengthByte;
    } else {
      final lengthByteCount = firstLengthByte & 0x7F;
      // 0x80 is the indefinite form, which BER allows and DER forbids.
      if (lengthByteCount == 0) return null;
      // A length needing more than 4 octets exceeds any certificate we can
      // hold in memory, and guards the accumulator below from overflowing.
      if (lengthByteCount > 4) return null;
      if (offset + 2 + lengthByteCount > buffer.length) return null;

      contentLength = 0;
      for (var i = 0; i < lengthByteCount; i++) {
        contentLength = (contentLength << 8) | buffer[offset + 2 + i];
      }
      contentStart = offset + 2 + lengthByteCount;
    }

    final contentEnd = contentStart + contentLength;
    if (contentEnd > buffer.length) return null;

    return DerElement(
      tag: tag,
      contentStart: contentStart,
      contentLength: contentLength,
      start: offset,
      totalLength: contentEnd - offset,
    );
  }

  /// Reads the direct children of the constructed element [parent].
  ///
  /// Returns null when [parent] is primitive or when any child is malformed
  /// or overruns the parent's content.
  static List<DerElement>? childrenOf(Uint8List buffer, DerElement parent) {
    if (!parent.isConstructed) return null;

    final children = <DerElement>[];
    final contentEnd = parent.contentStart + parent.contentLength;
    var offset = parent.contentStart;

    while (offset < contentEnd) {
      final child = read(buffer, offset);
      if (child == null) return null;
      if (child.end > contentEnd) return null;
      children.add(child);
      offset = child.end;
    }

    return children;
  }
}
