/// X.509 certificate store names supported by the platform.
///
/// This enum represents the different certificate stores available
/// on the target platform where certificates can be installed.
enum X509StoreName {
  /// Root certificate store for trusted root certificate authorities.
  ///
  /// Certificates in this store are automatically trusted by the system
  /// for all applications and services. Adding certificates to this store
  /// typically requires administrative privileges.
  root,

  /// Personal certificate store for user certificates.
  ///
  /// This store contains certificates that belong to the current user,
  /// including client authentication certificates and personal certificates.
  /// Also known as "My Store" on Windows platforms.
  my;

  /// Converts the enum value to its string representation used by native platforms.
  ///
  /// Returns:
  /// - "ROOT" for [root] store
  /// - "MY" for [my] store
  String getString() {
    switch (this) {
      case X509StoreName.root:
        return "ROOT";
      case X509StoreName.my:
        return "MY";
    }
  }
}

/// Cross-platform error categories returned by certificate operations.
///
/// Each enum value represents a semantic category that is mapped from
/// platform-specific native error codes (Win32 `DWORD` on Windows, Security
/// framework `OSStatus` on macOS) at the native layer. The public Dart API
/// exposes only categories, never raw native codes (the raw value, when
/// preserved, lives on `X509Failure.nativeCode`).
enum X509ErrorCode {
  /// Operation was canceled by the user or system.
  canceled,

  /// Certificate already exists in the target store.
  alreadyExist,

  /// Operation was denied for permission reasons (e.g. attempting to add to
  /// the ROOT store without administrator privileges).
  accessDenied,

  /// Certificate data could not be parsed (PEM/DER format error, decode
  /// failure, or other structural problem with the input bytes).
  invalidFormat,

  /// Native error that did not map to any other category. Inspect
  /// `X509Failure.nativeCode` for the raw platform-specific value.
  unknown,
}

/// Certificate addition behavior types.
///
/// These values control how certificates are added to a certificate store,
/// particularly when a certificate with the same identity already exists.
enum X509AddType {
  /// Add the certificate only if it doesn't already exist.
  ///
  /// If a certificate with the same identity is already present in the store,
  /// the operation will fail with [X509ErrorCode.alreadyExist].
  /// Corresponds to CERT_STORE_ADD_NEW (1) on Windows.
  addNew,

  /// Add the certificate only if it's newer than any existing certificate.
  ///
  /// If a certificate with the same identity exists and is newer or the same age,
  /// the operation succeeds without adding the certificate. If the new certificate
  /// is newer, it replaces the existing one.
  /// Corresponds to CERT_STORE_ADD_NEWER (6) on Windows.
  addNewer,

  /// Replace any existing certificate with the same identity.
  ///
  /// If a certificate with the same identity exists, it will be removed and
  /// replaced with the new certificate. If no existing certificate is found,
  /// the new certificate is simply added.
  /// Corresponds to CERT_STORE_ADD_REPLACE_EXISTING (3) on Windows.
  addReplaceExisting;

  /// Gets the numeric code used by the native platform implementation.
  ///
  /// Returns:
  /// - 1 for [addNew]
  /// - 6 for [addNewer]
  /// - 3 for [addReplaceExisting]
  int getCode() {
    switch (this) {
      case X509AddType.addNew:
        return 1;
      case X509AddType.addNewer:
        return 6;
      case X509AddType.addReplaceExisting:
        return 3;
    }
  }
}
