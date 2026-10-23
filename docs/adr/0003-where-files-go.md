---
status: accepted
---

# Where files go

Authored against the peer set in `docs/agents/thegraph.md`. The rows for the
`windows/` and `macos/` plugin layers went with them in 3.0.0.

| Path | Owns |
|---|---|
| `lib/x509_cert_store.dart` | the only public barrel — `export` directives only, no declarations |
| `lib/src/**.dart` | every implementation file; not imported by consumers directly |
| `test/**.dart` | unit tests for `lib/` |
| `example/**` | the host application |
| `docs/adr/NNNN-*.md` | decision records |
| `docs/agents/*.md` | agent skill bindings |
| `README.md`, `CHANGELOG.md`, `MIGRATION.md`, `LICENSE` | consumer-facing, published to pub.dev |
| `CLAUDE.md`, `GLOSSARY.md` | agent- and maintainer-facing, at the root by declaration, excluded from the package |
| any other `*.md` at the root | **no owner** — scratch, and must be excluded in `.pubignore` |

The last row exists because `todo.md` shipped to pub.dev in 2.0.2 with a note
about an unfixed bug. It was found by opening the published tarball in the pub
cache; reading `.pubignore` showed a list that looked well managed.
