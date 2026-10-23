# public-api

## What it is
The consumer contract: `X509CertStore.addCertificate`, the sealed
`X509Result` it returns, and the three enums that parameterize and categorize
it. Everything exported from `package:x509_cert_store/x509_cert_store.dart`.

## Governing decisions
- [ADR-0001](../../adr/0001-sealed-result-type-with-categorical-error-codes.md) — the sealed `X509Success | X509Failure` result, the five categories, `nativeCode` only for `unknown`, and hard breaking changes under semver with `MIGRATION.md`.

## Design model
From ADR-0001 and the source:
- `addCertificate` is total: every path returns an `X509Result`. Invalid
  base64, empty input and undecodable PEM return `invalidFormat` before the
  backend is reached; anything the backend throws becomes `unknown` with no
  `nativeCode` (`X509CertStore.addCertificate`, the final `catch`).
- `X509StoreName.getString` (`ROOT`/`MY`) is a wincrypt store name; only the
  Windows backend reads it. macOS reads the enum value itself, to choose a
  trust mechanism.
- `X509AddType.getCode` returns wincrypt `CERT_STORE_ADD_*` numbers, which
  both backends consume — see
  [wincrypt disposition parity](../invariant/wincrypt-disposition-parity.md).
- Doc-comments here ship verbatim as the pub.dev API docs.

Input: `certificateBase64` is a caller string with no size bound; it is
decoded whole in memory.

## Code
- `lib/x509_cert_store.dart` — the barrel: `export` directives only.
- `lib/src/x509_cert_store.dart` — `X509CertStore`, `X509CertStore.withBackend`, `X509CertStore.addCertificate`.
- `lib/src/x509_res_result.dart` — `X509Result`, `X509Success`, `X509Failure`.
- `lib/src/x509_store_enums.dart` — `X509StoreName.getString`, `X509ErrorCode`, `X509AddType.getCode`.

## Reference behaviour
**None.**

## Cross-cutting invariants
- [wincrypt disposition parity](../invariant/wincrypt-disposition-parity.md)
- [failure category parity](../invariant/failure-category-parity.md)

## Blast radius
- [input-normalization](input-normalization.md) — the `invalidFormat` cases this API promises are decided there.
- [backend-seam](backend-seam.md) — parameters are forwarded unchanged, so a new parameter or enum value has to cross the interface.
- [windows-store](windows-store.md) — it interprets `getString` and `getCode` as wincrypt values.
- [macos-keychain](macos-keychain.md) — it re-implements what each `getCode` value means.
- [release](release.md) — README, `MIGRATION.md` and `CHANGELOG.md` describe this surface, and an API change is a semver decision.
- [example-app](example-app.md) — it pattern-matches `X509Result` and lists every enum value in its UI.

## Known holes / open
- The library doc-comment on `lib/x509_cert_store.dart` still says "A Flutter plugin", and `X509ErrorCode`'s says the mapping happens "at the native layer"; both stopped being true in 3.0.0 (CHANGELOG 3.0.0) and both ship to pub.dev.
- `X509AddType.addNewer`'s doc-comment says a not-newer certificate "succeeds"; on Windows it returns `alreadyExist` — undecided, see [wincrypt disposition parity](../invariant/wincrypt-disposition-parity.md).
- No bound on the size of `certificateBase64`.
