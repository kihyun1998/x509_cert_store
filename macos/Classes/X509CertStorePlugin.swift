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
        result(Self.failure(category: X509Category.unknown, message: "Missing or invalid arguments"))
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
          result(Self.failure(category: X509Category.unknown, message: "Failed to add certificate"))
        }
      } catch CertificateError.invalidData {
        result(Self.failure(
          category: X509Category.invalidFormat,
          message: "Invalid certificate data"))
      } catch CertificateError.alreadyExists {
        // Pre-empted by certificateExists() or surfaced as
        // errSecDuplicateItem; either way the category is alreadyExist.
        result(Self.failure(
          category: X509Category.alreadyExist,
          message: "Certificate already exists"))
      } catch CertificateError.securityError(let code) {
        // Try to map the OSStatus to a known category; otherwise fall
        // back to "unknown" and preserve the raw value for diagnostics.
        let category = Self.mapOSStatus(code) ?? X509Category.unknown
        result(Self.failure(
          category: category,
          message: "Security framework error: \(code)",
          nativeCode: Int(code)))
      } catch {
        result(Self.failure(
          category: X509Category.unknown,
          message: "An unexpected error occurred: \(error)"))
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

  /// Map a Security framework OSStatus to an X509ErrorCode category key.
  ///
  /// Returns nil for unmapped status values — the failure then surfaces as
  /// "unknown" with the raw OSStatus preserved in `details.nativeCode`.
  private static func mapOSStatus(_ status: OSStatus) -> String? {
    switch status {
    case errSecDuplicateItem:
      return X509Category.alreadyExist
    case errSecUserCanceled:
      return X509Category.canceled
    case errSecAuthFailed:
      return X509Category.accessDenied
    case errSecDecode:
      return X509Category.invalidFormat
    default:
      return nil
    }
  }

  /// Build a FlutterError with the v2.0.0 contract.
  ///
  /// For matched categories, `details.nativeCode` is null since the
  /// consumer already receives the typed enum value. For "unknown" failures
  /// the raw native code (when applicable) is preserved so consumers can
  /// diagnose unmapped errors and surface a useful diagnostic to users.
  private static func failure(
    category: String,
    message: String,
    nativeCode: Int? = nil
  ) -> FlutterError {
    let codeValue: Any
    if category == X509Category.unknown {
      codeValue = nativeCode ?? NSNull()
    } else {
      codeValue = NSNull()
    }
    let details: [String: Any] = ["nativeCode": codeValue]
    return FlutterError(code: category, message: message, details: details)
  }
}
