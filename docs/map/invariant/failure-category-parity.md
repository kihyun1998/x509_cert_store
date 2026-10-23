# failure category parity

## The fact
The same failure condition yields the same `X509ErrorCode` on Windows and
macOS, and `X509Failure.nativeCode` is set only when the category is
`unknown`.

## Why it is cross-cutting
Each platform backend maps its own native error type — a Win32 `DWORD`, an
`OSStatus` — in its own private function, and the two never call each other.
The README promises consumers one portable category per failure; nothing but
this note keeps the two mapping tables, and each backend's early-return
failures, describing the same conditions.

## Territories it holds in
- [windows-store](../territory/windows-store.md) — `windows_cert_store.dart — _failure`, `_categoryFromWinError`.
- [macos-keychain](../territory/macos-keychain.md) — `macos_cert_store.dart — _failure`, `_categoryFromOSStatus`, and the `invalidFormat` / `alreadyExist` literals returned before any `OSStatus` exists.
- [backend-seam](../territory/backend-seam.md) — `backend.dart — UnsupportedBackend.addCertificate` returns `unknown` with no `nativeCode`.
- [public-api](../territory/public-api.md) — `x509_cert_store.dart — X509CertStore.addCertificate` turns a thrown exception into `unknown` with no `nativeCode`.
- [input-normalization](../territory/input-normalization.md) — what it passes through unvalidated is what each platform then categorizes on its own.

## What a violation looks like
A consumer's `switch` takes a different branch for the same input on the two
platforms, or receives a `nativeCode` beside a matched category.

**Present at HEAD (60f8c57):** bytes that start with `0x30` but are not a
certificate. `Pem.normalizeToDer` passes them through as DER. macOS rejects
them in `CertificateFields.parse` and returns `invalidFormat`. Windows has no
pre-parse: `certCreateCertificateContext` fails with an ASN.1 error that
`_categoryFromWinError` does not map, so the result is `unknown` with the raw
code. Recorded as a bug (maintainer, 2026-10-23).

The `addNewer` same-age case is the same symptom from the other invariant:
[wincrypt disposition parity](wincrypt-disposition-parity.md).

## Discovery history
- CHANGELOG 3.0.0 claims `invalidFormat` is reported identically on every
  platform; that holds for the input rejected above the seam in
  `X509CertStore.addCertificate`, not for input that reaches a backend.
  Found while reading for this map (2026-10-23).

## Where it will recur
A new native error code mapped on one platform, a new `X509ErrorCode` value,
or a new early return in either backend is subject to this: find the
condition's counterpart on the other platform and map it to the same category.
