#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>
#include <windows.h>
#include <wincrypt.h>

#include <memory>
#include <string>
#include <variant>
#include <vector>

#include "x509_cert_store_categories.h"
#include "x509_cert_store_plugin.h"

namespace x509_cert_store {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResultFunctions;

}  // namespace

// An unknown method name must be reported as not-implemented, not silently
// swallowed. Exercises the plugin's method dispatch without touching the
// certificate store.
TEST(X509CertStorePlugin, UnknownMethodReturnsNotImplemented) {
  X509CertStorePlugin plugin;

  bool not_implemented = false;
  plugin.HandleMethodCall(
      MethodCall("thisMethodDoesNotExist", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          nullptr, nullptr,
          [&not_implemented]() { not_implemented = true; }));

  EXPECT_TRUE(not_implemented);
}

// Regression: an empty certificate (empty base64 on the Dart side decodes to
// an empty byte vector) must be rejected as invalidFormat, not dereferenced.
// The emptiness guard returns before opening a system store, so this test is
// hermetic - it never touches the real certificate store.
TEST(X509CertStorePlugin, AddCertificateRejectsEmptyData) {
  X509CertStorePlugin plugin;

  EncodableMap args;
  args[EncodableValue("storeName")] = EncodableValue("MY");
  args[EncodableValue("certificate")] = EncodableValue(std::vector<uint8_t>{});
  args[EncodableValue("addType")] = EncodableValue(1);

  std::string error_code;
  bool got_success = false;
  plugin.HandleMethodCall(
      MethodCall("addCertificate", std::make_unique<EncodableValue>(args)),
      std::make_unique<MethodResultFunctions<>>(
          [&got_success](const EncodableValue*) { got_success = true; },
          [&error_code](const std::string& code, const std::string&,
                        const EncodableValue*) { error_code = code; },
          nullptr));

  EXPECT_FALSE(got_success);
  EXPECT_EQ(error_code, "invalidFormat");
}

// addCertificate with non-map arguments is rejected as "unknown" without
// touching the certificate store.
TEST(X509CertStorePlugin, AddCertificateRejectsMissingArguments) {
  X509CertStorePlugin plugin;

  std::string error_code;
  bool got_success = false;
  plugin.HandleMethodCall(
      MethodCall("addCertificate", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          [&got_success](const EncodableValue*) { got_success = true; },
          [&error_code](const std::string& code, const std::string&,
                        const EncodableValue*) { error_code = code; },
          nullptr));

  EXPECT_FALSE(got_success);
  EXPECT_EQ(error_code, "unknown");
}

// The category keys are the wire contract shared with the Dart and Swift
// layers. Assert against the literal strings (not the category:: constants) so
// a typo in either a constant or the mapping is caught, rather than comparing a
// value to itself.
TEST(X509CertStoreCategories, MapsKnownWin32ErrorsToWireKeys) {
  // CRYPT_E_EXISTS is an HRESULT; cast to DWORD to avoid a signed/unsigned
  // conversion warning (treated as an error under /WX).
  EXPECT_EQ(CategoryFromWinError(static_cast<DWORD>(CRYPT_E_EXISTS)),
            "alreadyExist");
  EXPECT_EQ(CategoryFromWinError(static_cast<DWORD>(ERROR_CANCELLED)),
            "canceled");
  EXPECT_EQ(CategoryFromWinError(static_cast<DWORD>(ERROR_ACCESS_DENIED)),
            "accessDenied");
}

TEST(X509CertStoreCategories, UnmappedWin32ErrorCollapsesToUnknown) {
  EXPECT_FALSE(
      MapWinErrorToCategory(static_cast<DWORD>(ERROR_INVALID_HANDLE))
          .has_value());
  EXPECT_EQ(CategoryFromWinError(static_cast<DWORD>(ERROR_INVALID_HANDLE)),
            "unknown");
}

TEST(X509CertStoreCategories, ConstantsMatchWireContract) {
  EXPECT_EQ(std::string(category::kCanceled), "canceled");
  EXPECT_EQ(std::string(category::kAlreadyExist), "alreadyExist");
  EXPECT_EQ(std::string(category::kAccessDenied), "accessDenied");
  EXPECT_EQ(std::string(category::kInvalidFormat), "invalidFormat");
  EXPECT_EQ(std::string(category::kUnknown), "unknown");
}

}  // namespace test
}  // namespace x509_cert_store
