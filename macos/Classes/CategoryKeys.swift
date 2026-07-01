import Foundation

/// The X509ErrorCode category keys sent over the method channel. These strings
/// are the wire contract shared with the Dart and Windows layers; keep them in
/// sync with lib/src/x509_cert_store_method_channel.dart and
/// windows/x509_cert_store_categories.h.
enum X509Category {
  static let canceled = "canceled"
  static let alreadyExist = "alreadyExist"
  static let accessDenied = "accessDenied"
  static let invalidFormat = "invalidFormat"
  static let unknown = "unknown"
}
