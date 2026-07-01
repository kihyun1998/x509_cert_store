import Cocoa
import FlutterMacOS
import XCTest

@testable import x509_cert_store

// Exercises the macOS plugin through its public handle(_:result:) entry point.
// Every case here is side-effect-free: it either trips an argument guard or
// fails certificate parsing (SecCertificateCreateWithData) before any keychain
// access, so it is safe to run in CI. Replaces the default getPlatformVersion
// template test, which called a method the plugin never implemented.
class RunnerTests: XCTestCase {

  private func invoke(_ method: String, arguments: Any?) -> Any? {
    let plugin = X509CertStorePlugin()
    let call = FlutterMethodCall(methodName: method, arguments: arguments)
    var captured: Any?
    let done = expectation(description: "result delivered")
    plugin.handle(call) { result in
      captured = result
      done.fulfill()
    }
    waitForExpectations(timeout: 1)
    return captured
  }

  func testUnknownMethodReturnsNotImplemented() {
    let result = invoke("noSuchMethod", arguments: nil)
    XCTAssertTrue(result as AnyObject === FlutterMethodNotImplemented)
  }

  func testAddCertificateWithMissingArgumentsReturnsUnknownError() {
    // "certificate" and "addType" are absent: the argument guard rejects the
    // call before any keychain access.
    let result = invoke("addCertificate", arguments: ["storeName": "MY"])
    let error = result as? FlutterError
    XCTAssertNotNil(error)
    XCTAssertEqual(error?.code, X509Category.unknown)
  }

  func testAddCertificateWithInvalidDataReturnsInvalidFormat() {
    // Well-formed arguments but bytes that are not a DER certificate:
    // SecCertificateCreateWithData returns nil and the plugin maps this to
    // invalidFormat. No keychain item is ever added.
    let garbage = FlutterStandardTypedData(bytes: Data([0xDE, 0xAD, 0xBE, 0xEF]))
    let result = invoke(
      "addCertificate",
      arguments: [
        "storeName": "MY",
        "certificate": garbage,
        "addType": 1,
      ])
    let error = result as? FlutterError
    XCTAssertNotNil(error)
    XCTAssertEqual(error?.code, X509Category.invalidFormat)
  }

  func testCategoryConstantsMatchWireContract() {
    // These keys are the wire contract shared with the Dart and Windows layers.
    XCTAssertEqual(X509Category.canceled, "canceled")
    XCTAssertEqual(X509Category.alreadyExist, "alreadyExist")
    XCTAssertEqual(X509Category.accessDenied, "accessDenied")
    XCTAssertEqual(X509Category.invalidFormat, "invalidFormat")
    XCTAssertEqual(X509Category.unknown, "unknown")
  }
}
