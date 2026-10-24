@TestOn('windows')
library;

// TEMPORARY probe for #37 - never merged. Reads winerror.h only.
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('probe #37: winerror.h MessageText for CRYPT_E_ASN1_*', () {
    final root = Directory(r'C:\Program Files (x86)\Windows Kits\10\Include');
    final versions = root.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    final lines =
        File('${versions.last.path}\\shared\\winerror.h').readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final m = RegExp(r'#define\s+(CRYPT_E_ASN1_\w+)\s+(.*)').firstMatch(lines[i]);
      if (m == null) continue;
      final text = <String>[];
      for (var j = i - 1; j >= 0 && j > i - 12; j--) {
        if (lines[j].contains('MessageText:')) break;
        final t = lines[j].replaceFirst(RegExp(r'^//\s?'), '').trim();
        if (t.isNotEmpty) text.insert(0, t);
      }
      print('PROBE37T | ${m.group(1)} | ${m.group(2)!.trim()} | ${text.join(' ')}');
    }
  });
}
