import Foundation
import Security

extension Data {
  init(reading file: UnsafeMutablePointer<FILE>) {
    self.init()
    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }
    
    while feof(file) == 0 {
      let bytesRead = fread(buffer, 1, bufferSize, file)
      if bytesRead > 0 {
        append(buffer, count: bytesRead)
      }
    }
  }
}

class SystemKeyChain: KeyChainManager {

  func addCertificate(certificateData: Data, addType: Int) throws -> Bool {
    let certData = CertificateUtils.prepareCertificateData(certificateData)

    guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
      throw CertificateError.invalidData
    }

    if addType == CertificateAddType.CERT_STORE_ADD_NEW {
      if certificateExists(certificate: certificate) {
        throw CertificateError.alreadyExists
      }
    } else if addType == CertificateAddType.CERT_STORE_ADD_REPLACE_EXISTING {
      if let existingCert = findExistingCertificate(certificate: certificate) {
        let deleteQuery: [String: Any] = [
          kSecClass as String: kSecClassCertificate,
          kSecValueRef as String: existingCert,
        ]

        let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
        if deleteStatus != errSecSuccess {
          throw CertificateError.securityError(deleteStatus)
        }
      }
    } else if addType == CertificateAddType.CERT_STORE_ADD_NEWER {
      if let existing = findExistingCertificate(certificate: certificate) {
        if !CertificateUtils.isNewerCertificate(newCert: certificate, existingCert: existing) {
          return true
        }

        let deleteQuery: [String: Any] = [
          kSecClass as String: kSecClassCertificate,
          kSecValueRef as String: existing,
        ]

        _ = SecItemDelete(deleteQuery as CFDictionary)
      }
    }

    let query: [String: Any] = [
      kSecClass as String: kSecClassCertificate,
      kSecValueRef as String: certificate,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
    ]

    let status = SecItemAdd(query as CFDictionary, nil)

    if status == errSecSuccess {
      do {
        try addTrustedCertificateWithSecurityCommand(certificateData: certData, isSystemWide: true)
      } catch {
        NSLog(
          "⚠️ Warning: Certificate added but system-wide trust setting failed: %@",
          error.localizedDescription)
      }
      return true
    } else if status == errSecDuplicateItem {
      throw CertificateError.alreadyExists
    } else {
      throw CertificateError.securityError(status)
    }
  }

  func certificateExists(certificate: SecCertificate) -> Bool {
    return CertificateUtils.certificateExists(certificate: certificate, keychain: nil)
  }

  func findExistingCertificate(certificate: SecCertificate) -> SecCertificate? {
    return CertificateUtils.findExistingCertificate(certificate: certificate, keychain: nil)
  }

  func loadAllCertificates() -> [SecCertificate] {
    return CertificateUtils.loadAllCertificatesFromKeychain(keychain: nil)
  }

  
  private func addTrustedCertificateWithSecurityCommand(
    certificateData: Data, isSystemWide: Bool = true
  ) throws {
    let tempDir = NSTemporaryDirectory()
    let tempFile = tempDir + "temp_cert_\(UUID().uuidString).pem"

    let pemData = CertificateUtils.convertDERToPEM(certificateData)

    NSLog(
      "🔐 Attempting to set trust settings using security command (System-wide: %@)",
      isSystemWide ? "YES" : "NO")
    NSLog("📁 Temporary file: %@", tempFile)

    try pemData.write(to: URL(fileURLWithPath: tempFile))

    defer {
      try? FileManager.default.removeItem(atPath: tempFile)
    }

    let script = """
      do shell script "security add-trusted-cert -r trustRoot -p ssl -p smime -p codeSign -p basic -k /Library/Keychains/System.keychain '\(tempFile)'" with administrator privileges
      """
    
    NSLog("🚀 Executing with admin privileges via AppleScript")
    
    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    let result = appleScript?.executeAndReturnError(&error)
    
    if let error = error {
      NSLog("❌ AppleScript execution failed: %@", error)
      throw CertificateError.securityError(OSStatus(error["OSAScriptErrorNumber"] as? Int32 ?? -1))
    }
    
    if let output = result?.stringValue, !output.isEmpty {
      NSLog("📄 Security command output: %@", output)
    }
    
    NSLog("✅ Security command completed successfully with admin privileges")
  }
}
