import Security
import Foundation

class CertificateUtils {
  
  static func prepareCertificateData(_ data: Data) -> Data {
    if let dataString = String(data: data, encoding: .utf8),
      dataString.contains("-----BEGIN CERTIFICATE-----")
    {
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
    return data
  }
  
  static func convertDERToPEM(_ derData: Data) -> Data {
    let base64String = derData.base64EncodedString(options: [
      .lineLength64Characters, .endLineWithLineFeed,
    ])
    let pemString = "-----BEGIN CERTIFICATE-----\n\(base64String)\n-----END CERTIFICATE-----\n"
    return pemString.data(using: .utf8) ?? derData
  }
  
  static func isNewerCertificate(newCert: SecCertificate, existingCert: SecCertificate) -> Bool {
    // Pass nil for the error out-parameter. The failure paths below never
    // inspect the error, and requesting an Unmanaged<CFError> that we then fail
    // to release would leak one CFError per failed lookup.
    guard let newProps = SecCertificateCopyValues(newCert, nil, nil) as? [CFString: Any] else {
      return false
    }

    guard
      let existingProps = SecCertificateCopyValues(existingCert, nil, nil) as? [CFString: Any]
    else {
      return false
    }

    let validityStartKey = kSecOIDX509V1ValidityNotBefore

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

    return newDate > existingDate
  }
  
  static func certificateExists(certificate: SecCertificate, keychain: SecKeychain? = nil) -> Bool {
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
  
  static func findExistingCertificate(certificate: SecCertificate, keychain: SecKeychain? = nil)
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
  
  static func loadAllCertificatesFromKeychain(keychain: SecKeychain? = nil) -> [SecCertificate] {
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
}