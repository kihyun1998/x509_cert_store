# windows-store

## What it is
Adding a certificate to a Windows system store through wincrypt over
`dart:ffi`, and turning a Win32 failure into an **Error category**.

## Governing decisions
- [ADR-0001](../../adr/0001-sealed-result-type-with-categorical-error-codes.md), amendment for v3.0.0 — the `DWORD` → `X509ErrorCode` mapping lives here.

## Design model
From the source:
- The whole sequence — open store, create context, add, free — runs on a
  worker isolate (`WindowsCertStore.addCertificate`, `Isolate.run`), because
  adding to `ROOT` raises a modal confirmation that blocks the call; dismissing
  it surfaces as `ERROR_CANCELLED`.
- `ensureBindingsResolved` runs before the first real call. The bindings are
  lazy top-level `final`s, and resolving one runs `LoadLibrary` /
  `GetProcAddress`, which succeed and reset the thread-local last error. It
  reads `windowsBindings`, the one list the Windows symbol test also iterates;
  a binding left out of it is resolved on first use and can erase the error it
  was meant to report (its doc-comment records the measurement).
- `getLastError` is read immediately after each failing call.
- Every handle and allocation is released in the `finally` of
  `_addCertificateSync`.
- The store name is `X509StoreName.getString` passed to
  `CertOpenSystemStoreA`; the disposition is `X509AddType.getCode`, passed to
  wincrypt unchanged. `setTrusted` is ignored.
- Mapping (`_categoryFromWinError`): `CRYPT_E_EXISTS` → `alreadyExist`,
  `ERROR_CANCELLED` → `canceled`, `ERROR_ACCESS_DENIED` → `accessDenied`,
  anything else → `unknown` with `nativeCode`. Nothing maps to
  `invalidFormat`.

Input: the DER is copied whole into a native buffer; no size bound.

## Code
- `lib/src/windows/windows_cert_store.dart` — `WindowsCertStore.addCertificate`, `_addCertificateSync`, `failureFromWinError`, `_categoryFromWinError`.
- `lib/src/windows/crypt32.dart` — `certOpenSystemStoreA`, `certCreateCertificateContext`, `certAddCertificateContextToStore`, `certFreeCertificateContext`, `certCloseStore`, `getLastError`, `windowsBindings`, `ensureBindingsResolved`, `certEncodingTypes`, `cryptEExists`, `errorCancelled`, `errorAccessDenied`.

## Reference behaviour
- `wincrypt.h` (10.0.19041.0), the `CertAddCertificateContextToStore` comment block — what each `CERT_STORE_ADD_*` disposition does, including `CRYPT_E_EXISTS` for a not-newer `ADD_NEWER`. Binding.

## Cross-cutting invariants
- [wincrypt disposition parity](../invariant/wincrypt-disposition-parity.md)
- [failure category parity](../invariant/failure-category-parity.md)

## Blast radius
- [macos-keychain](macos-keychain.md) — it imitates this platform's disposition outcomes and must categorize the same failures the same way.
- [verification](verification.md) — `test/windows_ffi_symbols_test.dart` lists the same bindings by hand; a new one is unproven until it is added there.
- [public-api](public-api.md) — the categories reported here are the documented contract.

## Known holes / open
- DER that `CertificateFields.parse` accepts but `CertCreateCertificateContext` rejects returns `unknown`; macOS returns `invalidFormat` — see [failure category parity](../invariant/failure-category-parity.md).
- `addNewer` with a same-age or newer incumbent returns `alreadyExist`; macOS returns success. Undecided (maintainer, 2026-10-23) — see [wincrypt disposition parity](../invariant/wincrypt-disposition-parity.md).
