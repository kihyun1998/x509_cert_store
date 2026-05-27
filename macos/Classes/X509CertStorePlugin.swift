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
        result(Self.failure(message: "Missing or invalid arguments", nativeCode: nil))
        return
      }

      let setTrusted = args["setTrusted"] as? Bool ?? false

      do {
        let keyChainManager = getKeyChainManager(for: storeName)
        let success = try keyChainManager.addCertificate(
          certificateData: certificateData.data,
          addType: addType,
          setTrusted: setTrusted
        )

        if success {
          result(true)
        } else {
          // Usually unreachable — the underlying call throws on failure.
          result(Self.failure(message: "Failed to add certificate", nativeCode: nil))
        }
      } catch CertificateError.invalidData {
        result(Self.failure(message: "Invalid certificate data", nativeCode: nil))
      } catch CertificateError.alreadyExists {
        // Either pre-empted by certificateExists() or surfaced as
        // errSecDuplicateItem from SecItemAdd. Forward the canonical
        // OSStatus so consumers can diagnose unmapped failures.
        result(Self.failure(
          message: "Certificate already exists",
          nativeCode: Int(errSecDuplicateItem)))
      } catch CertificateError.securityError(let code) {
        result(Self.failure(
          message: "Security framework error: \(code)",
          nativeCode: Int(code)))
      } catch {
        result(Self.failure(
          message: "An unexpected error occurred: \(error)",
          nativeCode: nil))
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

  /// Build a FlutterError for the v2.0.0 baseline.
  ///
  /// All failures use category "unknown" for now; categorical mapping
  /// (alreadyExist / canceled / accessDenied / invalidFormat) is added by
  /// a follow-up slice. The raw native code, when applicable, is forwarded
  /// via `details.nativeCode` and surfaces as `X509Failure.nativeCode` on
  /// the Dart side.
  private static func failure(message: String, nativeCode: Int?) -> FlutterError {
    let details: [String: Any] = ["nativeCode": nativeCode ?? NSNull()]
    return FlutterError(code: "unknown", message: message, details: details)
  }
}
