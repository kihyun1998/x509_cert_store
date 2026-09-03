/// Real X.509 certificates used as parser fixtures.
///
/// Both are self-signed with the same subject, so they share an issuer, and
/// were generated with explicit serial numbers so identity comparison has a
/// known expected value:
///
/// ```
/// openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes \
///   -keyout k1.pem -out c1.pem \
///   -subj "/CN=x509 cert store test CA/O=x509 cert store" \
///   -set_serial 0x1234567890
/// ```
///
/// Same issuer, different serial, means the pair must compare as *different*
/// identities - the case that distinguishes real identity comparison from a
/// parser that only reads the issuer.
library;

/// Serial `0x1234567890`, notBefore `2026-09-03T06:20:53Z`.
const String certificateOneBase64 =
    'MIIDSjCCAjKgAwIBAgIFEjRWeJAwDQYJKoZIhvcNAQELBQAwPDEgMB4GA1UEAwwXeDUwOSBjZXJ0IHN0b3JlIHRlc3QgQ0ExGDAWBgNVBAoMD3g1MDkgY2VydCBzdG9yZTAeFw0yNjA5MDMwNjIwNTNaFw0zNjA4MzEwNjIwNTNaMDwxIDAeBgNVBAMMF3g1MDkgY2VydCBzdG9yZSB0ZXN0IENBMRgwFgYDVQQKDA94NTA5IGNlcnQgc3RvcmUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCvrgdNB88YXh7hMH2h2373RqsAg3LjmF4aGp67mmcn9nanof8nrbNQfPZa0fVi/dv8CnStM45YUR7WJ0CjQeRo/TugpsZljxvwwoOyWFluxOUeh2OdDvtSftTNozbtYWV42cBHCCE3M2SHdInCaLoVVSdzuAMv/xmzzkqQy8uxnvtJjRaBwB94WsYME0kptz/Z+QTRjvjU+5F7BaasHTHALMvaXdLdxRpocqec2jr4CG2rOGjUDyE2YYGfhMdOadvbNo0hmmYKvUSeFRmImbhlozYJ8rAFqe5oNpTNqfDMYnzHKMi454pZiIQ3GxwEVv6qnN8jugqZdRBhTQDl6NUxAgMBAAGjUzBRMB0GA1UdDgQWBBQijwRFxt8FQfZHdD6Y3I0CpuEYOTAfBgNVHSMEGDAWgBQijwRFxt8FQfZHdD6Y3I0CpuEYOTAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQA9NgjA2zVkNPwCmZ6hZ0JSoSJ5ayx9jVUkic+hh+0bhhI1AuJ3VO7+ACH2HmL5se/HAfAKS1GClX03qqkcVL0sTr83SNj/ZAU27Sv4g4jlhA6d8d9H24pAcZuX9boKRPELUgIE1DwuVDKOumqjbD7lHMqUw6MOyFcoqo78gm0+6RGKZPDmSGsVzNNBHOK+s5kxHzFKvJNez3+Clco2J+aAfsKkpXN+Qb7CQmCJihUHKypdsDhyf3KpSuEXsqKGelRhrRNkirksrt61KpBrkhvQrNbjOSB1yLfxnw0lPagJEymU5VrCHuT1XRgs8oLOmGl8niFHzN5UFbTHOWXD+gu/';

/// Serial `0x0FEDCBA987`, same issuer and notBefore as [certificateOneBase64].
const String certificateTwoBase64 =
    'MIIDSjCCAjKgAwIBAgIFD+3LqYcwDQYJKoZIhvcNAQELBQAwPDEgMB4GA1UEAwwXeDUwOSBjZXJ0IHN0b3JlIHRlc3QgQ0ExGDAWBgNVBAoMD3g1MDkgY2VydCBzdG9yZTAeFw0yNjA5MDMwNjIwNTNaFw0zNjA4MzEwNjIwNTNaMDwxIDAeBgNVBAMMF3g1MDkgY2VydCBzdG9yZSB0ZXN0IENBMRgwFgYDVQQKDA94NTA5IGNlcnQgc3RvcmUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpNgbdt0BGjVUEQ17wL5SK8HTenoBa8VyqQ1aFo7XzrseDh/15YeVp7hGJ0pCcbyaUxMsqy5mK3Biy3T27xqkCbQLAiQPETxiPIXTuPv3PtnziEEGfMD4UXnZ4wjwlzYCZkyw51hWWspm4jL4sFv2oTGo3BZAgq+ZjcMTR9cLKt5zQ58uiAXoI1Uot3T8JdT/bfERCoZKE8xozjm2Rw1hmiGNfXTmBrKlUyOLHc3ig6eqtB7qMWJEz4oZFecU2piq4GPH1d8RZjSg/6eDidKXp4N4EVBa8ZZs2d7St8Nw22F2wSMR832LFYZQKC9ljWzXZV/LFf2OGXBDwkQwm1BbdAgMBAAGjUzBRMB0GA1UdDgQWBBRLup54uc0dB3BQkWm7dHqDexze/jAfBgNVHSMEGDAWgBRLup54uc0dB3BQkWm7dHqDexze/jAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQA37mrbEMQ8/nLYqpoa8L/pxbAhnjaYmOijZ6ECdPf6xN8sSdw4n+s8fYb4Y782ksSbbcN/5Fa90+mo0nGOShiMp7osytdiBolukKYmvVe+EbQBF5p7hvpm5E+icJPZsk2zl2GZaAT/17bfdycr6Q5C3gQkbFuh4fmXXXpkJiKy77cydi0hs0sz4MUho3Alezrh7ggI+OFbLEiU+xcoVmzM38oj0MOgXqlNNN0rTdLdW+jg7r0n0JXkUHqBKog3LfzA+mWn+X6BAE/+C4pR8mMVqrR1lDNxAAJk9GcI4aqZ2BrWsd6+6TXrux2xsfh1mD1XMBZefvwyIU7umZyj/fip';

/// `certificateOneBase64` serial number, as the DER INTEGER content octets.
const List<int> certificateOneSerial = [0x12, 0x34, 0x56, 0x78, 0x90];

/// `certificateTwoBase64` serial number.
const List<int> certificateTwoSerial = [0x0F, 0xED, 0xCB, 0xA9, 0x87];

/// The `notBefore` both fixtures carry.
final DateTime certificateNotBefore = DateTime.utc(2026, 9, 3, 6, 20, 53);
