# Migration guide

- [2.x to 3.0.0](#2x-to-300) - the package became Dart-only
- [1.x to 2.0.0](#1x-to-200) - the result API was redesigned

## 2.x to 3.0.0

v3.0.0 replaces the native Windows C++ and macOS Swift plugins with `dart:ffi`, and drops the Flutter dependency. **No source changes are required**: `X509CertStore`, `X509Result`, `X509ErrorCode`, `X509StoreName`, and `X509AddType` are unchanged, and `addCertificate` keeps its signature and its behaviour.

### What you have to do

Bump the constraint and clear the build once, because the generated plugin registrant changes when a package stops being a plugin:

```bash
flutter clean
flutter pub get
```

That is the whole migration.

### What changed underneath

| 2.x | 3.0.0 |
| --- | --- |
| Flutter plugin with `windows/` (C++) and `macos/` (Swift) | Dart package calling `crypt32.dll` and Security.framework over `dart:ffi` |
| `flutter` + `plugin_platform_interface` dependencies | `ffi` + `meta`; no Flutter dependency |
| Method channel `io.github.kihyun1998/x509_cert_store` | Direct FFI calls; no channel |
| Error categories mapped in C++/Swift and sent as string keys | Mapped in Dart from the raw Win32 `DWORD` / `OSStatus` |
| PEM/DER normalization implemented twice, natively | One Dart implementation shared by both platforms |
| Platform work ran on the platform thread | Runs on a worker isolate, so prompts no longer block the calling isolate |

### Behaviour worth knowing about

- **Dart-side input rejection.** Empty, non-base64, and malformed-PEM input is now rejected in Dart before any platform call. It was already reported as `invalidFormat`, so the observable result is the same, but it is now identical across platforms.
- **macOS duplicate detection** compares certificate identity as (issuer, serial number) parsed from the DER, where 2.x used `SecCertificateCopyNormalizedIssuerSequence`. That API applies RFC name normalization; DER comparison does not. For a CA re-issuing under the same name - the case duplicate detection exists for - the issuer bytes are identical either way, so this only differs for two certificates whose issuer names match after normalization but differ byte-for-byte.
- **macOS store names.** As in 2.x, the certificate is added to the default keychain for both `X509StoreName` values, and the store name selects the trust mechanism. The 2.x README described this incorrectly; the behaviour has not changed.
- **Failed symbol lookups** surface as `X509Failure(code: X509ErrorCode.unknown)` rather than a link error at build time. This is the one class of failure that moved from build time to runtime.

### Using it outside Flutter

With the Flutter dependency gone, the package works in a plain Dart program:

```dart
import 'package:x509_cert_store/x509_cert_store.dart';

Future<void> main() async {
  final result = await X509CertStore().addCertificate(
    storeName: X509StoreName.my,
    certificateBase64: '...',
    addType: X509AddType.addNew,
  );
  print(result);
}
```

---

## 1.x to 2.0.0

v2.0.0 replaces the v1.x stringly-typed `X509ResValue` return shape with a sealed `X509Result` hierarchy + categorical `X509ErrorCode` enum. This is a **breaking change with no compatibility shim** — every consumer of `addCertificate` must be updated.

For the rationale, see [ADR-0001](docs/adr/0001-sealed-result-type-with-categorical-error-codes.md) and the closed RFC discussion in [#3](https://github.com/kihyun1998/x509_cert_store/issues/3).

### At a glance

| 1.x | 2.0.0 |
| --- | --- |
| `X509ResValue` | `X509Result` (sealed) |
| `result.isOk` (bool) | `case X509Success()` |
| `result.hasError(enum)` | `case X509Failure(code: enum)` |
| `result.code` (String) | `X509Failure.code` (`X509ErrorCode`) |
| `result.msg` (String) | `X509Failure.msg` (unchanged) |
| 3 enum values | 5 enum values |
| native code embedded in `code` string (Windows) | `X509Failure.nativeCode` (`int?`) |
| `hasError()` method | removed — use pattern matching |
| `X509ErrorCode.getString()` / `.fromString()` | removed |

### Common migration patterns

#### Success check

**1.x**:

```dart
if (result.isOk) {
  print('OK');
}
```

**2.0.0**:

```dart
if (result is X509Success) {
  print('OK');
}

// or switch:
switch (result) {
  case X509Success():
    print('OK');
  case X509Failure():
    // ...
}
```

#### Specific error category

**1.x**:

```dart
if (result.hasError(X509ErrorCode.alreadyExist)) {
  print('Already exists');
}
```

**2.0.0**:

```dart
if (result case X509Failure(code: X509ErrorCode.alreadyExist)) {
  print('Already exists');
}
```

#### Full error handling

**1.x**:

```dart
if (result.isOk) {
  print('OK');
} else if (result.hasError(X509ErrorCode.alreadyExist)) {
  print('Already exists');
} else if (result.hasError(X509ErrorCode.canceled)) {
  print('Canceled');
} else {
  print('Other: ${result.msg}');
}
```

**2.0.0**:

```dart
switch (result) {
  case X509Success():
    print('OK');
  case X509Failure(code: X509ErrorCode.alreadyExist):
    print('Already exists');
  case X509Failure(code: X509ErrorCode.canceled):
    print('Canceled');
  case X509Failure(:final msg):
    print('Other: $msg');
}
```

#### Raw error code comparison

**1.x** (worked on Windows after 1.2.2; never worked on macOS in a portable way):

```dart
if (result.code == "2148081669") { // CRYPT_E_EXISTS
  // ...
}
```

**2.0.0**:

```dart
// X509ErrorCode is now the cross-platform category. Comparing raw native
// codes is no longer the right tool — use the typed enum:
if (result case X509Failure(code: X509ErrorCode.alreadyExist)) {
  // ...
}

// If you genuinely need the raw native value (typically for diagnostics
// on unmapped failures), read it from X509Failure.nativeCode:
if (result case X509Failure(
  code: X509ErrorCode.unknown,
  nativeCode: 2148081669,
)) {
  // ...
}
```

#### Error message access

**1.x**:

```dart
final message = result.msg; // always available
```

**2.0.0**:

```dart
final message = switch (result) {
  X509Success() => null,
  X509Failure(:final msg) => msg,
};

// or, when you only care about the failure case:
if (result case X509Failure(:final msg)) {
  print(msg);
}
```

### New in 2.0.0: `unknown` + `nativeCode` diagnostic surface

When a native error doesn't map to any of the four canonical categories (`alreadyExist`, `canceled`, `accessDenied`, `invalidFormat`), v2.0.0 classifies it as `X509ErrorCode.unknown` and preserves the raw platform-specific value in `X509Failure.nativeCode`. In v1.x this diagnostic information was embedded in the `msg` string and required string parsing to extract.

```dart
switch (result) {
  case X509Failure(code: X509ErrorCode.unknown, nativeCode: var n):
    log.warning('Unmapped native error code: $n');
    // Consider filing a GitHub issue requesting a new X509ErrorCode
    // category if this raw code surfaces often in your application.
}
```

For matched categories, `nativeCode` is `null` — the typed enum already conveys the meaning, and `nativeCode` would be redundant.

### New in 2.0.0: Exhaustiveness guarantee

Because `X509Result` is sealed and `X509ErrorCode` is an enum, the Dart compiler verifies that your `switch` covers every case. In v1.x the `hasError()` comparisons were stringly-typed — a typo or a newly-added category would silently fall through. This was the bug class that motivated v2.0.0 (see [#2](https://github.com/kihyun1998/x509_cert_store/issues/2) for one such silent failure on Windows).

```dart
// Adding a new X509ErrorCode value will cause this switch to fail to
// compile — an incremental, type-safe upgrade path.
String describe(X509Result r) {
  return switch (r) {
    X509Success() => 'OK',
    X509Failure(code: X509ErrorCode.canceled) => 'Canceled',
    X509Failure(code: X509ErrorCode.alreadyExist) => 'Duplicate',
    X509Failure(code: X509ErrorCode.accessDenied) => 'Permission denied',
    X509Failure(code: X509ErrorCode.invalidFormat) => 'Bad certificate',
    X509Failure(code: X509ErrorCode.unknown) => 'Other',
  };
}
```

### Removed APIs

| Removed | Replacement |
| --- | --- |
| `class X509ResValue` | `sealed class X509Result` (with `X509Success` / `X509Failure`) |
| `X509ResValue.isOk` | `result is X509Success` |
| `X509ResValue.hasError(code)` | `result case X509Failure(code: code)` |
| `X509ResValue.code` (String) | `X509Failure.code` (`X509ErrorCode`) |
| `X509ResValue.copyWith(...)` | None — `X509Result` instances are immutable values; construct a new one |
| `X509ErrorCode.getString()` | None — the public API no longer exposes the stringly-typed key |
| `X509ErrorCode.fromString(...)` | None — categorical mapping happens at the native layer |

### New `X509ErrorCode` values

v1.x had three categories (`canceled`, `alreadyExist`, `unknown`). v2.0.0 adds two more, both pain-driven from real native error sites:

- **`accessDenied`** — admin-required operations attempted without privileges (e.g. adding to ROOT store on Windows / macOS System keychain). Consumers can now show a "needs admin" prompt without parsing native codes.
- **`invalidFormat`** — certificate data could not be parsed (PEM/DER decode failure). Lets consumers distinguish "bad input" from other failures.

### Questions or unmapped errors?

If you encounter an `X509ErrorCode.unknown` failure with a `nativeCode` that you think deserves its own category, please file an issue at <https://github.com/kihyun1998/x509_cert_store/issues> with the raw value and your use case.
