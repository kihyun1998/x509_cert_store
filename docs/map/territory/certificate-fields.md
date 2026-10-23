# certificate-fields

## What it is
A deliberately small DER reader and the three certificate fields read with it
— issuer, serial number, `notBefore` — which give the macOS backend its
certificate identity and its "newer" test.

## Governing decisions
**None.** CHANGELOG 3.0.0 records why the fields are parsed in Dart rather than read through Security APIs; no decision record covers it.

## Design model
From the source:
- `Der.read` and `Der.childrenOf` return `null` instead of throwing, because
  malformed certificates are expected input. They reject indefinite length,
  high-tag-number form, lengths over 4 octets, and any element that overruns
  its buffer or parent.
- `CertificateFields.parse` walks only to `validity`; subject, extensions and
  signature are never read. `version` is optional and shifts the field
  indices by one when present.
- Identity is (issuer, serial): the issuer's full DER encoding and the serial
  INTEGER's content octets, compared byte for byte
  (`CertificateFields.hasSameIdentityAs`). It is not RFC name-normalized;
  `MIGRATION.md` names the one case where that differs from 2.x.
- `notBefore` accepts UTCTime and GeneralizedTime ending in `Z` only;
  UTCTime years of 50 and above are 19YY.
- The only caller is the macOS backend (`grep -rn CertificateFields lib`).

Input: bounded by the buffer — every length is checked against it before use.

## Code
- `lib/src/asn1/der.dart` — `DerElement`, `Der.read`, `Der.childrenOf`.
- `lib/src/asn1/certificate_fields.dart` — `CertificateFields.parse`, `CertificateFields.hasSameIdentityAs`, `CertificateFields._parseTime`.

## Reference behaviour
- `wincrypt.h` (10.0.19041.0) — `CertGetSubjectCertificateFromStore` identifies a certificate by Issuer and SerialNumber, the identity this note reproduces for macOS.

## Cross-cutting invariants
- [wincrypt disposition parity](../invariant/wincrypt-disposition-parity.md)

## Blast radius
- [macos-keychain](macos-keychain.md) — identity and `notBefore` decide which disposition branch runs, and `parse` returning `null` is its `invalidFormat`.
- [verification](verification.md) — `test/certificate_fields_test.dart` is the only place this logic is exercised on every host.

## Known holes / open
- Whether wincrypt compares issuer names byte for byte, as this does, was not checked.
