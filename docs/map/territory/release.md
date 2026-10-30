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
- `.pubignore` excludes by name — agent docs, `docs/`, `openssl.md`,
  `todo.md`, build caches, `.claude/`. Checked: `.pubignore`.
- CI's no-Flutter job reads `dart pub publish --dry-run` and fails on any
  root `*.md` other than `README.md`, `CHANGELOG.md` and `MIGRATION.md`. It
  reads what would ship rather than `.pubignore`, because W5 below was a list
  that looked right (ADR-0003, #27). Seen failing on `todo.md` with its
  exclusion removed (2026-10-23).
- `README.md`, `CHANGELOG.md`, `MIGRATION.md`, `LICENSE` ship. Library
  doc-comments ship as the pub.dev API docs.
- Before a release, run `pub-ready`.
- `.github/dependabot.yml` raises the root's constraints with
  `increase-if-necessary`, one PR per dependency. The root commits no
  lockfile, so a PR opens only when a release falls outside the caret — at
  `0.x`, every minor — and each one is a floor decision for consumers, not a
  chore. `example/` and the workflow actions ship nothing, so their PRs come
  grouped, monthly (#24).
- `pubspec.yaml` and `CHANGELOG.md` are at 3.0.1 (maintainer, 2026-10-24),
  while pub.dev's latest is 3.0.0 (pub.dev API, 2026-10-24): the 3.0.1 entry
  is unpublished and can still be edited.
- W5: `todo.md` shipped in 2.0.2 and was found by opening the tarball, not by
  reading `.pubignore` (ADR-0003).

## Code
- `pubspec.yaml`, `.pubignore`, `README.md`, `CHANGELOG.md`, `MIGRATION.md`, `LICENSE`.
- `.github/dependabot.yml`.

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [public-api](public-api.md) — every document here describes that surface, and its doc-comments are part of what ships.
- [example-app](example-app.md) — the README points consumers at it, and `.pubignore` does not exclude `example/`.
- [verification](verification.md) — CI is the only check behind the Dart-only claim.

## Known holes / open
- `MIGRATION.md`'s 2.0.0 table still says the mapping "happens at the native layer"; a published migration guide is left as written.
