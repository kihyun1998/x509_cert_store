@TestOn('windows')
library;

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:x509_cert_store/src/windows/crypt32.dart';
import 'package:x509_cert_store/src/windows/windows_cert_store.dart';
import 'package:x509_cert_store/x509_cert_store.dart';

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

  _lastErrorSurvivesTheCallBoundary();
}

/// Regression test for the Win32 last-error clobber.
///
/// The bindings are lazily-initialized top-level finals, one copy per isolate.
/// The first read of `getLastError` therefore ran LoadLibrary and
/// GetProcAddress, which succeed and reset the last error to 0 - and that
/// first read was the one immediately after a failed wincrypt call. Every
/// failure collapsed into `X509ErrorCode.unknown` with `nativeCode: 0`, making
/// `alreadyExist` (CRYPT_E_EXISTS), `canceled` (ERROR_CANCELLED), and
/// `accessDenied` (ERROR_ACCESS_DENIED) unreachable. `ensureBindingsResolved`
/// closes that window.
void _lastErrorSurvivesTheCallBoundary() {
  test('a failed wincrypt call reports a non-zero Win32 error', () async {
    // 0xFF 0xFE 0xFD is neither DER nor PEM, so the store opens and
    // CertCreateCertificateContext rejects it. Nothing is written.
    final result = await WindowsCertStore().addCertificate(
      storeName: X509StoreName.my,
      der: Uint8List.fromList([0xFF, 0xFE, 0xFD]),
      addType: X509AddType.addNew,
      setTrusted: false,
    );

    expect(result, isA<X509Failure>());
    final failure = result as X509Failure;
    // The specific crypt error varies across Windows versions; zero is the
    // bug, and it is what an unresolved binding produces.
    expect(failure.nativeCode, isNotNull);
    expect(failure.nativeCode, isNot(0),
        reason: 'GetLastError was clobbered before Dart could read it');
    expect(failure.msg, contains('Win32 error'));
  });
}
