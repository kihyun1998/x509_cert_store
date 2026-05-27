---
status: accepted
---

# Sealed Result type for v2.0.0, with categorical X509ErrorCode

Replace `X509ResValue` with a sealed hierarchy `X509Result` → `X509Success | X509Failure`, where `X509Failure` carries a categorical `X509ErrorCode` enum (`canceled`, `alreadyExist`, `accessDenied`, `invalidFormat`, `unknown`), a `msg`, and a nullable `nativeCode: int?` for unmapped-failure diagnostics. The native layer (Windows + macOS plugins) owns the mapping from platform-specific error codes (Win32 `DWORD` / Security framework `OSStatus`) to the enum; the public Dart API exposes only categories, never raw native codes (except via `nativeCode` for failures bucketed as `unknown`).

This is a hard breaking change shipped as v2.0.0 with no parallel API, no deprecation release, no compatibility shim — justified by (a) the type-safety win, since exhaustive pattern matching prevents the silent-comparison-failure bug class that motivated v2.0.0 (see #2), (b) the plugin's small consumer base where churn cost is low, and (c) semver protection on pub.dev plus a dedicated `MIGRATION.md` adequately serving consumers who do migrate. ADR status moves to `accepted` when issue #3 is closed with an accept decision.
