import Cocoa
import FlutterMacOS
import Security

public class X509CertStorePlugin: NSObject, FlutterPlugin {
  private let loginKeyChain = LoginKeyChain()
  private let systemKeyChain = SystemKeyChain()
  
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

      let setTrusted = args["setTrusted"] as? Bool ?? false

      // Try to add the certificate
      do {
        let keyChainManager = getKeyChainManager(for: storeName)
        let success = try keyChainManager.addCertificate(
          certificateData: certificateData.data,
          addType: addType,
          setTrusted: setTrusted
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

  private func getKeyChainManager(for storeName: String) -> KeyChainManager {
    switch storeName.uppercased() {
    case "MY":
      return loginKeyChain
    case "ROOT":
      return systemKeyChain
    default:
      return loginKeyChain
    }
  }

}
