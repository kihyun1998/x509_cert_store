---
status: accepted
---

# The test suite stops at the backend seam

`dart test` substitutes a fake `X509CertStoreBackend`, and the FFI symbol tests
only resolve bindings (and call `GetLastError`). Nothing in CI reaches a
certificate store, so a green run proves less than it reads as:

- `test/x509_cert_store_test.dart` proves normalization above the seam and that
  results pass through unchanged. It proves nothing about which `DWORD` or
  `OSStatus` a real store returns, or that a platform mapping assigns it the
  right category: the fake returns whatever category the test wrote.
- `test/*_ffi_symbols_test.dart` proves a symbol loads, not that the call is
  right. The parts that can do real damage — installing into the Windows `ROOT`
  store, deleting a certificate on the replace/newer path, elevating through
  `security add-trusted-cert` — are untested by construction.
- `example/integration_test/` is run by no CI job.
- The macOS backend runs only on the macOS CI job; the Windows dev host cannot
  execute it, so its red is visible only after a push.

A change to store interaction therefore needs a run against a real store, not
just a green suite.

Precedent: before 3.0.0 the template `RunnerTests` called `getPlatformVersion`,
a method this plugin never implemented, and passed (replaced in `d3b414b`).
