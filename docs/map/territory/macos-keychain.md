# macos-keychain

## What it is
Adding a certificate to the macOS keychain through the Security framework over
`dart:ffi`: re-implementing the add dispositions wincrypt provides natively,
keeping CoreFoundation object lifetimes right, and turning an `OSStatus` into
an **Error category**.

## Governing decisions
- [ADR-0001](../../adr/0001-sealed-result-type-with-categorical-error-codes.md), amendment for v3.0.0 — the `OSStatus` → `X509ErrorCode` mapping lives here.

## Design model
From the source:
- Runs on a worker isolate (`MacOsCertStore.addCertificate`, `Isolate.run`),
  because the add can raise an authorization prompt.
- Input is rejected as `invalidFormat` twice before any keychain call: by
  `CertificateFields.parse`, then by `secCertificateCreateWithData` returning
  null. The public API already ran the same `parse`, so the first is defence
  in depth.
- The incumbent is found by `_findByIdentity`: every certificate
  `SecItemCopyMatching` returns (`kSecMatchLimitAll`, no keychain
  restriction) is copied out and parsed, and the first (issuer, serial) match
  wins. Any non-success status is treated as "none found".
- Dispositions: `addNew` with an incumbent → `alreadyExist`; `addNewer` → no
  change and success unless strictly newer by `notBefore`, else delete then
  add; `addReplaceExisting` → delete then add. See
  [wincrypt disposition parity](../invariant/wincrypt-disposition-parity.md).
- The add carries no `kSecUseKeychain`, so both `X509StoreName` values land in
  the default keychain (the `MacOsCertStore` doc-comment; README "Platform-specific Behavior").
- Lifetimes: a candidate is `cfRetain`ed before its `CFArray` is released;
  every CF object is released on all paths.
- Mapping (`_categoryFromOSStatus`): `errSecDuplicateItem` → `alreadyExist`,
  `errSecUserCanceled` → `canceled`, `errSecAuthFailed` → `accessDenied`,
  `errSecDecode` → `invalidFormat`, else `unknown` with `nativeCode`.

Input: `_findByIdentity` walks every certificate in the keychain search list on
each add, copying and parsing each one; nothing bounds that count.

## Code
- `lib/src/macos/macos_cert_store.dart` — `MacOsCertStore.addCertificate`, `_addCertificateSync`, `_certStoreAddNew`, `_certStoreAddReplaceExisting`, `_certStoreAddNewer`, `_createCertificate`, `_findByIdentity`, `_fieldsOf`, `_addCertificate`, `_deleteCertificate`, `_createDictionary`, `failureFromOSStatus`, `_categoryFromOSStatus`.
- `lib/src/macos/security.dart` — `secCertificateCreateWithData`, `secCertificateCopyData`, `secItemAdd`, `secItemCopyMatching`, `secItemDelete`, the `kSec*` constants, the `errSec*` values.
- `lib/src/macos/core_foundation.dart` — `cfConstant`, `cfRelease`, `cfRetain`, `cfDataCreate`, `cfDictionaryCreate`, `cfArrayGetCount`, `cfArrayGetValueAtIndex`, `kCFTypeDictionaryKeyCallBacks`, `kCFBooleanTrue`.

## Reference behaviour
- `apple-oss-distributions/Security` — `SecItem.h` for the query keys, `SecBase.h` for the `errSec*` values, which the documentation site does not list. Binding. See [`docs/agents/thegraph.md`](../../agents/thegraph.md).

## Cross-cutting invariants
- [wincrypt disposition parity](../invariant/wincrypt-disposition-parity.md)
- [failure category parity](../invariant/failure-category-parity.md)

## Blast radius
- [certificate-fields](certificate-fields.md) — identity and `notBefore` come from there; a parse change changes which branch runs.
- [macos-trust](macos-trust.md) — it runs only after this returns `X509Success`, against the certificate just added.
- [windows-store](windows-store.md) — the outcome of every disposition, and every category, has to match.
- [verification](verification.md) — this code runs only on the macOS CI job, and only up to symbol resolution.

## Known holes / open
- Delete-then-add is not atomic: if `secItemAdd` fails after `_deleteCertificate` succeeded, the incumbent is gone.
- `todo.md` (2025-08-28, before 3.0.0) records that `replace` does not add when the certificate is in root and not in my. Its platform and whether it still reproduces are unknown (maintainer, 2026-10-23). A candidate here: the incumbent search spans every keychain, the add targets the default one.
- `errSecItemNotFound` is declared and never read; other `SecItemCopyMatching` failures are also read as "none found".
- No bound on the number of keychain certificates parsed per add.
