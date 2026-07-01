import Foundation
import Security

protocol KeyChainManager {
  func addCertificate(certificateData: Data, addType: Int, setTrusted: Bool) throws -> Bool
  func certificateExists(certificate: SecCertificate) -> Bool
  func findExistingCertificate(certificate: SecCertificate) -> SecCertificate?
  func loadAllCertificates() -> [SecCertificate]

  /// Configure the certificate as trusted. Implemented per store because the
  /// mechanism differs (a user `security` invocation for the login keychain
  /// vs. an admin-elevated call for the system keychain). Called only when
  /// `setTrusted` is requested; `addCertificate` treats failures as
  /// best-effort and does not fail the overall operation.
  func applyTrust(certData: Data) throws
}

enum CertificateError: Error {
  case invalidData
  case alreadyExists
  case securityError(OSStatus)
}

struct CertificateAddType {
  static let CERT_STORE_ADD_NEW = 1
  static let CERT_STORE_ADD_REPLACE_EXISTING = 3
  static let CERT_STORE_ADD_NEWER = 6
}

/// Shared behavior for every keychain-backed store. The only per-store
/// variation is `applyTrust(certData:)`; the add/replace/newer flow and the
/// lookup helpers are identical, so they live here once instead of being
/// duplicated across `LoginKeyChain` and `SystemKeyChain`.
extension KeyChainManager {
  func certificateExists(certificate: SecCertificate) -> Bool {
    return CertificateUtils.certificateExists(certificate: certificate, keychain: nil)
  }

  func findExistingCertificate(certificate: SecCertificate) -> SecCertificate? {
    return CertificateUtils.findExistingCertificate(certificate: certificate, keychain: nil)
  }

  func loadAllCertificates() -> [SecCertificate] {
    return CertificateUtils.loadAllCertificatesFromKeychain(keychain: nil)
  }

  func addCertificate(certificateData: Data, addType: Int, setTrusted: Bool) throws -> Bool {
    let certData = CertificateUtils.prepareCertificateData(certificateData)

    guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
      throw CertificateError.invalidData
    }

    switch addType {
    case CertificateAddType.CERT_STORE_ADD_NEW:
      if certificateExists(certificate: certificate) {
        throw CertificateError.alreadyExists
      }
    case CertificateAddType.CERT_STORE_ADD_REPLACE_EXISTING:
      if let existingCert = findExistingCertificate(certificate: certificate) {
        try deleteCertificate(existingCert)
      }
    case CertificateAddType.CERT_STORE_ADD_NEWER:
      if let existing = findExistingCertificate(certificate: certificate) {
        if !CertificateUtils.isNewerCertificate(newCert: certificate, existingCert: existing) {
          return true
        }
        try deleteCertificate(existing)
      }
    default:
      break
    }

    let query: [String: Any] = [
      kSecClass as String: kSecClassCertificate,
      kSecValueRef as String: certificate,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
    ]

    let status = SecItemAdd(query as CFDictionary, nil)

    if status == errSecSuccess {
      if setTrusted {
        // Best-effort: the certificate is already added, so a trust-configuration
        // failure must not fail the whole operation.
        try? applyTrust(certData: certData)
      }
      return true
    } else if status == errSecDuplicateItem {
      throw CertificateError.alreadyExists
    } else {
      throw CertificateError.securityError(status)
    }
  }

  /// Delete a certificate from the keychain, throwing on failure. Unifies the
  /// previous inconsistency where the NEWER path ignored delete failures on the
  /// login keychain but threw on the system keychain.
  private func deleteCertificate(_ certificate: SecCertificate) throws {
    let deleteQuery: [String: Any] = [
      kSecClass as String: kSecClassCertificate,
      kSecValueRef as String: certificate,
    ]
    let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
    if deleteStatus != errSecSuccess {
      throw CertificateError.securityError(deleteStatus)
    }
  }
}
