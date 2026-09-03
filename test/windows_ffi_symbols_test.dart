@TestOn('windows')
library;

import 'package:test/test.dart';
import 'package:x509_cert_store/src/windows/crypt32.dart';

/// Resolves every wincrypt symbol the Windows backend calls.
///
/// Under the previous C++ plugin a misspelled or missing API was a link
/// error. With FFI it is a runtime `ArgumentError` on the user's machine, so
/// the loads are pinned here instead. Reading the bindings is enough: each is
/// a lazily-initialized top-level `final` that opens the library and performs
/// the lookup on first access.
void main() {
  test('crypt32 and kernel32 symbols resolve', () {
    expect(certOpenSystemStoreA, isNotNull);
    expect(certCreateCertificateContext, isNotNull);
    expect(certAddCertificateContextToStore, isNotNull);
    expect(certFreeCertificateContext, isNotNull);
    expect(certCloseStore, isNotNull);
    expect(getLastError, isNotNull);
  });

  test('GetLastError is callable and returns a DWORD', () {
    // Side-effect-free, and proves the resolved pointer is actually invocable
    // rather than merely non-null.
    expect(getLastError(), isA<int>());
  });
}
