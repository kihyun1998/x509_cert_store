# failure category parity

## The fact
The same failure condition yields the same `X509ErrorCode` on Windows and
macOS, and `X509Failure.nativeCode` is set only when the category is
`unknown`.

## Why it is cross-cutting
Each platform backend maps its own native error type — a Win32 `DWORD`, an
`OSStatus` — in its own function, and the two never call each other. The
README promises consumers one portable category per failure.
`test/failure_category_parity_test.dart` holds the two mapping tables to one
list of conditions; nothing but this note keeps each backend's early-return
failures, and what each platform's parser rejects, describing the same
conditions.

## Territories it holds in
- [windows-store](../territory/windows-store.md) — `windows_cert_store.dart — failureFromWinError`, `_categoryFromWinError`.
- [macos-keychain](../territory/macos-keychain.md) — `macos_cert_store.dart — failureFromOSStatus`, `_categoryFromOSStatus`, and the `invalidFormat` / `alreadyExist` literals returned before any `OSStatus` exists.
- [backend-seam](../territory/backend-seam.md) — `backend.dart — UnsupportedBackend.addCertificate` returns `unknown` with no `nativeCode`.
- [public-api](../territory/public-api.md) — `x509_cert_store.dart — X509CertStore.addCertificate` turns a thrown exception into `unknown` with no `nativeCode`.
- [input-normalization](../territory/input-normalization.md) — `X509CertStore.addCertificate` rejects DER that `CertificateFields.parse` refuses as `invalidFormat`, so no backend categorizes it.
- [verification](../territory/verification.md) — `test/failure_category_parity_test.dart` holds the two mapping tables to one table of conditions on every host.

## What a violation looks like
A consumer's `switch` takes a different branch for the same input on the two
platforms, or receives a `nativeCode` beside a matched category.

**Closed in 3.0.1 (#26):** bytes that start with `0x30` but are not a
certificate came back `invalidFormat` on macOS and `unknown` with the raw
ASN.1 code on Windows. `X509CertStore.addCertificate` now rejects them with
`CertificateFields.parse` before either backend runs.

**Closed in 3.0.1 (#37):** DER that `CertificateFields.parse` accepted
because it walked only as far as `validity`. With a broken SPKI,
signatureAlgorithm or signatureValue tag, both platforms rejected it, macOS as
`invalidFormat` and Windows as `CRYPT_E_ASN1_BADTAG` → `unknown`; with a broken
subject tag, macOS rejected it and Windows added it. `parse` now checks the
whole structure, and Windows maps the malformed-input ASN.1 codes to
`invalidFormat` (maintainer's choice of both, 2026-10-24, over a mapping alone
and over every context failure as `invalidFormat`).

**Still open:** a certificate that is structurally whole but that one platform
rejects for its content. Not measured on either side.

The `addNewer` same-age case is the same symptom from the other invariant:
[wincrypt disposition parity](wincrypt-disposition-parity.md).

## Discovery history
- CHANGELOG 3.0.0 claims `invalidFormat` is reported identically on every
  platform; that holds for the input rejected above the seam in
  `X509CertStore.addCertificate`, not for input that reaches a backend.
  Found while reading for this map (2026-10-23).

## Where it will recur
Add the condition to `conditions` in `test/failure_category_parity_test.dart`;
the test fails while a category other than `unknown` has no row.

A new native error code mapped on one platform, a new `X509ErrorCode` value,
or a new early return in either backend is subject to this: find the
condition's counterpart on the other platform and map it to the same category.
