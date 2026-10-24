# example-app

## What it is
The Flutter desktop app under `example/` that shows every store name, add type
and result case, and the only place the package runs inside a real Flutter
host. It depends on the package by path and is never published itself.

## Governing decisions
- [ADR-0004](../../adr/0004-msvc-compiled-sources-are-ascii-only.md) — `example/windows/runner/` C++ and CMake stay ASCII-only.

## Design model
From the source:
- `example/pubspec.yaml` depends on `x509_cert_store` by `path: ../` with
  `publish_to: "none"`.
- `_CertificateManagerPageState._handleCertificateResult` switches over
  `X509Result` and names some `X509ErrorCode` values, with a `_` fallback.
- `_CertificateManagerPageState._loadCertificateFromFile` picks a file with
  `FilePicker.pickFile` and reads it with `PlatformFile.readAsBytes`
  (`file_picker` ^13). `file_picker` 12 removed `FilePickerResult` and
  `FilePicker.platform`, which broke the example build when Dependabot raised
  the group (commit e013029, 2026-10-23).
- The macOS entitlements disable the App Sandbox and enable keychain access
  (`example/macos/Runner/*.entitlements`), the setup the README tells
  consumers to copy.
- `example/integration_test/plugin_integration_test.dart` asserts that a
  `ROOT` add without elevation fails and that empty input is
  `invalidFormat`.
- CI builds it on the Windows and macOS jobs; the no-Flutter job skips it with
  `--no-example`.

## Code
- `example/lib/main.dart` — `MyApp`, `CertificateManagerPage`, `_CertificateManagerPageState._addCertificate`, `_CertificateManagerPageState._loadCertificateFromFile`, `_CertificateManagerPageState._handleCertificateResult`.
- `example/integration_test/plugin_integration_test.dart`.
- `example/windows/runner/`, `example/macos/Runner/`.

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [public-api](public-api.md) — it is the one consumer this repo builds, so an API break shows here first.
- [release](release.md) — the README's setup instructions and this app's entitlements describe the same requirement.

## Known holes / open
- The integration test is run by no CI job, and still carries the commented-out `getPlatformVersion` test from the plugin template.
