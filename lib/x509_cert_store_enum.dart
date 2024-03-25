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
  alreadyExist;

  String getString() {
    switch (this) {
      case X509ErrorCode.alreadyExist:
        return "2148081669";
      case X509ErrorCode.canceled:
        return "1223";
    }
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
