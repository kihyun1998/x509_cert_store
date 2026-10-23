# input-normalization

## What it is
Turning the caller's base64 string into the DER bytes a backend receives:
base64 decode, the empty check, and PEM-to-DER. It runs above the backend
seam, once, for both platforms.

## Governing decisions
**None.** [ADR-0001](../../adr/0001-sealed-result-type-with-categorical-error-codes.md) decides the result shape this step reports through, not how input is decoded.

## Design model
From the source:
- `Pem.normalizeToDer`: a leading `0x30` is taken as DER and passed through
  unchecked; bytes that are not UTF-8, or UTF-8 with no `BEGIN CERTIFICATE`
  marker, are also passed through; PEM text is decoded with `Pem.decodePem`.
  A `null` return becomes `invalidFormat` in `X509CertStore.addCertificate`.
- `Pem.decodePem` takes the **first** certificate block only; later blocks in
  a bundle are ignored without a report. END before BEGIN, a missing END, an
  empty body and a non-base64 body all return `null`.
- Everything passed through is validated only by the platform, so the
  category it fails with is the backend's — see
  [failure category parity](../invariant/failure-category-parity.md).

Input: no size bound; the decoded buffer and the PEM text are both held whole.

## Code
- `lib/src/pem.dart` — `Pem.normalizeToDer`, `Pem.decodePem`, `Pem.encodePem`.
- `lib/src/x509_cert_store.dart` — `X509CertStore.addCertificate` (the `base64.decode`, empty and `null` checks).

## Reference behaviour
**None.**

## Cross-cutting invariants
- [failure category parity](../invariant/failure-category-parity.md)

## Blast radius
- [windows-store](windows-store.md) — receives pass-through bytes that were never checked as a certificate.
- [macos-keychain](macos-keychain.md) — the same, and its own pre-parse decides `invalidFormat` there.
- [macos-trust](macos-trust.md) — `Pem.encodePem` writes the file `security` reads, and must round-trip through `normalizeToDer`.
- [public-api](public-api.md) — the `invalidFormat` cases are part of the documented contract.

## Known holes / open
- A PEM bundle silently yields only its first certificate.
- No bound on input size.
