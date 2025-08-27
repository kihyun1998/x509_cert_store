import Foundation
import Security

class LoginKeyChain: KeyChainManager {

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
        try addTrustedCertificateWithSecurityCommand(certificateData: certData, isSystemWide: false)
      } catch {
        NSLog(
          "⚠️ Warning: Certificate added but trust setting failed: %@", error.localizedDescription)
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
    certificateData: Data, isSystemWide: Bool = false
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

    let task = Process()
    task.launchPath = "/usr/bin/security"
    task.arguments = [
      "add-trusted-cert",
      "-d",
      "-r", "trustRoot",
      "-p", "ssl",
      "-p", "smime",
      "-p", "codeSign",
      "-p", "basic",
      tempFile,
    ]

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
}
