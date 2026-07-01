import Foundation
import Security

class LoginKeyChain: KeyChainManager {

  /// Trust configuration for the login keychain: invoke `security` directly as
  /// the current user (no elevation).
  func applyTrust(certData: Data) throws {
    try addTrustedCertificateWithSecurityCommand(certificateData: certData)
  }

  private func addTrustedCertificateWithSecurityCommand(certificateData: Data) throws {
    let tempDir = NSTemporaryDirectory()
    let tempFile = tempDir + "temp_cert_\(UUID().uuidString).pem"

    let pemData = CertificateUtils.convertDERToPEM(certificateData)

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

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    task.launch()
    task.waitUntilExit()

    if task.terminationStatus != 0 {
      throw CertificateError.securityError(OSStatus(task.terminationStatus))
    }
  }
}
