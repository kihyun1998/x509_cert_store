# thegraph — x509_cert_store

What a person knows about this project that no file here answers. Read by
`thegraph`; a run that needs something missing asks, and the answer is appended.

## What this project is

A plain Dart package that adds X.509 certificates to the Windows and macOS
certificate stores over `dart:ffi`.

## References

| Source | Informs | Reached by | Binding |
|---|---|---|---|
| Win32 wincrypt API | how it works | `Windows Kits/10/Include/<ver>/um/wincrypt.h` on the dev host — raw | binding |
| Apple Security framework | how it works | `apple-oss-distributions/Security` (`SecItem.h`, `SecBase.h`, `SecCertificate.h`) via raw.githubusercontent.com — raw. `developer.apple.com` is a **summarized** fallback; `errSec*` values exist only in `SecBase.h` | binding |
| Peer desktop packages: `url_launcher_windows`, `path_provider_foundation`, `flutter_secure_storage_macos`, `flutter_secure_storage_windows`, `window_manager`, `flutter_alone` | where files go | the pub cache (`%LOCALAPPDATA%/Pub/Cache/hosted/pub.dev/`) and `D:/github/flutter_alone` — raw | example |

## Release

`pub-ready`
