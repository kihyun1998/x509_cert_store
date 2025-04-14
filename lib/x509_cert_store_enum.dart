enum X509StoreName {
  root,
  my;

  String getString() {
    switch (this) {
      case X509StoreName.root:
        return "ROOT";
      case X509StoreName.my:
        return "MY";
    }
  }
}

enum X509ErrorCode {
  canceled,
  alreadyExist,
  unknown;

  String getString() {
    switch (this) {
      case X509ErrorCode.alreadyExist:
        return "2148081669"; // CRYPT_E_EXISTS
      case X509ErrorCode.canceled:
        return "1223"; // ERROR_CANCELLED
      case X509ErrorCode.unknown:
        return "UNKNOWN";
    }
  }

  static X509ErrorCode fromString(String code) {
    for (var value in X509ErrorCode.values) {
      if (value.getString() == code) {
        return value;
      }
    }
    return X509ErrorCode.unknown;
  }
}

enum X509AddType {
  addNew, // CERT_STORE_ADD_NEW, 1
  addNewer, // CERT_STORE_ADD_NEWER, 6
  addReplaceExisting; // CERT_STORE_ADD_REPLACE_EXISTING, 3

  int getCode() {
    switch (this) {
      case X509AddType.addNew:
        return 1;
      case X509AddType.addNewer:
        return 6;
      case X509AddType.addReplaceExisting:
        return 3;
    }
  }
}
