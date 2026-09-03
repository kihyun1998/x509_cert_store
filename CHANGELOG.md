## 3.0.0

### BREAKING CHANGES
- The package is no longer a Flutter plugin. The Windows C++ and macOS Swift implementations are replaced by `dart:ffi` calls into `crypt32.dll` and the Security framework, and the `flutter` dependency is dropped entirely - `x509_cert_store` is now a plain Dart package usable from Flutter apps and Dart CLI programs alike.
- **The public API is unchanged.** `X509CertStore`, `X509Result`, `X509ErrorCode`, `X509StoreName`, and `X509AddType` keep their existing shapes, so no consumer code needs editing. Because the generated plugin registrant changes, run `flutter clean` and `flutter pub get` once after upgrading.
- Removed the internal `X509CertStorePlatform` / `MethodChannelX509CertStore` classes and the `plugin_platform_interface` dependency. Neither was exported from `package:x509_cert_store/x509_cert_store.dart`, so this is not a source-breaking change.

### Changed
- Base64 decoding and PEM/DER normalization now run in Dart before the platform call, so `invalidFormat` for empty, malformed, or non-decodable input is reported identically on every platform.
- Certificate identity for duplicate detection is parsed from the certificate DER in Dart (issuer + serial number) rather than through `SecCertificateCopyNormalizedIssuerSequence` / `SecCertificateCopySerialNumberData`, and `addNewer` compares a `notBefore` parsed from DER rather than one read via `SecCertificateCopyValues`.
- Platform calls run on a worker isolate, so the system confirmation and authorization prompts they can raise no longer block the calling isolate.
- macOS trust elevation uses `osascript` in place of `NSAppleScript`; the `security add-trusted-cert` invocation is otherwise identical.

### Fixed
- Documented macOS store behaviour accurately: the certificate is added to the default keychain for both `X509StoreName` values, which select the trust mechanism rather than the destination keychain. The README previously described `root` and `my` as targeting the System and Login keychains, which the implementation never did.

### Internal
- Deleted `windows/` and `macos/` along with the CMake, podspec, gtest, and XCTest build surface.
- `dart test` now covers PEM/DER handling, DER parsing, certificate identity, and result mapping on any host - logic that previously required a macOS runner to exercise. FFI symbol resolution is pinned per platform by `test/windows_ffi_symbols_test.dart` and `test/macos_ffi_symbols_test.dart`.
- CI analyzes and tests on a bare Dart SDK with no Flutter installed, so reintroducing a Flutter dependency fails the build.

## 2.0.2

### Fixed
- Windows: an empty certificate (empty base64) no longer triggers an out-of-bounds read; it now fails cleanly with `X509ErrorCode.invalidFormat`, matching macOS behavior.
- Windows: hardened PEM parsing against malformed input where the `END` marker precedes `BEGIN` (previously surfaced as `unknown`; now `invalidFormat`).
- macOS: fixed a `CFError` memory leak on the certificate-comparison failure path (`isNewerCertificate`).
- macOS: a failed certificate deletion during the "add newer" flow on the login keychain now surfaces as an error instead of being silently ignored, consistent with the system keychain.
- Dart: a non-`true` native result returned without an error is now reported as `X509Failure(X509ErrorCode.unknown)` instead of a false `X509Success`.

### Internal
- Added a GitHub Actions CI pipeline (analyze, Dart unit tests, Windows/macOS native compile) and wired up the Windows native gtest target.
- Deduplicated the macOS login/system keychain implementations behind a shared `KeyChainManager` protocol extension.
- Centralized the method-channel error-category keys into named constants across the C++, Swift, and Dart layers.

## 2.0.1

### Fixed
- Windows: removed non-ASCII em-dash characters from `x509_cert_store_plugin.cpp` comments. On hosts whose system codepage cannot represent them (e.g. Korean Windows / CP949), MSVC raised `C4819` and Flutter's default `/WX` escalated it to `C2220`, breaking the build for any downstream app using this plugin.

## 2.0.0

### BREAKING CHANGES
- `X509ResValue` class and its `hasError()` / `code` / `isOk` / `msg` accessors are removed. `addCertificate` now returns a sealed `X509Result` (either `X509Success` or `X509Failure`); consumers must pattern-match on the result.
- `X509Failure` carries the cross-platform category as `code: X509ErrorCode` (a typed enum, no longer a `String`), a `msg`, and a nullable `nativeCode: int?` for unmapped-failure diagnostics.
- `X509ErrorCode` enum expanded from 3 to 5 values: `canceled`, `alreadyExist`, `accessDenied` (new), `invalidFormat` (new), `unknown`. The `getString()` / `fromString()` helpers are removed.
- Native plugins now own the `native-errcode → X509ErrorCode` mapping. The Dart API no longer exposes raw native codes except via the optional `X509Failure.nativeCode` field for failures bucketed as `unknown`.
- macOS no longer coerces failures into Windows DWORD literals (`"2148081669"` etc.); each platform emits its own categorical key.

See `MIGRATION.md` for before/after examples for every common usage pattern. Design rationale lives in `docs/adr/0001-sealed-result-type-with-categorical-error-codes.md` and the closed RFC discussion in issue #3.

## 1.2.2

### Fixed
- Windows error codes are now exposed as numeric Win32 values (e.g. `2148081669` for `CRYPT_E_EXISTS`, `1223` for `ERROR_CANCELLED`) instead of the generic `CERT_ADD_FAILED` literal. This enables `result.hasError(X509ErrorCode.alreadyExist)` and `result.hasError(X509ErrorCode.canceled)` to work cross-platform, matching the macOS contract.

## 1.2.1

### Fixed
- Fixed Swift compilation errors in macOS implementation
- Corrected protocol conformance issues in SystemKeyChain class
- Fixed missing bracket in certificate deletion logic

## 1.2.0

### Added
- Certificate trust functionality for macOS platform (using `setTrusted` parameter)
- Enhanced certificate management with trust settings support on macOS
- Comprehensive certificate existence checking with keychain-specific operations

### Fixed  
- Fixed certificate addition issues on macOS that were preventing certificates from being added properly
- Improved certificate duplicate detection and replacement logic
- Enhanced error handling and logging for better debugging

### Improved
- Implemented fallback mechanisms for certificate trust operations when system-level permissions are not available
- Added detailed logging for certificate operations to help with troubleshooting

## 1.1.3

- update license

## 1.1.2

- update license

## 1.1.1

- Raised macOS deployment target to 10.13 for CocoaPods compatibility.

## 1.1.0

- Added macOS platform support
- Implemented certificate management on macOS:
  - Support for adding certificates to the macOS Keychain
  - Automatic conversion between PEM and DER formats on macOS
  - Certificate duplicate detection and management
  - Proper error handling with descriptive error codes
- Updated documentation to reflect macOS support
- Code organization improvements for cross-platform support

## 1.0.0

- First stable release
- Major code improvements:
  - Consistent error handling across platforms
  - Improved code organization with better separation of concerns
  - Enhanced memory management in C++ code
  - Better type safety in Dart code
  - Proper resource cleanup and error handling in Windows implementation
- Complete documentation with usage examples
- Added proper error code handling with helper functions
- Enhanced certificate format detection (PEM/DER)
- Comprehensive test suite
- Added additional safeguards for certificate context management

## 0.9.5

- Added error code checking functionality with `hasError()` method
- Improved error reporting with specific error codes
- Enhanced return value structure for better error diagnosis

## 0.9.4

- Added support for PEM format certificates
- Automatic detection and conversion between PEM and DER formats
- Improved certificate parsing logic

## 0.9.3

- Improved error catching and reporting
- Better exception handling in native code
- More descriptive error messages

## 0.9.2

- Updated README.md with improved documentation
- Enhanced example code with proper error handling
- Exported necessary packages for easier use

## 0.9.1

- Improved README.md with better installation and usage instructions
- Added code examples and API reference

## 0.9.0

- Initial release
- Basic functionality to add certificates to the Windows certificate store
- Support for ROOT and MY store locations
- Support for different certificate addition modes
