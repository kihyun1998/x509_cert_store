# release

## What it is
Shipping the package to pub.dev: the manifest, what the published tarball
contains and excludes, and the consumer-facing documents that travel with each
version.

## Governing decisions
- [ADR-0003](../../adr/0003-where-files-go.md) — which root files are consumer-facing, which are excluded, and that any other root `*.md` must be excluded.
- [ADR-0001](../../adr/0001-sealed-result-type-with-categorical-error-codes.md) — breaking changes ship as a major version with `MIGRATION.md`, no parallel API.

## Design model
- `pubspec.yaml` declares a plain Dart package: `ffi` and `meta` only, no
  Flutter, no plugin platforms. Checked: `pubspec.yaml`.
- `.pubignore` excludes by name — agent docs, `docs/`, `openssl.md`, build
  caches, `.claude/`. Checked: `.pubignore`.
- `README.md`, `CHANGELOG.md`, `MIGRATION.md`, `LICENSE` ship. Library
  doc-comments ship as the pub.dev API docs.
- A published version renders the `CHANGELOG.md` in its own tarball, so a
  published entry can be superseded but never rewritten (old thegraph build,
  2026-09-03).
- W5: `todo.md` shipped in 2.0.2 and was found by opening the tarball, not by
  reading `.pubignore` (ADR-0003).

## Code
- `pubspec.yaml`, `.pubignore`, `README.md`, `CHANGELOG.md`, `MIGRATION.md`, `LICENSE`.

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [public-api](public-api.md) — every document here describes that surface, and its doc-comments are part of what ships.
- [example-app](example-app.md) — the README points consumers at it, and `.pubignore` does not exclude `example/`.
- [verification](verification.md) — CI is the only check behind the Dart-only claim.

## Known holes / open
- `todo.md` is tracked and not excluded by `.pubignore`, so it ships in the next publish — the W5 repeat ADR-0003's last row exists to prevent.
- Nothing checks the built package against `.pubignore`.
- Stale descriptions that ship or are read as identity: the barrel's "A Flutter plugin" (see [public-api](public-api.md)); `GLOSSARY.md`'s **Cross-platform store name**, still mapped "at the native layer".
