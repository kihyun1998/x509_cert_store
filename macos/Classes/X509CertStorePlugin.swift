import Cocoa
import FlutterMacOS
import Security

public class X509CertStorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "io.github.kihyun1998/x509_cert_store", binaryMessenger: registrar.messenger)
    let instance = X509CertStorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "addCertificate":
      guard let args = call.arguments as? [String: Any],
        let storeName = args["storeName"] as? String,
        let certificateData = args["certificate"] as? FlutterStandardTypedData,
        let addType = args["addType"] as? Int
      else {
        // Return error in the format expected by Dart when arguments are missing or invalid
        result(
          FlutterError(
            code: "INVALID_ARGUMENT", message: "Missing or invalid arguments", details: nil))
        return
      }

      // Try to add the certificate
      do {
        let success = try addCertificateToKeychain(
          storeName: storeName,
          certificateData: certificateData.data,
          addType: addType
        )

        // On success
        if success {
          result(true)
        } else {
          // Unknown failure — usually this line is not reached
          result(
            FlutterError(code: "UNKNOWN_ERROR", message: "Failed to add certificate", details: nil))
        }
      } catch CertificateError.alreadyExists {
        // Handle duplicate certificate with known error code
        result(
          FlutterError(code: "2148081669", message: "Certificate already exists", details: nil))
      } catch CertificateError.securityError(let code) {
        // Include Security framework error code
        result(
          FlutterError(code: "\(code)", message: "Security framework error: \(code)", details: nil))
      } catch {
        // Other unexpected errors
        result(
          FlutterError(
            code: "UNEXPECTED_ERROR", message: "An unexpected error occurred: \(error)",
            details: nil))
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Define error types
  enum CertificateError: Error {
    case invalidData
    case alreadyExists
    case securityError(OSStatus)
  }

  private func addCertificateToKeychain(storeName: String, certificateData: Data, addType: Int)
    throws -> Bool
  {
    // Define constants with clear names
    let CERT_STORE_ADD_NEW = 1
    let CERT_STORE_ADD_REPLACE_EXISTING = 3
    let CERT_STORE_ADD_NEWER = 6

    // 1. Check if the certificate is in PEM format and convert to DER if necessary
    let certData = prepareCertificateData(certificateData)

    // 2. Create SecCertificate object
    guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
      throw CertificateError.invalidData
    }

    // 3. Determine the appropriate keychain based on storeName
    let keychain = try getKeychainForStore(storeName: storeName)

    // 4. Handle based on addType
    if addType == CERT_STORE_ADD_NEW {
      // For CERT_STORE_ADD_NEW: Check if certificate exists. If yes, throw error. If no, add it.
      if certificateExists(certificate: certificate, keychain: keychain) {
        throw CertificateError.alreadyExists
      }
      // Will add the certificate below
    } else if addType == CERT_STORE_ADD_REPLACE_EXISTING {
      // For CERT_STORE_ADD_REPLACE_EXISTING: Delete existing certificate if it exists
      if let existingCert = findExistingCertificate(certificate: certificate, keychain: keychain) {
        var deleteQuery: [String: Any] = [
          kSecClass as String: kSecClassCertificate,
          kSecValueRef as String: existingCert,
        ]

        if keychain != nil {
          deleteQuery[kSecUseKeychain as String] = keychain
        }

        let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
        if deleteStatus != errSecSuccess {
          throw CertificateError.securityError(deleteStatus)
        }
      }
    } else if addType == CERT_STORE_ADD_NEWER {
      // For CERT_STORE_ADD_NEWER: Check if certificate exists
      if let existing = findExistingCertificate(certificate: certificate, keychain: keychain) {
        // Compare certificates to see if the new one is newer
        if !isNewerCertificate(newCert: certificate, existingCert: existing) {
          // If the new certificate is not newer, don't add it and return success
          return true
        }

        // If the new certificate is newer, delete the existing one
        var deleteQuery: [String: Any] = [
          kSecClass as String: kSecClassCertificate,
          kSecValueRef as String: existing,
        ]

        if keychain != nil {
          deleteQuery[kSecUseKeychain as String] = keychain
        }

        _ = SecItemDelete(deleteQuery as CFDictionary)
      }
      // If no existing certificate or if the new one is newer, continue to add the new certificate
    }

    // 5. Prepare query for adding the certificate to the keychain
    var query: [String: Any] = [
      kSecClass as String: kSecClassCertificate,
      kSecValueRef as String: certificate,
    ]

    // Add keychain-specific attributes
    if keychain != nil {
      query[kSecUseKeychain as String] = keychain
    } else {
      // For user keychain, set accessibility
      query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
    }

    // 6. Add the certificate
    let status = SecItemAdd(query as CFDictionary, nil)

    if status == errSecSuccess {
      // For both MY and ROOT stores, use security command for automatic trust
      if storeName.uppercased() == "MY" {
        do {
          try addTrustedCertificateWithSecurityCommand(certificateData: certData, isSystemWide: false)
        } catch {
          NSLog("⚠️ Warning: Certificate added but trust setting failed: %@", error.localizedDescription)
        }
      } else if storeName.uppercased() == "ROOT" {
        do {
          try addTrustedCertificateWithSecurityCommand(certificateData: certData, isSystemWide: true)
        } catch {
          NSLog("⚠️ Warning: Certificate added but system-wide trust setting failed: %@", error.localizedDescription)
        }
      }
      return true
    } else if status == errSecDuplicateItem {
      throw CertificateError.alreadyExists
    } else {
      throw CertificateError.securityError(status)
    }
  }

  // Get existing certificate if it exists
  private func getExistingCertificate(for certificate: SecCertificate) -> SecCertificate? {
    let existingQuery: [String: Any] = [
      kSecClass as String: kSecClassCertificate,
      kSecValueRef as String: certificate,
      kSecReturnRef as String: true,
    ]

    var existingItem: CFTypeRef?

    return SecItemCopyMatching(existingQuery as CFDictionary, &existingItem) == errSecSuccess
      ? (existingItem as! SecCertificate)
      : nil
  }

  func loadAllCertificatesFromKeychain(keychain: SecKeychain? = nil) -> [SecCertificate] {
    var query: [CFString: Any] = [
      kSecClass: kSecClassCertificate,
      kSecMatchLimit: kSecMatchLimitAll,
      kSecReturnRef: true,
    ]

    if let keychain = keychain {
      query[kSecUseKeychain] = keychain
    }

    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status == errSecSuccess, let certs = result as? [SecCertificate] {
      return certs
    }

    return []
  }

  // Check if certificate already exists in the keychain
  func certificateExists(certificate: SecCertificate, keychain: SecKeychain? = nil) -> Bool {
    guard let certIssuer = SecCertificateCopyNormalizedIssuerSequence(certificate) as Data?,
      let certSerial = SecCertificateCopySerialNumberData(certificate, nil) as Data?
    else {
      return false
    }

    let allCerts = loadAllCertificatesFromKeychain(keychain: keychain)

    for existingCert in allCerts {
      guard let existingIssuer = SecCertificateCopyNormalizedIssuerSequence(existingCert) as Data?,
        let existingSerial = SecCertificateCopySerialNumberData(existingCert, nil) as Data?
      else {
        continue
      }

      if existingIssuer == certIssuer && existingSerial == certSerial {
        return true
      }
    }

    return false
  }

  func findExistingCertificate(certificate: SecCertificate, keychain: SecKeychain? = nil)
    -> SecCertificate?
  {
    guard let certIssuer = SecCertificateCopyNormalizedIssuerSequence(certificate) as Data?,
      let certSerial = SecCertificateCopySerialNumberData(certificate, nil) as Data?
    else {
      return nil
    }

    let allCerts = loadAllCertificatesFromKeychain(keychain: keychain)

    for existingCert in allCerts {
      guard let existingIssuer = SecCertificateCopyNormalizedIssuerSequence(existingCert) as Data?,
        let existingSerial = SecCertificateCopySerialNumberData(existingCert, nil) as Data?
      else {
        continue
      }

      if existingIssuer == certIssuer && existingSerial == certSerial {
        return existingCert
      }
    }

    return nil
  }

  // Check if the new certificate is newer than the existing one (based on expiration date)
  private func isNewerCertificate(newCert: SecCertificate, existingCert: SecCertificate) -> Bool {
    var error: Unmanaged<CFError>?

    // Load attributes from the new certificate
    guard let newProps = SecCertificateCopyValues(newCert, nil, &error) as? [CFString: Any] else {
      return false
    }

    error = nil  // Reuse the error variable

    guard
      let existingProps = SecCertificateCopyValues(existingCert, nil, &error) as? [CFString: Any]
    else {
      return false
    }

    // Key for the "not before" validity date
    let validityStartKey = kSecOIDX509V1ValidityNotBefore

    // Get the start date for each certificate
    guard let newValidityData = newProps[validityStartKey] as? [CFString: Any],
      let existingValidityData = existingProps[validityStartKey] as? [CFString: Any]
    else {
      return false
    }

    let valueKey = kSecPropertyKeyValue

    guard let newValidityValue = newValidityData[valueKey],
      let existingValidityValue = existingValidityData[valueKey]
    else {
      return false
    }

    guard let newDate = newValidityValue as? Date,
      let existingDate = existingValidityValue as? Date
    else {
      return false
    }

    // Compare using the start date: if new certificate starts later, consider it newer
    return newDate > existingDate
  }

  // Add certificate as trusted using security command
  private func addTrustedCertificateWithSecurityCommand(certificateData: Data, isSystemWide: Bool = false) throws {
    // Create temporary file for the certificate
    let tempDir = NSTemporaryDirectory()
    let tempFile = tempDir + "temp_cert_\(UUID().uuidString).pem"

    // Convert DER to PEM format for security command
    let pemData = convertDERToPEM(certificateData)

    NSLog("🔐 Attempting to set trust settings using security command (System-wide: %@)", isSystemWide ? "YES" : "NO")
    NSLog("📁 Temporary file: %@", tempFile)

    // Write certificate to temporary file
    try pemData.write(to: URL(fileURLWithPath: tempFile))

    defer {
      // Clean up temporary file
      try? FileManager.default.removeItem(atPath: tempFile)
    }

    // Execute security command
    let task = Process()
    task.launchPath = "/usr/bin/security"
    
    if isSystemWide {
      // For ROOT store: Add to system keychain (requires admin privileges)
      task.arguments = [
        "add-trusted-cert",
        "-r", "trustRoot",  // Trust as root certificate
        "-p", "ssl",        // For SSL policy
        "-p", "smime",      // For S/MIME policy
        "-p", "codeSign",   // For code signing policy
        "-p", "basic",      // For basic policy
        "-k", "/Library/Keychains/System.keychain",  // System keychain
        tempFile
      ]
    } else {
      // For MY store: Add to user domain
      task.arguments = [
        "add-trusted-cert",
        "-d",               // Add to user domain  
        "-r", "trustRoot",  // Trust as root certificate
        "-p", "ssl",        // For SSL policy
        "-p", "smime",      // For S/MIME policy
        "-p", "codeSign",   // For code signing policy
        "-p", "basic",      // For basic policy
        tempFile            // Let it use default user keychain
      ]
    }

    NSLog("🚀 Executing: %@ %@", task.launchPath!, task.arguments!.joined(separator: " "))

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    NSLog("📊 Security command exit code: %d", task.terminationStatus)
    if !output.isEmpty {
      NSLog("📄 Security command output: %@", output)
    }

    if task.terminationStatus != 0 {
      NSLog("❌ Security command failed with code: %d", task.terminationStatus)
      throw CertificateError.securityError(OSStatus(task.terminationStatus))
    } else {
      NSLog("✅ Security command completed successfully")
    }
  }

  // Convert DER data to PEM format
  private func convertDERToPEM(_ derData: Data) -> Data {
    let base64String = derData.base64EncodedString(options: [
      .lineLength64Characters, .endLineWithLineFeed,
    ])
    let pemString = "-----BEGIN CERTIFICATE-----\n\(base64String)\n-----END CERTIFICATE-----\n"
    return pemString.data(using: .utf8) ?? derData
  }

  // Get the appropriate keychain based on store name
  private func getKeychainForStore(storeName: String) throws -> SecKeychain? {
    switch storeName.uppercased() {
    case "ROOT":
      // For ROOT store, use user keychain but mark as trusted root certificate
      // System keychain is read-only, so we add to user keychain with trust settings
      return nil  // nil means default user keychain
    case "MY":
      // Personal certificates go to user keychain
      return nil  // nil means default user keychain
    default:
      return nil
    }
  }

  private func prepareCertificateData(_ data: Data) -> Data {
    // Check if the data is in PEM format
    if let dataString = String(data: data, encoding: .utf8),
      dataString.contains("-----BEGIN CERTIFICATE-----")
    {

      // Strip PEM headers/footers and decode from Base64
      var pemString = dataString
      pemString = pemString.replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
      pemString = pemString.replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
      pemString = pemString.replacingOccurrences(of: "\n", with: "")
      pemString = pemString.replacingOccurrences(of: "\r", with: "")
      pemString = pemString.trimmingCharacters(in: .whitespacesAndNewlines)

      if let derData = Data(base64Encoded: pemString) {
        return derData
      }
    }

    // Return original data if it's already in DER format or conversion fails
    return data
  }
}
