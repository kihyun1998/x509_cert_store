import 'x509_store_enums.dart' show X509ErrorCode;

/// Result of an X.509 certificate operation.
///
/// A sealed hierarchy: every result is either [X509Success] or [X509Failure].
/// Consumers should pattern-match on the result to handle the success and
/// failure paths exhaustively.
///
/// Example:
/// ```dart
/// final result = await certStore.addCertificate(...);
/// switch (result) {
///   case X509Success():
///     print('OK');
///   case X509Failure(code: X509ErrorCode.alreadyExist):
///     print('Certificate already exists');
///   case X509Failure(code: X509ErrorCode.canceled):
///     print('User canceled');
///   case X509Failure(code: X509ErrorCode.unknown, nativeCode: var n):
///     print('Unmapped failure (native code: $n)');
///   case X509Failure(:final msg):
///     print('Other failure: $msg');
/// }
/// ```
sealed class X509Result {
  const X509Result();
}

/// Indicates that the certificate operation completed successfully.
final class X509Success extends X509Result {
  const X509Success();

  @override
  String toString() => 'X509Success()';

  @override
  bool operator ==(Object other) => other is X509Success;

  @override
  int get hashCode => 0;
}

/// Indicates that the certificate operation failed.
///
/// [code] is the cross-platform [X509ErrorCode] category. [msg] is a
/// human-readable description suitable for logging. [nativeCode] is the
/// raw platform-specific error value, typically populated when [code] is
/// [X509ErrorCode.unknown] so consumers can diagnose unmapped failures.
final class X509Failure extends X509Result {
  /// The cross-platform error category.
  final X509ErrorCode code;

  /// Human-readable failure description.
  final String msg;

  /// Raw platform-specific native error code. May be null when no native
  /// code is associated with the failure (e.g. argument validation failures
  /// that originate on the Dart side).
  final int? nativeCode;

  const X509Failure({
    required this.code,
    required this.msg,
    this.nativeCode,
  });

  @override
  String toString() =>
      'X509Failure(code: $code, msg: "$msg", nativeCode: $nativeCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is X509Failure &&
        other.code == code &&
        other.msg == msg &&
        other.nativeCode == nativeCode;
  }

  @override
  int get hashCode => Object.hash(code, msg, nativeCode);
}
