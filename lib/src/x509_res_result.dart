import 'x509_store_enums.dart' show X509ErrorCode;

/// Result value returned by X.509 certificate operations.
///
/// This class encapsulates the result of certificate operations, including
/// success status, error messages, and error codes that can be used for
/// programmatic error handling.
class X509ResValue {
  /// Whether the operation completed successfully.
  ///
  /// `true` if the operation succeeded, `false` if it failed.
  final bool isOk;

  /// Human-readable message describing the operation result.
  ///
  /// For successful operations, contains a success message.
  /// For failed operations, contains details about what went wrong.
  final String msg;

  /// Error or status code for programmatic handling.
  ///
  /// For successful operations, typically contains "SUCCESS".
  /// For failed operations, contains platform-specific error codes
  /// that can be matched against [X509ErrorCode] values.
  final String code;

  /// Creates a new [X509ResValue] with the specified parameters.
  ///
  /// [isOk]: Whether the operation was successful
  /// [msg]: Human-readable message describing the result
  /// [code]: Machine-readable code for programmatic handling
  X509ResValue({
    required this.isOk,
    required this.msg,
    required this.code,
  });

  /// Creates an initial/default result indicating no operation was performed.
  ///
  /// This factory constructor is useful for initializing result variables
  /// before performing actual operations.
  factory X509ResValue.init() => X509ResValue(
        isOk: false,
        msg: "No operation performed",
        code: "NO_CODE",
      );

  /// Creates a successful result with a default success message.
  ///
  /// Use this factory constructor when an operation completes successfully
  /// and you don't need a custom success message.
  factory X509ResValue.success() => X509ResValue(
        isOk: true,
        msg: "Operation completed successfully",
        code: "SUCCESS",
      );

  /// Creates an error result with the specified error code and message.
  ///
  /// [errorCode]: The error code (should match platform-specific error codes)
  /// [errorMessage]: Human-readable description of what went wrong
  factory X509ResValue.error(String errorCode, String errorMessage) =>
      X509ResValue(
        isOk: false,
        msg: errorMessage,
        code: errorCode,
      );

  /// Checks if this result represents a specific error type.
  ///
  /// [errorCode]: The error code to check against
  ///
  /// Returns `true` if this result's code matches the specified error code.
  ///
  /// Example:
  /// ```dart
  /// if (result.hasError(X509ErrorCode.alreadyExist)) {
  ///   print('Certificate already exists');
  /// }
  /// ```
  bool hasError(X509ErrorCode errorCode) {
    return code == errorCode.getString();
  }

  /// Creates a copy of this result with optionally modified values.
  ///
  /// [isOk]: New success status (defaults to current value)
  /// [msg]: New message (defaults to current value)
  /// [code]: New code (defaults to current value)
  ///
  /// Returns a new [X509ResValue] instance with the specified changes.
  X509ResValue copyWith({
    bool? isOk,
    String? msg,
    String? code,
  }) {
    return X509ResValue(
      isOk: isOk ?? this.isOk,
      msg: msg ?? this.msg,
      code: code ?? this.code,
    );
  }

  @override
  String toString() {
    return 'X509ResValue(isOk: $isOk, msg: "$msg", code: "$code")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is X509ResValue &&
        other.isOk == isOk &&
        other.msg == msg &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(isOk, msg, code);
}
