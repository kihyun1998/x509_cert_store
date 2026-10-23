# x509_cert_store

A plain Dart package that adds X.509 certificates to the Windows and macOS
certificate stores over `dart:ffi`.

## Agent docs

| When | Read |
|---|---|
| opening, reading, commenting on or labelling an issue | `docs/agents/issue-tracker.md` |
| a skill names a triage role | `docs/agents/triage-labels.md` — role → label string |
| before exploring an area | `GLOSSARY.md` and the `docs/adr/` records touching it — `docs/agents/domain.md` |

## Map

The territory map is [`docs/map/README.md`](docs/map/README.md).

- **Read before the change** — before designing one (`read-it`), open the
  territory that owns the code, walk its blast radius and its invariants.
- **Write after it lands** — once the change is complete (`sweep`), update
  the notes it made false.
- **Promotion, at the first fix.** When a fix reveals a fact, ask: does this
  hold at every site that shares the same assumption? If yes, the fix lands
  with an invariant note under `docs/map/invariant/`.

## Comments

A comment says what the code is. Why it is this way, what it deliberately
leaves out, the trap and the measured value go to the territory note under
`docs/map/`; a new note follows `docs/map/README.md` § Conventions. History
goes to the commit message. Before deleting a comment, move whatever the map
does not yet hold into it (`decant`).

## Seams

- **Core:** the native-error → `X509ErrorCode` mapping. It lives in each
  platform backend (`lib/src/windows/`, `lib/src/macos/`), right after the FFI
  call that produced the `DWORD` / `OSStatus` — never above the backend seam
  (ADR-0001, amendment).
- **The seam:** `X509CertStoreBackend` (`lib/src/backend.dart`). Policy crosses
  it as arguments — store (`X509StoreName`), addition behaviour
  (`X509AddType`), `setTrusted` — and the core is agnostic to all three. Input
  normalization (base64, PEM → DER) happens above it.
- **The consumer owns:** the reaction to each `X509ErrorCode` — retry, an
  elevation prompt, a fallback store; the package decides none of them — and
  base64-encoding the certificate.
- **Contracts, not defects.** A report against either is a request to change
  the contract:
  - on macOS a trust failure after a successful add is swallowed; the
    certificate stays added.
  - `setTrusted` is ignored on Windows.
