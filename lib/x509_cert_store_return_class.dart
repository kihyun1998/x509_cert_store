import 'package:x509_cert_store/x509_cert_store_enum.dart';

class X509ResValue {
  final bool isOk;
  final String msg;
  final String code;
  X509ResValue({
    required this.isOk,
    required this.msg,
    required this.code,
  });

  factory X509ResValue.init() =>
      X509ResValue(isOk: false, msg: "No operation performed", code: "NO_CODE");

  factory X509ResValue.success() => X509ResValue(
      isOk: true, msg: "Operation completed successfully", code: "SUCCESS");

  factory X509ResValue.error(String errorCode, String errorMessage) =>
      X509ResValue(isOk: false, msg: errorMessage, code: errorCode);

  bool hasError(X509ErrorCode errorCode) {
    return code == errorCode.getString();
  }

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
}
