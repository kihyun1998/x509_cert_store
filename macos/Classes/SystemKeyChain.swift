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

  /// Trust configuration for the system keychain: elevate via AppleScript, and
  /// fall back to a direct `security` invocation if elevation is unavailable.
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

    // First try with sudo via AppleScript for the system keychain.
    let script = """
      do shell script "security add-trusted-cert -d -r trustRoot -p ssl -p smime -p codeSign -p basic -k /Library/Keychains/System.keychain '\(tempFile)'" with administrator privileges
      """

    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    let _ = appleScript?.executeAndReturnError(&error)

    if error != nil {
      try fallbackToProcessExecution(tempFile: tempFile)
    }
  }

  private func fallbackToProcessExecution(tempFile: String) throws {
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
