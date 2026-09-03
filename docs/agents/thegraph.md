# thegraph — the compiled graph for x509_cert_store

Built by `/grill-the-graph`. This document carries **this project's data only**;
every method it feeds lives in `thegraph` or a sibling skill and is deliberately
not restated here.

- **Build stamp:** `thegraph@50664f1133e6` (sha256 prefix of `SKILL.md` +
  `NODES.md` + `BUILD_CONTRACT.md`, concatenated in that order)
- **Built:** 2026-09-03
- **Input:** the repository itself. No `docs/agents/theflow.md` has ever existed
  here, so every slot below was compiled from source or asked, never carried
  over from bindings.

---

## Contents

- [Node roster](#node-roster)
- [Per-node data](#per-node-data)
- [Boundary rule](#boundary-rule)
- [Tie-breaker](#tie-breaker)
- [Deliberate-divergence list](#deliberate-divergence-list)
- [Areas already carrying a decision record](#areas-already-carrying-a-decision-record)
- [Tracker capability](#tracker-capability)
- [Extraction plan](#extraction-plan)
- [War-story index](#war-story-index)
- [Slot authority map](#slot-authority-map)
- [Compile notes and build gaps](#compile-notes-and-build-gaps)

---

## Node roster

| Node | Instances | Settled by |
|---|---|---|
| `classify` | 1 | catalog |
| `spine` | 1 | catalog; roster is a relation — see [Tracker capability](#tracker-capability) |
| `map` | **none** | No territory map exists. `CONTEXT.md` is a glossary, not a map; the `CODE.md` named in `.pubignore` is not committed. The tree is small enough to be its own map. |
| `reference` | 1 per source class — the classes are listed below | asked |
| `enumerate` | 1 | catalog |
| `boundary` | 1 | catalog |
| `place` | 1 | catalog — every repo has a tree |
| `implement` | 1 per layer | `pubspec.yaml` `flutter.plugin.platforms` + `lib/` |
| `proof` | 1 per layer | same |
| `verify` | 1, **+1 refuter** | the sacred-path list below is non-empty |
| `sweep` | 1, fanning out per surface | catalog |
| `gate` | 1 | catalog |
| `search` | once per candidate | catalog |
| `batch` | 1 or more | catalog |
| `stop` / `decide` | edge-triggered | catalog |
| `promote` | 1 | `docs/adr/` carries a real record format — numbered filename, `status:` frontmatter |
| `downstream` | 1 | the package publishes to pub.dev |

**The layers** are `lib/` (Dart), `windows/` (C++), `macos/` (Swift). One
`implement` and one `proof` node each.

---

## Per-node data

### `reference` — source classes

| Class | Reached by | Summarized? | Routing key (`change_type`) |
|---|---|---|---|
| Win32 / wincrypt API | `C:/Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/um/wincrypt.h` on the dev host | **no — raw** | change touches `windows/` |
| Apple Security / Keychain Services | `apple-oss-distributions/Security` via `raw.githubusercontent.com` — `SecItem.h`, `SecBase.h`, `SecCertificate.h` | **no — raw**. `developer.apple.com` is a summarized fallback and is marked as such when used | change touches `macos/` |
| Flutter plugin + method-channel contract | the Flutter SDK on the dev host (`flutter` resolves to `D:/flutter/bin/flutter`; read `packages/flutter/lib/src/services/` and the Windows C++ wrapper headers) | **no — raw** | change touches `lib/` or the channel |
| Peer desktop plugins | the pub cache at `%LOCALAPPDATA%/Pub/Cache/hosted/pub.dev/`, and `D:/github/flutter_alone` | **no — raw** | change touches layout or public API shape |

**The confirmed peer set** (names only — their trees are read again when acted
on, never stored here): `url_launcher_windows`, `path_provider_foundation`,
`flutter_secure_storage_macos`, `flutter_secure_storage_windows`,
`window_manager`, `flutter_alone`.

`errSec*` constant values exist only in `SecBase.h` and are absent from the
documentation site — which is why the Apple class is raw rather than summarized.

### `proof` — method per layer, and this project's tautological traps

| Layer | Proof command | Tautological trap |
|---|---|---|
| `lib/` (Dart) | `flutter test` at the repo root | The suite mocks the method channel. It can prove the Dart-side category mapping and **nothing** about whether the native layer actually emits that key. A green Dart run says nothing about the wire. |
| `windows/` (C++) | `ctest --test-dir plugins/x509_cert_store -C Debug --output-on-failure`, run from `example/build/windows/x64` with `runner/Debug` on `PATH` | Every test returns from a guard **before** touching wincrypt. The store interaction — the part that can install a wrong root CA — is untested by construction. |
| `macos/` (Swift) | `xcodebuild test -workspace macos/Runner.xcworkspace -scheme Runner -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO`, run from `example/` | Same hermetic ceiling: all cases fail an argument guard or certificate parsing before keychain access. Additionally it **cannot run on the dev host at all**, so red is only visible after a push. |

### `verify` — sacred paths

A change touching any of these fires `verify` unconditionally and buys the
refuting second lens.

```
macos/Classes/SystemKeyChain.swift
macos/Classes/LoginKeyChain.swift
macos/Classes/KeyChainProtocol.swift
windows/x509_cert_store_plugin.cpp
lib/src/x509_cert_store_method_channel.dart
windows/x509_cert_store_categories.h
macos/Classes/CategoryKeys.swift
```

Three groups, and the reason each is here:

1. **Trust and privilege escalation** — `SystemKeyChain.swift` and
   `LoginKeyChain.swift` shell out to `security` and elevate via AppleScript.
2. **Destructive and root-store** — `KeyChainProtocol.swift` deletes an existing
   certificate on the replace/newer flow; `x509_cert_store_plugin.cpp` installs
   into the Windows `ROOT` store.
3. **The hand-synced wire contract** — three files holding the same five
   category-key strings, kept in agreement by hand. Drift collapses a category to
   `unknown` silently.

### `sweep` — surfaces

| Surface | How it is read |
|---|---|
| `README.md` | API reference and platform-behaviour sections |
| `MIGRATION.md` | before/after examples per usage pattern |
| `CHANGELOG.md` | append at top under the version heading |
| `CONTEXT.md` | glossary terms and their `_Avoid_` lists |
| `docs/adr/NNNN-*.md` | amend a record whose premise the change falsified |
| `lib/**/*.dart` doc-comments | these ship verbatim to pub.dev API docs |
| the three wire-contract files' own comments | each names the other two as the thing to keep in sync |
| `pubspec.yaml` | `description`, `version`, `topics` |
| `example/lib/main.dart` | the demonstrated usage |

**Changelog snapshotting at publish: yes.** Every pub.dev version renders the
`CHANGELOG.md` shipped in that tarball, so a published entry is frozen and can
only be superseded, never rewritten.

**Glossary:** `CONTEXT.md` at the repo root. **Decision records:** `docs/adr/`.
Both declared in `CLAUDE.md` and `docs/agents/domain.md`.

### `place` — tree rule

Concrete paths, matchable against a diff.

| Path | Owns |
|---|---|
| `lib/x509_cert_store.dart` | the only public barrel — `export` directives only, no declarations |
| `lib/src/**.dart` | every Dart implementation file; not imported by consumers directly |
| `test/**.dart` | Dart unit tests for `lib/` |
| `windows/*.cpp`, `windows/*.h` | Windows native implementation and the C-API shim |
| `windows/include/x509_cert_store/*.h` | the Windows public header the host app consumes |
| `windows/test/*.cpp` | Windows native unit tests (gtest) |
| `windows/CMakeLists.txt` | the Windows build and test target |
| `macos/Classes/*.swift` | macOS native implementation |
| `macos/Resources/*` | macOS bundle resources |
| `macos/x509_cert_store.podspec` | the macOS package manifest |
| `example/lib/**` | the host application |
| `example/integration_test/*.dart` | on-device integration tests |
| `example/macos/RunnerTests/*.swift` | macOS native unit tests (XCTest) — see the divergence list |
| `docs/adr/NNNN-*.md` | decision records |
| `docs/agents/*.md` | agent skill bindings |
| `README.md`, `CHANGELOG.md`, `MIGRATION.md`, `LICENSE` | consumer-facing, published to pub.dev |
| `CLAUDE.md`, `CONTEXT.md` | agent- and maintainer-facing, at the root by declaration, excluded from the package |
| any other `*.md` at the repo root | **no owner** — scratch, and must be excluded in `.pubignore` |

Its prior art is the `reference` peer class above and its exceptions are in the
divergence list; neither gets a second home here.

### `gate` — command list

**Authoritative source: `.github/workflows/ci.yml`.** The list is not restated
here as a count; the generated gate runner reads that file and asserts against
it in both directions.

Each command is invoked **bare** — never piped — because a pipeline's exit
status is the last command's.

**Measured blind spots:**

1. `example/integration_test/plugin_integration_test.dart` is **executed by no CI
   job**. It exists, reads as coverage, and proves nothing.
2. **No formatter or linter covers C++ or Swift.** `dart format` reaches only
   Dart; `windows/*.cpp` and `macos/Classes/*.swift` have no format gate at all.
3. **Host versus target:** the macOS job is the only thing that can run the Swift
   layer. The dev host is Windows, so macOS red is invisible until a push.
4. The Windows gtest target only builds when the **example app** builds — the
   plugin cannot be tested standalone, because `include_x509_cert_store_tests` is
   set by the example's own CMakeLists.
5. **Nothing gates what actually ships.** `.pubignore` is never checked against
   the built package. See war story W5.

**Not a blind spot, measured:** the root `flutter analyze` *does* reach
`example/lib/`. A deliberate type error placed there was reported by the root
invocation. This was assumed to be a blind spot during the build and the
assumption was false.

### `search` — areas already carrying a record

See [Areas already carrying a decision record](#areas-already-carrying-a-decision-record).
`search` reads `docs/adr/*.md` — the **record files**, never an index.

### `downstream`

The package publishes to **pub.dev** as `x509_cert_store`. The link mechanism to
consumers is semver plus `CHANGELOG.md`, with `MIGRATION.md` carrying the
before/after for the 1.x → 2.0.0 break. Consumers are derived on the spot when
`downstream` runs and are never stored here.

---

## Boundary rule

**Mechanism** — the native-error-code → category mapping. Only a layer holding
the Win32 `DWORD` or the `OSStatus` can be correct about what a failure means, so
the mapping lives in `windows/x509_cert_store_categories.h` and
`macos/Classes/`, never in Dart.

**Policy, injected across the seam** — which store (`X509StoreName`), which
addition behaviour (`X509AddType`), whether to request trust (`setTrusted`), and
how to react to each category. The core is agnostic to all four.

**The seam** — method channel `io.github.kihyun1998/x509_cert_store`, method
`addCertificate`, arguments `{storeName: String, certificate: Uint8List,
addType: int, setTrusted: bool}`. Success is `true`; failure is a
`PlatformException` whose `code` is one of the five category keys and whose
`details` may carry `nativeCode: int`.

**What the consumer owns by definition** — the reaction to an `X509ErrorCode`.
Retry, an elevation prompt, a fallback store: the plugin decides none of them.
The consumer also owns the base64 encoding; Dart owns the decode, and a
`FormatException` there becomes `invalidFormat` without ever reaching native.

**Contracts, not defects.** A report against either of these is a request to
change the contract, and treating it as a bug deletes the contract:

- `setTrusted` failure is deliberately swallowed on the add path
  (`macos/Classes/KeyChainProtocol.swift:86`, documented at lines 13–15). The
  certificate is added even when trust application fails.
- `setTrusted` is ignored entirely on Windows, documented on
  `X509CertStorePlatform.addCertificate`.

---

## Tie-breaker

**This project's own measurement wins over prior art.**

The one carve-out: what a platform API *does* is a fact rather than prior art. A
local measurement contradicting `wincrypt.h` or `SecBase.h` means the probe is
wrong or the environment differs — investigate, never override.

Precedents are W1 and W4 in the war-story index.

---

## Deliberate-divergence list

Project-scoped entries. A run's `human` calls are co-authored by the issue and
arrive separately.

| Divergence | Reason | Record |
|---|---|---|
| Hard breaking change with no parallel API, no deprecation release, no shim; and the native layer owns the error mapping so Dart never sees raw native codes | Type-safety win against the silent-comparison bug class, a small consumer base, and semver plus `MIGRATION.md` serving those who migrate | `docs/adr/0001-sealed-result-type-with-categorical-error-codes.md`, issue #3 |
| `windows/` C++ and CMake sources are ASCII-only, where peers use non-ASCII freely | On a Korean Windows host (CP949) MSVC raises `C4819` and Flutter's default `/WX` escalates it to `C2220`, breaking the build for every downstream app | `CHANGELOG.md` 2.0.1 — no ADR |
| Not federated — one package serves both Windows and macOS, where first-party Flutter splits per platform | Two platforms and a small surface; splitting triples release overhead for no consumer benefit. Matches `window_manager` and `flutter_alone` | this document |
| macOS native tests live in `example/macos/RunnerTests/`, where `path_provider_foundation` keeps them in-plugin | The Windows dev host cannot build macOS Swift, so CI's `xcodebuild` from `example/` is the only verification path and it works against this placement. The first-party layout needs podspec and Xcode target rewiring that cannot be verified locally | this document |
| `docs/adr/` and `docs/agents/` exist at all — no peer keeps in-repo decision records | The repo is driven by agent skills that read those exact paths | `CLAUDE.md` |

### Unclassified — reported, not resolved

Nobody has decided these. They stay visible rather than being settled by
majority.

- **U1** — macOS uses the classic CocoaPods `macos/Classes/` layout.
  `path_provider_foundation` and `window_manager` have moved to Swift Package
  Manager (`macos/<name>/{Package.swift,Sources/}`);
  `flutter_secure_storage_macos` and `flutter_alone` have not.
- **U2** — the wire contract is hand-authored and hand-synced across three files.
  Both first-party peers generate theirs from `pigeons/messages.dart`. Issue #9
  centralized the keys but no record rejects pigeon. **This is why sacred-path
  group 3 exists**, which is precisely why it was not promoted to a deliberate
  divergence during this build.
- **U3** — `windows/CMakeLists.txt` defines the test target inline;
  `flutter_alone` splits it into `windows/test/CMakeLists.txt`.

---

## Areas already carrying a decision record

Compiled from the **record files** in `docs/adr/`, not from any index — there is
no index here, and a roster compiled from one drifts.

| Number | Area | Status |
|---|---|---|
| 0001 | Sealed result type with categorical error codes — the `X509Result` / `X509ErrorCode` design and native ownership of the mapping | accepted |

No record is currently `proposed`. The next number to allocate is read from the
directory at allocation time, never carried in a list.

---

## Tracker capability

**GitHub sub-issues are available**: a parent/child relation exists. Measured
2026-09-03 against `kihyun1998/x509_cert_store` via the GraphQL `subIssues` and
`parent` fields on `Issue`, both of which resolved.

So the follow-up tree and the anchor's roster are **relations**, not prose, and
no reconciliation step is needed at a flush.

This fact is outside the repository and therefore **unassertable** by a local
check. The measurement date above is the guard.

---

## Extraction plan

**Script language: Python.** It runs on all three CI runners with no toolchain
step, and keeping the scripts out of Dart keeps them out of the published
package — the failure mode W5 records.

**Location:** `.claude/scripts/` and `.claude/agents/`, both added to
`.pubignore`.

### Generated agents

| Artifact | Node | Carries |
|---|---|---|
| `reference-fetcher` | `reference` | the four source classes, how each is reached, and which are summarized |
| `gap-lens` | `verify` | corpora paths · the tie-breaker · the deliberate-divergence list |
| `refute-lens` | `verify` (2nd) | the same material, opposing stance in the brief |
| `surface-sweeper` | `sweep` | the surface list and how each is read |

Every one of these is **read-only by default**. None carries a write-capable
tool, and no brief declares a command, so none is licensed one.

### Generated scripts

| Artifact | Node | Asserts |
|---|---|---|
| `gate_runner.py` | `gate` | every command in `ci.yml`, invoked bare |
| `trigger_check.py` | `verify` guard | the sacred-path list against the diff |
| `tree_rule_check.py` | `place`, and `gate` on the final diff | the tree rule against the changed paths |
| `cluster_router.py` | `search` | the tracker query by artifact |
| `slot_authority_check.py` | every derived slot | the slot-to-authority map below, both directions |
| `agent_grant_check.py` | the extraction plan itself | that no agent under `.claude/agents/` holds a write-capable tool without a `**Runs:**` declaration naming it |

`slot_authority_check.py` and `agent_grant_check.py` join the `gate` command
list like any other check.

---

## War-story index

Concrete precedents. These are what keep the rules above from reading as
abstractions.

- **W1 — non-ASCII broke every downstream build.** Em-dashes in `windows/`
  comments raised `C4819` on a CP949 host, escalated to `C2220` by `/WX`, and
  broke the build for anyone depending on the plugin. Fixed in 2.0.1. *Feeds the
  tie-breaker and the ASCII divergence.*
- **W2 — an empty certificate caused an out-of-bounds read.** Empty base64
  decoded to an empty byte vector and was dereferenced. Issue #7, fixed in 2.0.2,
  now a regression test in `windows/test/`. *Feeds the sacred-path list.*
- **W3 — a `CFError` leaked on every macOS failure path** in
  `isNewerCertificate`. Issue #10. *Feeds the sacred-path list.*
- **W4 — `hasError()` silently failed across platforms** because Windows never
  mapped its error codes. This is the bug class that motivated the whole of
  v2.0.0. Issue #2, ADR-0001. *Feeds the tie-breaker and the boundary rule.*
- **W5 — `todo.md` shipped to pub.dev in 2.0.2**, carrying a Korean note about an
  unfixed replace bug. `.pubignore` excludes `openssl.md`, `CLAUDE.md`,
  `CONTEXT.md` and `docs/` by name and never mentioned `todo.md`. Found by
  opening the published tarball in the pub cache, **not** by reading
  `.pubignore` — which would have shown a file list that looked well managed.
  *Feeds gate blind spot 5 and the tree rule's last row.*
- **W6 — a green macOS suite that proved nothing.** The template `RunnerTests`
  called `getPlatformVersion`, a method this plugin never implemented. It passed.
  Replaced in `d3b414b`. *This is the tautological-proof trap, already realised
  once in this repo.*
- **W7 — a blind spot that was not there.** This build assumed the root
  `flutter analyze` missed `example/` and was about to record it. A deliberate
  type error planted in `example/lib/` was reported by the root invocation. *A
  blind spot nobody tested is a claim, not a fact.*

---

## Slot authority map

Every derived slot is a **copy**. A copy is never empty — it fails by being
silently wrong — so each one names the fact it was copied from, and
`slot_authority_check.py` asserts each in both directions. Slots marked
unassertable announce themselves; a slot that says nothing is indistinguishable
from a checked one.

| Slot | Authority | Assertable |
|---|---|---|
| layer count → `implement` / `proof` instances | `pubspec.yaml` → `flutter.plugin.platforms`, plus `lib/` | yes |
| `gate` command list | `.github/workflows/ci.yml` | yes, both directions |
| `sweep` surface list | the surface files themselves | yes — existence |
| `place` tree rule (local paths) | the directory tree | yes |
| record roster | `docs/adr/*.md` — the files | yes |
| sacred-path list — **existence** of each path | the files themselves | yes (the *choice* of paths is decided and has no authority) |
| proof commands per layer | `.github/workflows/ci.yml` | yes |
| triage labels | `gh label list` | yes, but remote — see build gaps |
| `downstream` target | `pubspec.yaml` → `homepage` / `repository` | yes |
| glossary and record locations | `CLAUDE.md`, `docs/agents/domain.md` | yes |
| tracker parent/child capability | GitHub GraphQL `Issue.subIssues` / `Issue.parent` | **no — remote.** Measured 2026-09-03 |
| `reference` source classes 1 and 3 | the Windows SDK header and the Flutter SDK, both on the dev host | **no — host-local, not in the repo.** Measured 2026-09-03 |
| `reference` source classes 2 and 4 | `apple-oss-distributions/Security`; the pub cache and `D:/github/flutter_alone` | **no — external.** Measured 2026-09-03 |
| peer trees behind the tree rule | the six confirmed peers | **no — external and deliberately not stored.** Read again when acted on |

**Decided slots**, which have no authority by construction and are therefore not
in the table: the sacred-path selection, the tie-breaker, the
deliberate-divergence list, the proof method per layer, the extraction plan, and
the script language.

---

## Compile notes and build gaps

Recorded at build time. Each is either already resolved into this document or is
a `build_gaps` entry, and this section says which.

| Finding | Resolution |
|---|---|
| `docs/agents/triage-labels.md` claims five canonical labels; the tracker carries only `ready-for-agent` and `wontfix`. `needs-triage`, `needs-info` and `ready-for-human` do not exist. | **`build_gaps`.** The document and the tracker disagree and neither is obviously right. Nothing in this graph depends on the missing three. |
| `lib/src/x509_cert_store_method_channel.dart` lines 18–20 still say the categorical mapping is "filled in by a follow-up slice" and that native emits `unknown` until then. Issue #5 closed and the mapping exists. | **`build_gaps`.** A `sweep` miss that predates this build; it is a doc-comment that ships to pub.dev. |
| `todo.md` holds an untracked bug in Korean and ships to consumers. | **`build_gaps`**, and it must reach the tracker through `batch` — invariant 3 forbids the path it took. See W5. |
| `.pubignore` enumerates exclusions by filename; the measured rule is stricter than the declaration. | **`build_gaps`** — a sharpening, filed separately. `plat` moves nothing. |
| The assumed `flutter analyze` blind spot was measured false. | **Resolved** into the `gate` section as an explicit non-blind-spot. |
