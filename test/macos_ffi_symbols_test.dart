@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:test/test.dart';
import 'package:x509_cert_store/src/macos/core_foundation.dart';
import 'package:x509_cert_store/src/macos/security.dart';

/// Resolves every CoreFoundation and Security symbol the macOS backend calls.
///
/// Under the previous Swift plugin these were compile-time references. With
/// FFI a wrong name fails at runtime on the user's machine, so both the
/// functions and the CFString constants are pinned here. None of these
/// assertions touch the keychain.
void main() {
  test('CoreFoundation symbols resolve', () {
    expect(cfRelease, isNotNull);
    expect(cfRetain, isNotNull);
    expect(cfDataCreate, isNotNull);
    expect(cfDataGetBytePtr, isNotNull);
    expect(cfDataGetLength, isNotNull);
    expect(cfDictionaryCreate, isNotNull);
    expect(cfArrayGetCount, isNotNull);
    expect(cfArrayGetValueAtIndex, isNotNull);
  });

  test('Security symbols resolve', () {
    expect(secCertificateCreateWithData, isNotNull);
    expect(secCertificateCopyData, isNotNull);
    expect(secItemAdd, isNotNull);
    expect(secItemCopyMatching, isNotNull);
    expect(secItemDelete, isNotNull);
  });

  test('CoreFoundation callback tables have addresses', () {
    // These are struct symbols, so the address itself is the value passed to
    // CFDictionaryCreate - a null here would silently build a dictionary that
    // does not retain its entries.
    expect(kCFTypeDictionaryKeyCallBacks, isNot(nullptr));
    expect(kCFTypeDictionaryValueCallBacks, isNot(nullptr));
  });

  test('keychain query constants dereference to live CFStrings', () {
    // Read through a pointer-sized global, so a wrong symbol name yields null
    // rather than an error - assert non-null explicitly.
    expect(kCFBooleanTrue, isNot(nullptr));
    expect(kSecClass, isNot(nullptr));
    expect(kSecClassCertificate, isNot(nullptr));
    expect(kSecValueRef, isNot(nullptr));
    expect(kSecAttrAccessible, isNot(nullptr));
    expect(kSecAttrAccessibleAfterFirstUnlock, isNot(nullptr));
    expect(kSecMatchLimit, isNot(nullptr));
    expect(kSecMatchLimitAll, isNot(nullptr));
    expect(kSecReturnRef, isNot(nullptr));
  });
}
