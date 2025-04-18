import Cocoa
import FlutterMacOS
import Security

public class X509CertStorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "io.github.kihyun1998/x509_cert_store", binaryMessenger: registrar.messenger)
    let instance = X509CertStorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "addCertificate":
      guard let args = call.arguments as? [String: Any],
            let storeName = args["storeName"] as? String,
            let certificateData = args["certificate"] as? FlutterStandardTypedData,
            let addType = args["addType"] as? Int else {
        // Return error in the format expected by Dart when arguments are missing or invalid
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid arguments", details: nil))
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
          result(FlutterError(code: "UNKNOWN_ERROR", message: "Failed to add certificate", details: nil))
        }
      } catch CertificateError.alreadyExists {
        // Handle duplicate certificate with known error code
        result(FlutterError(code: "2148081669", message: "Certificate already exists", details: nil))
      } catch CertificateError.securityError(let code) {
        // Include Security framework error code
        result(FlutterError(code: "\(code)", message: "Security framework error: \(code)", details: nil))
      } catch {
        // Other unexpected errors
        result(FlutterError(code: "UNEXPECTED_ERROR", message: "An unexpected error occurred: \(error)", details: nil))
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

  private func addCertificateToKeychain(storeName: String, certificateData: Data, addType: Int) throws -> Bool {
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

    // 3. Handle based on addType
    if addType == CERT_STORE_ADD_NEW {
        // For CERT_STORE_ADD_NEW: Check if certificate exists. If yes, throw error. If no, add it.
        if certificateExists(certificate: certificate) {
            throw CertificateError.alreadyExists
        }
        // Will add the certificate below
    } else if addType == CERT_STORE_ADD_REPLACE_EXISTING {
        // For CERT_STORE_ADD_REPLACE_EXISTING: Delete existing certificate if it exists
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecValueRef as String: certificate
        ]
        
        _ = SecItemDelete(deleteQuery as CFDictionary)
    } else if addType == CERT_STORE_ADD_NEWER {
        // For CERT_STORE_ADD_NEWER: Check if certificate exists
        if let existing = findExistingCertificate(certificate: certificate) {
            // Compare certificates to see if the new one is newer
            if !isNewerCertificate(newCert: certificate, existingCert: existing) {
                // If the new certificate is not newer, don't add it and return success
                return true
            }
            
            // If the new certificate is newer, delete the existing one
            let deleteQuery: [String: Any] = [
                kSecClass as String: kSecClassCertificate,
                kSecValueRef as String: existing
            ]
            
            _ = SecItemDelete(deleteQuery as CFDictionary)
        }
        // If no existing certificate or if the new one is newer, continue to add the new certificate
    }
    
    // 4. Prepare query for adding the certificate to the keychain
    let query: [String: Any] = [
        kSecClass as String: kSecClassCertificate,
        kSecValueRef as String: certificate,
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]
    
    // 5. Add the certificate
    let status = SecItemAdd(query as CFDictionary, nil)
    
    if status == errSecSuccess {
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
          kSecReturnRef as String: true
      ]
      
      var existingItem: CFTypeRef?
      
      return SecItemCopyMatching(existingQuery as CFDictionary, &existingItem) == errSecSuccess 
          ? (existingItem as! SecCertificate) 
          : nil
  }
  
  func loadAllCertificatesFromKeychain() -> [SecCertificate] {
      let query: [CFString: Any] = [
          kSecClass: kSecClassCertificate,
          kSecMatchLimit: kSecMatchLimitAll,
          kSecReturnRef: true
      ]

      var result: CFTypeRef?
      let status = SecItemCopyMatching(query as CFDictionary, &result)

      if status == errSecSuccess, let certs = result as? [SecCertificate] {
          return certs
      }

      return []
  }

  // Check if certificate already exists in the keychain
  func certificateExists(certificate: SecCertificate) -> Bool {
      guard let certIssuer = SecCertificateCopyNormalizedIssuerSequence(certificate) as Data?,
            let certSerial = SecCertificateCopySerialNumberData(certificate, nil) as Data? else {
          return false
      }

      let allCerts = loadAllCertificatesFromKeychain()

      for existingCert in allCerts {
          guard let existingIssuer = SecCertificateCopyNormalizedIssuerSequence(existingCert) as Data?,
                let existingSerial = SecCertificateCopySerialNumberData(existingCert, nil) as Data? else {
              continue
          }

          if existingIssuer == certIssuer && existingSerial == certSerial {
              return true
          }
      }

      return false
  }



  func findExistingCertificate(certificate: SecCertificate) -> SecCertificate? {
      guard let certIssuer = SecCertificateCopyNormalizedIssuerSequence(certificate) as Data?,
            let certSerial = SecCertificateCopySerialNumberData(certificate, nil) as Data? else {
          return nil
      }

      let allCerts = loadAllCertificatesFromKeychain()

      for existingCert in allCerts {
          guard let existingIssuer = SecCertificateCopyNormalizedIssuerSequence(existingCert) as Data?,
                let existingSerial = SecCertificateCopySerialNumberData(existingCert, nil) as Data? else {
              continue
          }

          if existingIssuer == certIssuer && existingSerial == certSerial {
              return existingCert
          }
      }

      return nil
  }




  // 새 인증서가 기존 인증서보다 최신인지 확인 (만료 날짜 기준)
  private func isNewerCertificate(newCert: SecCertificate, existingCert: SecCertificate) -> Bool {
      // 인증서에서 속성 dictionary를 가져옴
      var error: Unmanaged<CFError>?
      
      // 인증서 속성을 가져옴
      guard let newProps = SecCertificateCopyValues(newCert, nil, &error) as? [CFString: Any] else {
          return false
      }
      
      error = nil // error 재사용
      
      guard let existingProps = SecCertificateCopyValues(existingCert, nil, &error) as? [CFString: Any] else {
          return false
      }
      
      // 유효기간 시작일 키
      let validityStartKey = kSecOIDX509V1ValidityNotBefore

      // 시작 날짜 정보 가져오기
      guard let newValidityData = newProps[validityStartKey] as? [CFString: Any],
            let existingValidityData = existingProps[validityStartKey] as? [CFString: Any] else {
          return false
      }

      let valueKey = kSecPropertyKeyValue

      guard let newValidityValue = newValidityData[valueKey],
            let existingValidityValue = existingValidityData[valueKey] else {
          return false
      }

      guard let newDate = newValidityValue as? Date,
            let existingDate = existingValidityValue as? Date else {
          return false
      }

      // 시작일 기준 비교: 새 인증서가 더 늦게 시작되면 최신으로 간주
      return newDate > existingDate

  }
  
  private func prepareCertificateData(_ data: Data) -> Data {
    // Check if the data is in PEM format
    if let dataString = String(data: data, encoding: .utf8),
       dataString.contains("-----BEGIN CERTIFICATE-----") {
      
      // Remove PEM headers/footers and base64 decode
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
    
    // Return original data if already in DER format or conversion fails
    return data
  }
}