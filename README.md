# X509 Certificate Store

A Flutter plugin for Windows and macOS desktop applications that enables adding X.509 certificates to the local certificate store. This plugin provides a simple and efficient way to manage certificates in desktop environments.

[![pub package](https://img.shields.io/pub/v/x509_cert_store.svg)](https://pub.dev/packages/x509_cert_store)

## Features

- Add certificates to the Windows certificate store and macOS Keychain
- **Certificate trust settings support** - Optionally configure certificates as trusted (macOS only) using `setTrusted` parameter
- Support for multiple store locations (ROOT, MY) on Windows and macOS Keychain stores
- Various certificate addition types:
  - Add new certificates only
  - Add newer versions of certificates
  - Replace existing certificates
- Comprehensive error handling with descriptive error codes
- Automatic PEM/DER format detection and conversion
- Enhanced certificate management with improved duplicate detection

## Platform Support

| macOS | Windows | Linux |
|:-----:|:-------:|:-----:|
|   ✅   |    ✅    |   🔜   |

Linux support coming soon!

## Installation

```yaml
dependencies:
  x509_cert_store: ^2.0.0
```

Or run:

```
flutter pub add x509_cert_store
```

> **Upgrading from 1.x?** v2.0.0 introduces a breaking redesign of the result API. See [MIGRATION.md](MIGRATION.md) for before/after examples for every common usage pattern.

## Platform-specific Setup

### macOS Setup

To use this plugin on macOS, you need to configure the entitlements properly:

1. **Disable App Sandbox** in your `macos/Runner/*.entitlements` files (DebugProfile.entitlements, Release.entitlements):

```xml
<key>com.apple.security.app-sandbox</key>
<false/>
```

2. Add the Keychain access entitlement:

```xml
<key>com.apple.security.keychain</key>
<true/>
```

**Note:** The App Sandbox must be set to `false` to allow proper certificate operations and trust settings configuration.

### Windows Setup

No additional setup is required for Windows.

## Usage

```dart
import 'package:x509_cert_store/x509_cert_store.dart';

final x509CertStore = X509CertStore();

const String certificateBase64 = "MIIDKjCCAhKgAwIBAgIQFSHum2++9bhOXjAo4Z7...";

final result = await x509CertStore.addCertificate(
  storeName: X509StoreName.root,
  certificateBase64: certificateBase64,
  addType: X509AddType.addNew,
  setTrusted: true, // macOS only; ignored on Windows
);

switch (result) {
  case X509Success():
    print("Certificate added successfully");
  case X509Failure(code: X509ErrorCode.alreadyExist):
    print("Certificate already exists in the store");
  case X509Failure(code: X509ErrorCode.canceled):
    print("User canceled the certificate installation");
  case X509Failure(code: X509ErrorCode.accessDenied):
    print("Admin privileges required");
  case X509Failure(code: X509ErrorCode.invalidFormat):
    print("Invalid certificate format");
  case X509Failure(code: X509ErrorCode.unknown, nativeCode: var n):
    print("Unmapped failure (native code: $n)");
}
```

`X509Result` is a sealed type — the Dart compiler verifies that your `switch` covers every case, so adding a new `X509ErrorCode` value in the future will surface as a compile error rather than a silent fallthrough.

## API Reference

### X509CertStore

The main class for interacting with the certificate store.

#### Methods

- `Future<X509Result> addCertificate({required X509StoreName storeName, required String certificateBase64, required X509AddType addType, bool setTrusted = false})`  
  Adds a certificate to the specified certificate store with optional trust settings. Returns a sealed `X509Result` — either `X509Success` or `X509Failure(code: X509ErrorCode, msg: String, nativeCode: int?)`.
  
  **Parameters:**
  - `storeName` - The target certificate store (ROOT or MY)
  - `certificateBase64` - The certificate in base64 format
  - `addType` - How to handle the certificate addition
  - `setTrusted` - Whether to configure the certificate as trusted (**macOS only**, ignored on Windows)

### X509StoreName (enum)

Specifies the certificate store location.

- `root` - The trusted root certification authorities store
- `my` - The personal certificate store

### X509AddType (enum)

Specifies how to handle the certificate addition.

- `addNew` - Add only if the certificate doesn't exist
- `addNewer` - Add only if the certificate is newer than an existing one
- `addReplaceExisting` - Replace any existing certificate

### X509Result (sealed class)

Returned by `addCertificate`. Either `X509Success` (no fields) or `X509Failure` with:

- `code: X509ErrorCode` — cross-platform error category
- `msg: String` — human-readable failure description
- `nativeCode: int?` — raw native error code; populated for failures bucketed as `X509ErrorCode.unknown` so consumers can diagnose unmapped errors

### X509ErrorCode (enum)

Cross-platform error categories. Each maps from one or more platform-specific native error codes at the native layer (Win32 `DWORD` on Windows, Security framework `OSStatus` on macOS).

- `canceled` — The user canceled the operation
- `alreadyExist` — The certificate already exists in the store
- `accessDenied` — Operation denied for permission reasons (e.g. admin privileges required for the ROOT store)
- `invalidFormat` — Certificate data could not be parsed (PEM/DER format issue or decode failure)
- `unknown` — Native error that did not map to any other category; inspect `X509Failure.nativeCode` for the raw value

## Platform-specific Behavior

### macOS

On macOS, certificates are managed through the Keychain system with support for both system and login keychains:

- `X509StoreName.root` adds certificates to the **System Keychain** (requires admin privileges)
- `X509StoreName.my` adds certificates to the **Login Keychain** (user-level access)
- **Trust Settings**: When `setTrusted: true` is explicitly specified, the certificate will be configured as a trusted certificate (default is `false`)
- **Fallback Mechanism**: If system-level trust configuration fails (due to permissions), the plugin automatically falls back to adding trusted certificates to the login keychain
- The user may be prompted to enter their password to allow the application to modify the Keychain
- Enhanced certificate management with improved duplicate detection and replacement logic

### Windows

On Windows, certificates are added to the Windows Certificate Store according to the `X509StoreName` value specified:

- `X509StoreName.root` adds to the **Trusted Root Certification Authorities store** (automatically trusted)
- `X509StoreName.my` adds to the **Personal Certificate store**
- **Trust Settings**: The `setTrusted` parameter is ignored on Windows as certificates added to the ROOT store are automatically trusted by the system
- Depending on the certificate and store location, users may see a security prompt asking for confirmation
- Administrator privileges may be required for adding certificates to certain stores

## Example

Check the `/example` folder for a complete implementation demonstrating:
- Adding certificates with different addition types
- Proper error handling
- Creating certificate files from base64 strings
- Platform-specific configurations

## Notes for Developers

If you're contributing to this plugin or integrating it into your application, note that:

1. For macOS, the plugin requires Keychain access, which is enabled through entitlements
2. For Windows, the plugin uses the Windows CryptoAPI

## License

MIT

## Contributing

Contributions are welcome! If you encounter any issues or have feature requests, please file them in the [issue tracker](https://github.com/kihyun1998/x509_cert_store/issues).