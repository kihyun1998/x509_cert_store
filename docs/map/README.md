<!-- grill-map build stamp: 8e5a943 -->
<!-- grill-map synced at: d25bf8e (2026-10-24) -->

# The territory map

A comment's why, trap and measured value go to a note here. Notes are added as
they come up, or all at once with `grill-map`, which also reads hand-written
notes as leads and keeps their paths.

## The two questions

- **If I touch this, what else moves?** Open the territory that owns the code
  and walk its `## Blast radius`, then each note under `## Cross-cutting invariants`.
- **What decision is this shape derived from?** Read the territory's
  `## Governing decisions`. A **None.** there is itself the answer: the shape
  is read from the source and nothing recorded decided it.

`## Blast radius` is a checklist, not a prediction: an edge with nothing to do
for a given change is a correct outcome.

## The system in one paragraph

`x509_cert_store` takes a base64 string, normalizes it to DER and checks that
it parses as a certificate above a single seam, and hands it to a **Platform
backend** that adds the certificate to the
Windows wincrypt store or the macOS keychain over `dart:ffi`, maps the
**Native error code** to an **Error category**, and returns a sealed
`X509Result`. macOS has to re-implement, in Dart, the add dispositions wincrypt
provides natively, and so parses certificate identity from DER itself. The
package is plain Dart and ships to pub.dev. The largest gap: nothing in CI
reaches a real certificate store
([ADR-0002](../adr/0002-the-test-suite-stops-at-the-backend-seam.md)). Failure
category parity has a test for the two mapping tables but not for what each
platform rejects; wincrypt disposition parity is held by reading alone. Both
are violated at the synced commit.

## Territories

- [public-api](territory/public-api.md)
- [input-normalization](territory/input-normalization.md)
- [certificate-fields](territory/certificate-fields.md)
- [backend-seam](territory/backend-seam.md)
- [windows-store](territory/windows-store.md)
- [macos-keychain](territory/macos-keychain.md)
- [macos-trust](territory/macos-trust.md)
- [verification](territory/verification.md)
- [release](territory/release.md)
- [example-app](territory/example-app.md)

## Cross-cutting invariants

- [wincrypt disposition parity](invariant/wincrypt-disposition-parity.md)
- [failure category parity](invariant/failure-category-parity.md)

## Conventions

- Before starting a new note, search this folder and the code symbol for one
  that already holds the fact; a new note is named for what the system does
  there, not for the file.
- Section headings are identical in every note; an empty section says **None.**
- Code is cited by symbol, never by line number.
- A fact another artifact owns is linked, not restated.
- Every claim carries its evidence (a symbol, a record, a commit) or its source
  and date, e.g. `(maintainer, 2026-10-23)`.

## What the map cannot answer

Source files, issues and decision records are text inside notes, not nodes;
the map links to them but does not track their state.

## Scope

A territory appears when something in the repo commits to it — code, a
decision record, an open issue with a design. Out of scope, with the reason:

- `CLAUDE.md`, `GLOSSARY.md`, `docs/agents/`, `docs/adr/` — they describe the
  system and the working process; they are cited from notes, not mapped.
- `openssl.md` — the maintainer's notes on making test certificates; excluded
  from the package.
- Linux support — the README marks it 🔜, and nothing is designed or built; it
  is a line in [backend-seam](territory/backend-seam.md) until something
  commits to it.
