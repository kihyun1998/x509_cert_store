# x509_cert_store

Flutter desktop plugin that adds X.509 certificates to the operating-system certificate store on Windows and macOS.

## Language

**Certificate store**:
The OS-managed location where X.509 certificates are persisted. On Windows this is the wincrypt-managed store (e.g. `ROOT`, `MY`); on macOS it is the Keychain (System or Login).
_Avoid_: Cert vault, keystore (Java/Android term)

**Cross-platform store name**:
The portable identifier the plugin's public API uses to select a store. `X509StoreName.root` and `X509StoreName.my` map to the platform-specific **Certificate store** at the native layer.
_Avoid_: Store ID, store type

**Native error code**:
The raw, platform-specific error returned by the underlying OS API: a Win32 `DWORD` (e.g. `CRYPT_E_EXISTS` = `0x80092005`) on Windows, an `OSStatus` from Apple's Security framework on macOS. Integral, never portable across platforms.
_Avoid_: Errno (POSIX term), error number

**Error category**:
The portable, cross-platform meaning of a failure, represented by `X509ErrorCode` (an enum, post-2.0.0). Each **Native error code** maps to exactly one category at the native layer; the public Dart API exposes only categories, never raw native codes (except as the optional `nativeCode` field on `X509Failure` when the category is `unknown`).
_Avoid_: Error type, error kind (overloaded in Dart language)

## Relationships

- A **Certificate store** holds zero or more X.509 certificates
- A **Cross-platform store name** identifies exactly one **Certificate store** at runtime
- A **Native error code** belongs to exactly one platform
- Each **Native error code** maps to exactly one **Error category** (at the native layer)
- An **Error category** has zero or more **Native error codes** mapped to it (across both platforms)

## Example dialogue

> **Dev:** "If I call `addCertificate` and macOS returns `errSecDuplicateItem`, what does the consumer see?"
> **Maintainer:** "The macOS native layer maps `errSecDuplicateItem` to the `alreadyExist` **Error category** and returns `X509Failure(code: X509ErrorCode.alreadyExist, ...)`. The consumer never sees `errSecDuplicateItem` itself — that's a **Native error code**, not part of the cross-platform contract."

## Flagged ambiguities

- "Error code" in 1.x code/docs referred to three different things: (a) the `X509ErrorCode` enum, (b) the stringified native code stored in `X509ResValue.code`, and (c) the raw integral native code. **Resolved post-2.0.0**: only **Native error code** (integral, platform-specific) and **Error category** (`X509ErrorCode` enum) remain; the stringified intermediate form is gone.
