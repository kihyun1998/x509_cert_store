# backend-seam

## What it is
The interface between the public API and the platform code: which **Platform
backend** runs, what it receives, and how tests substitute one.

## Governing decisions
- [ADR-0001](../../adr/0001-sealed-result-type-with-categorical-error-codes.md), amendment for v3.0.0 — the native-to-category mapping runs inside the per-platform backend.
- [ADR-0002](../../adr/0002-the-test-suite-stops-at-the-backend-seam.md) — the test suite stops here.

## Design model
From the source and ADR-0001's amendment:
- `X509CertStoreBackend.addCertificate` always receives DER; decoding happens
  above it.
- `createPlatformBackend` picks `WindowsCertStore` or `MacOsCertStore` from
  `Platform`, and `UnsupportedBackend` for any other OS. Unsupported returns
  `unknown` rather than throwing.
- `X509CertStore.withBackend` is the test seam; FFI bindings cannot be mocked
  (its doc-comment).

## Code
- `lib/src/backend.dart` — `X509CertStoreBackend`, `createPlatformBackend`, `UnsupportedBackend`.
- `lib/src/x509_cert_store.dart` — `X509CertStore.withBackend`.

## Reference behaviour
**None.**

## Cross-cutting invariants
- [failure category parity](../invariant/failure-category-parity.md)

## Blast radius
- [windows-store](windows-store.md) — implements the interface and relies on DER-only input.
- [macos-keychain](macos-keychain.md) — the same.
- [verification](verification.md) — the fake backend is the whole unit-test strategy.
- [public-api](public-api.md) — constructs the backend and forwards every parameter.

## Known holes / open
- Linux: the README's platform table marks it 🔜; nothing is designed or built, so it is `UnsupportedBackend` today.
