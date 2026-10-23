# wincrypt disposition parity

## The fact
For every `X509AddType`, the macOS backend produces the outcome wincrypt's
`CertAddCertificateContextToStore` produces on Windows: the same disposition
numbers (`addNew` 1, `addReplaceExisting` 3, `addNewer` 6), the same identity
(issuer + serial number), the same "newer" test (`notBefore` strictly later),
and the same result when nothing is added.

## Why it is cross-cutting
Windows hands the number to wincrypt and wincrypt does the rest; macOS has no
such API and re-implements each disposition in Dart. The two sites never call
each other and share no primitive beyond the integer `X509AddType.getCode`
returns, so nothing but this note ties the macOS switch to wincrypt's
semantics. Changing either side alone makes the same call behave differently
per platform.

## Territories it holds in
- [public-api](../territory/public-api.md) — `x509_store_enums.dart — X509AddType.getCode` defines the numbers, and `X509AddType`'s doc-comments describe the outcomes.
- [windows-store](../territory/windows-store.md) — `windows_cert_store.dart — _addCertificateSync` passes the number to `certAddCertificateContextToStore` unchanged.
- [macos-keychain](../territory/macos-keychain.md) — `macos_cert_store.dart — _certStoreAddNew`, `_certStoreAddReplaceExisting`, `_certStoreAddNewer` and the `switch (addType)` in `_addCertificateSync`.
- [certificate-fields](../territory/certificate-fields.md) — `certificate_fields.dart — CertificateFields.hasSameIdentityAs` and `notBefore` are macOS's identity and newer test.

## What a violation looks like
The same `addCertificate` call returns a different `X509Result`, or leaves a
different store state, on the two platforms.

**Present at HEAD (60f8c57):** `addNewer` when the stored certificate is the
same age or newer. wincrypt fails with `CRYPT_E_EXISTS` (the
`CERT_STORE_ADD_NEWER` comment in `wincrypt.h`, 10.0.19041.0), which
`_categoryFromWinError` maps to `alreadyExist`; macOS returns `X509Success()`
without touching the keychain, and `X509AddType.addNewer`'s doc-comment says
the operation succeeds. Which one is the contract is not decided
(maintainer, 2026-10-23).

A disposition number outside 1/3/6 matches no `case` in the macOS `switch`,
which has no `default`, and falls through to a plain add.

## Discovery history
- Found while reading for this map: the macOS `addNewer` branch against the
  `CERT_STORE_ADD_NEWER` comment in `wincrypt.h` (2026-10-23).
- The identity rule matches wincrypt's: `wincrypt.h` says
  `CertGetSubjectCertificateFromStore` decides whether the certificate already
  exists, and that function matches on issuer and serial number.

## Where it will recur
Any change to what an `X509AddType` does, a new `X509AddType` value, or a
change to how macOS finds the incumbent certificate is subject to this. Read
the `CertAddCertificateContextToStore` comment block in `wincrypt.h` first;
it is binding (see [`docs/agents/thegraph.md`](../../agents/thegraph.md)).
