import Cocoa
import FlutterMacOS
import XCTest

// x509_cert_store has no macOS native code left to test: the Swift plugin was
// replaced by dart:ffi calls into the Security framework, which are covered by
// the Dart suite (test/macos_ffi_symbols_test.dart pins the symbol lookups,
// test/certificate_fields_test.dart covers the parsing that replaced
// SecCertificateCopyValues and friends).
//
// This target ships with the Flutter macOS template and is kept so the example
// project matches a freshly generated one. The smoke test below asserts only
// that the target builds and links against the host app.
class RunnerTests: XCTestCase {

  func testHostApplicationIsLinked() {
    XCTAssertNotNil(NSApplication.shared)
  }
}
