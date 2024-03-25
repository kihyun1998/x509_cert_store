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
