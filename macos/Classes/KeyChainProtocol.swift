import Foundation
import Security

protocol KeyChainManager {
  func addCertificate(certificateData: Data, addType: Int) throws -> Bool
  func certificateExists(certificate: SecCertificate) -> Bool
  func findExistingCertificate(certificate: SecCertificate) -> SecCertificate?
  func loadAllCertificates() -> [SecCertificate]
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
