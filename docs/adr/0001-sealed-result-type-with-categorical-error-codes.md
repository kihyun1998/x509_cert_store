---
status: accepted
---

# Sealed Result type for v2.0.0, with categorical X509ErrorCode

Replace `X509ResValue` with a sealed hierarchy `X509Result` → `X509Success | X509Failure`, where `X509Failure` carries a categorical `X509ErrorCode` enum (`canceled`, `alreadyExist`, `accessDenied`, `invalidFormat`, `unknown`), a `msg`, and a nullable `nativeCode: int?` for unmapped-failure diagnostics. The native layer (Windows + macOS plugins) owns the mapping from platform-specific error codes (Win32 `DWORD` / Security framework `OSStatus`) to the enum; the public Dart API exposes only categories, never raw native codes (except via `nativeCode` for failures bucketed as `unknown`).

This is a hard breaking change shipped as v2.0.0 with no parallel API, no deprecation release, no compatibility shim — justified by (a) the type-safety win, since exhaustive pattern matching prevents the silent-comparison-failure bug class that motivated v2.0.0 (see #2), (b) the plugin's small consumer base where churn cost is low, and (c) semver protection on pub.dev plus a dedicated `MIGRATION.md` adequately serving consumers who do migrate. ADR status moves to `accepted` when issue #3 is closed with an accept decision.

## Amendment (v3.0.0, issue #22)

One premise above is no longer true: "the native layer (Windows + macOS plugins) owns the mapping". v3.0.0 replaced both native plugins with `dart:ffi`, so there is no native layer. The mapping from a Win32 `DWORD` or a Security framework `OSStatus` to `X509ErrorCode` now runs in Dart, inside the per-platform backend, immediately after the FFI call that produced the value.

The decision itself stands unchanged, and the migration strengthened rather than weakened it:

- The public contract is identical. Consumers still receive only categories, plus `nativeCode` for failures bucketed as `unknown`.
- The reason the mapping was pushed down to the native layer in the first place — only the native code could see the raw platform error — no longer applies, because the FFI call site *is* Dart.
- The wire contract this ADR implied (category keys duplicated as strings across `x509_cert_store_categories.h`, `CategoryKeys.swift`, and `_CategoryKeys`, the duplication that issue #9 centralized but could not remove) is gone. `X509ErrorCode` is now the single representation, so a category can no longer drift between the three layers.
