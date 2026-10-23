# macos-trust

## What it is
Marking a just-added certificate as trusted on macOS when `setTrusted` is
true, by running `/usr/bin/security add-trusted-cert`, elevated through
`osascript` for `X509StoreName.root`.

## Governing decisions
**None.** `CLAUDE.md` § Seams states the best-effort rule as a contract, not a defect; no decision record covers it.

## Design model
From the source:
- Runs only when the add returned `X509Success` and `setTrusted` is true
  (`MacOsCertStore.addCertificate`).
- Best effort: every error is swallowed, and the operation's result is the
  add's result (`applyTrust` doc-comment). A trust failure is never reported.
- `security add-trusted-cert` takes only a file path, so the DER is written as
  PEM (`Pem.encodePem`) to a fresh temp directory, deleted afterwards.
- `root`: elevated through `osascript` with `-k /Library/Keychains/System.keychain`;
  if that fails, the unelevated command runs. `my`: unelevated only.
- Both invocations pass `-d -r trustRoot` and the policies `ssl`, `smime`,
  `codeSign`, `basic` (`_trustArguments`).
- The elevated script is one `osascript -e` argument; the PEM path is
  single-quoted inside it.

## Code
- `lib/src/macos/trust.dart` — `applyTrust`, `_trustArguments`, `_addTrustedCert`, `_addTrustedCertElevated`.
- `lib/src/pem.dart` — `Pem.encodePem`.

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [macos-keychain](macos-keychain.md) — trust assumes the certificate it marks is the one that add just placed.
- [input-normalization](input-normalization.md) — `Pem.encodePem` must stay the inverse of `Pem.normalizeToDer`.
- [release](release.md) — the README's macOS section describes this behaviour to consumers.

## Known holes / open
- The README says `my` "requests trust as the current user"; both invocations pass `-d`, the admin trust domain. Which one is right was not checked against `security(1)`.
- A temp path containing a single quote would break the elevated script's quoting; the path comes from `Directory.systemTemp`.
- Neither `security` nor `osascript` is tested anywhere — see [verification](verification.md).
