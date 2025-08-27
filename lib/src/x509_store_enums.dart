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

/// Standard error codes that can be returned during certificate operations.
/// 
/// These error codes correspond to common certificate management errors
/// across different platforms.
enum X509ErrorCode {
  /// Operation was canceled by the user or system.
  /// 
  /// This typically occurs when a user cancels a certificate installation
  /// dialog or when the system interrupts the operation.
  canceled,

  /// Certificate already exists in the target store.
  /// 
  /// This error is returned when attempting to add a certificate that
  /// is already present in the specified certificate store.
  alreadyExist,

  /// Unknown or unhandled error occurred.
  /// 
  /// This is a catch-all error code for situations where the specific
  /// error cannot be categorized into other error types.
  unknown;

  /// Gets the platform-specific error code string.
  /// 
  /// Returns:
  /// - "2148081669" for [alreadyExist] (CRYPT_E_EXISTS on Windows)
  /// - "1223" for [canceled] (ERROR_CANCELLED on Windows)
  /// - "UNKNOWN" for [unknown] errors
  String getString() {
    switch (this) {
      case X509ErrorCode.alreadyExist:
        return "2148081669"; // CRYPT_E_EXISTS
      case X509ErrorCode.canceled:
        return "1223"; // ERROR_CANCELLED
      case X509ErrorCode.unknown:
        return "UNKNOWN";
    }
  }

  /// Creates an [X509ErrorCode] from its string representation.
  /// 
  /// If the provided [code] doesn't match any known error code,
  /// returns [X509ErrorCode.unknown].
  /// 
  /// [code]: The error code string to parse
  static X509ErrorCode fromString(String code) {
    for (var value in X509ErrorCode.values) {
      if (value.getString() == code) {
        return value;
      }
    }
    return X509ErrorCode.unknown;
  }
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