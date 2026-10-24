# verification

## What it is
What proves a change works before it ships: the Dart test suite, the
per-platform FFI symbol tests, and the three CI jobs that run them.

## Governing decisions
- [ADR-0002](../../adr/0002-the-test-suite-stops-at-the-backend-seam.md) — the suite stops at the backend seam, and what a green run therefore does not prove.

## Design model
From the source and ADR-0002:
- `test/x509_cert_store_test.dart` drives `X509CertStore.withBackend` with a
  fake; it proves normalization and pass-through, never a platform mapping.
- `test/windows_ffi_symbols_test.dart` and `test/macos_ffi_symbols_test.dart`
  (`@TestOn`) resolve every binding by hand-written list; Windows also calls
  `GetLastError`. A missing symbol is otherwise a runtime failure on a user's
  machine.
- `test/pem_test.dart` and `test/certificate_fields_test.dart` exercise pure
  Dart on any host, against `test/fixtures/test_certificates.dart`.
- CI (`.github/workflows/ci.yml`): one job on a bare Dart SDK with no Flutter —
  format, `dart analyze lib test`, `dart test`, and the published-root-documents
  check (see [release](release.md)) — which is what keeps the package
  Dart-only; one Windows and one macOS job, each running `dart test` and then
  `flutter analyze` and `flutter build` on `example/`.
- The macOS backend runs only on the macOS job; the Windows dev host cannot
  execute it.

## Code
- `test/x509_cert_store_test.dart`, `test/pem_test.dart`, `test/certificate_fields_test.dart`, `test/windows_ffi_symbols_test.dart`, `test/macos_ffi_symbols_test.dart`, `test/fixtures/test_certificates.dart`.
- `.github/workflows/ci.yml` — jobs `analyze-and-test`, `windows`, `macos`.

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [windows-store](windows-store.md) — its symbol test repeats the binding list; the two drift apart silently.
- [macos-keychain](macos-keychain.md) — the same, for Security and CoreFoundation symbols and constants.
- [backend-seam](backend-seam.md) — the fake backend is only as faithful as the interface it implements.
- [release](release.md) — the no-Flutter job is the gate behind the "Dart-only" claim in `pubspec.yaml` and the README.
- [example-app](example-app.md) — the desktop jobs build it, so a public API break fails there too.

## Known holes / open
- `_categoryFromWinError` and `_categoryFromOSStatus` are private and called by no test.
- No test reaches a certificate store; `example/integration_test/` is run by no CI job (ADR-0002).
- [macos-trust](macos-trust.md) is untested.
