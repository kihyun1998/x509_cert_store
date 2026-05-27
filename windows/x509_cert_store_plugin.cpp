#include "x509_cert_store_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <wincrypt.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <optional>
#include <sstream>
#include <vector>

using flutter::EncodableMap;
using flutter::EncodableValue;

namespace x509_cert_store {

// Map a Win32 / wincrypt errcode to an X509ErrorCode category key.
//
// Returns std::nullopt for unmapped codes — the failure then surfaces as
// "unknown" with nativeCode preserved for diagnostics.
std::optional<std::string> MapWinErrorToCategory(DWORD code) {
  switch (code) {
    case CRYPT_E_EXISTS:       // 0x80092005 (2148081669)
      return "alreadyExist";
    case ERROR_CANCELLED:      // 1223
      return "canceled";
    case ERROR_ACCESS_DENIED:  // 5
      return "accessDenied";
    default:
      return std::nullopt;
  }
}

// Choose the category key from a raw Win32 errcode. Always returns a
// non-empty key — unmapped errors collapse to "unknown".
std::string CategoryFromWinError(DWORD code) {
  return MapWinErrorToCategory(code).value_or("unknown");
}

// Send an error response on the method channel.
//
// `category` is one of the X509ErrorCode keys ("canceled" / "alreadyExist"
// / "accessDenied" / "invalidFormat" / "unknown"). `details.nativeCode` is
// populated only when `category == "unknown"` and a raw Win32 errcode
// applies — for matched categories it is null, since the consumer already
// gets the typed enum value.
void SendErrorResponse(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result,
    const std::string& category,
    const std::string& error_message,
    DWORD win_error_code = 0) {
  EncodableMap details;
  if (category == "unknown" && win_error_code != 0) {
    details[EncodableValue("nativeCode")] =
        EncodableValue(static_cast<int64_t>(win_error_code));
  } else {
    details[EncodableValue("nativeCode")] = EncodableValue();  // null
  }
  result->Error(category, error_message, EncodableValue(details));
}

// Convert a PEM-encoded certificate to DER. Returns empty vector on failure.
std::vector<BYTE> ConvertPemToDer(const std::vector<BYTE>& inputData) {
  std::string pemCert(inputData.begin(), inputData.end());

  auto beginPos = pemCert.find("-----BEGIN CERTIFICATE-----");
  auto endPos = pemCert.find("-----END CERTIFICATE-----");

  if (beginPos != std::string::npos && endPos != std::string::npos) {
    beginPos += strlen("-----BEGIN CERTIFICATE-----");

    std::string base64Cert = pemCert.substr(beginPos, endPos - beginPos);
    base64Cert.erase(std::remove(base64Cert.begin(), base64Cert.end(), '\n'), base64Cert.end());
    base64Cert.erase(std::remove(base64Cert.begin(), base64Cert.end(), '\r'), base64Cert.end());
    base64Cert.erase(std::remove(base64Cert.begin(), base64Cert.end(), ' '), base64Cert.end());

    DWORD binarySize = 0;
    if (!CryptStringToBinaryA(base64Cert.c_str(), 0, CRYPT_STRING_BASE64, NULL, &binarySize, NULL, NULL)) {
      return {};
    }

    std::vector<BYTE> derData(binarySize, 0);
    if (!CryptStringToBinaryA(base64Cert.c_str(), 0, CRYPT_STRING_BASE64, derData.data(), &binarySize, NULL, NULL)) {
      return {};
    }

    return derData;
  }

  return inputData;  // not PEM, assume DER
}

// Add a certificate to the named store.
//
// On failure, the caller receives:
// - `category`: the X509ErrorCode key (e.g. "alreadyExist", "invalidFormat", "unknown")
// - `errorMessage`: human-readable diagnostic text
// - `nativeCode`: the raw Win32 error (0 when no native error applies, e.g.
//   the PEM/DER conversion path)
//
// Note: setTrusted is not supported on Windows — ROOT store certs are
// automatically trusted by the system.
bool AddCertificateToStore(
    const std::string& storeName,
    std::vector<BYTE>& certificateData,
    int addType,
    std::string& category,
    std::string& errorMessage,
    DWORD& nativeCode) {
  category = "unknown";
  nativeCode = 0;

  HCERTSTORE hStore = CertOpenSystemStoreA(NULL, storeName.c_str());
  if (!hStore) {
    nativeCode = GetLastError();
    category = CategoryFromWinError(nativeCode);
    errorMessage = "Failed to open certificate store (Win32 error " + std::to_string(nativeCode) + ")";
    return false;
  }

  if (certificateData[0] != 0x30) {
    certificateData = ConvertPemToDer(certificateData);
    if (certificateData.empty()) {
      category = "invalidFormat";
      errorMessage = "Failed to convert PEM to DER format";
      CertCloseStore(hStore, 0);
      return false;
    }
  }

  PCCERT_CONTEXT pCertContext = CertCreateCertificateContext(
      X509_ASN_ENCODING | PKCS_7_ASN_ENCODING,
      certificateData.data(),
      static_cast<DWORD>(certificateData.size()));

  if (!pCertContext) {
    nativeCode = GetLastError();
    category = CategoryFromWinError(nativeCode);
    errorMessage = "Failed to create certificate context (Win32 error " + std::to_string(nativeCode) + ")";
    CertCloseStore(hStore, 0);
    return false;
  }

  BOOL result = CertAddCertificateContextToStore(
      hStore,
      pCertContext,
      addType,
      NULL);

  CertFreeCertificateContext(pCertContext);
  CertCloseStore(hStore, 0);

  if (!result) {
    nativeCode = GetLastError();
    category = CategoryFromWinError(nativeCode);
    errorMessage = "Failed to add certificate to store (Win32 error " + std::to_string(nativeCode) + ")";
    return false;
  }

  return true;
}

// static
void X509CertStorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "io.github.kihyun1998/x509_cert_store",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<X509CertStorePlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

X509CertStorePlugin::X509CertStorePlugin() {}

X509CertStorePlugin::~X509CertStorePlugin() {}

void X509CertStorePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

  if (method_call.method_name() == "addCertificate") {
    try {
      const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());

      if (!arguments) {
        SendErrorResponse(result, "unknown", "Missing or invalid arguments");
        return;
      }

      auto storeNameIter = arguments->find(flutter::EncodableValue("storeName"));
      auto certificateIter = arguments->find(flutter::EncodableValue("certificate"));
      auto addTypeIter = arguments->find(flutter::EncodableValue("addType"));

      if (storeNameIter == arguments->end() ||
          certificateIter == arguments->end() ||
          addTypeIter == arguments->end()) {
        SendErrorResponse(result, "unknown", "Missing required parameters");
        return;
      }

      if (!std::holds_alternative<std::string>(storeNameIter->second) ||
          !std::holds_alternative<std::vector<uint8_t>>(certificateIter->second) ||
          !std::holds_alternative<int>(addTypeIter->second)) {
        SendErrorResponse(result, "unknown", "Parameters have incorrect type");
        return;
      }

      auto storeName = std::get<std::string>(storeNameIter->second);
      auto certificate = std::get<std::vector<uint8_t>>(certificateIter->second);
      auto addType = std::get<int>(addTypeIter->second);

      std::string category, errorMessage;
      DWORD nativeCode = 0;
      bool success = AddCertificateToStore(
          storeName, certificate, addType, category, errorMessage, nativeCode);

      if (success) {
        result->Success(flutter::EncodableValue(true));
      } else {
        SendErrorResponse(result, category, errorMessage, nativeCode);
      }

    } catch (const std::runtime_error& e) {
      DWORD code = GetLastError();
      SendErrorResponse(result, CategoryFromWinError(code), e.what(), code);
    } catch (...) {
      DWORD code = GetLastError();
      SendErrorResponse(result, CategoryFromWinError(code), "Unknown error occurred", code);
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace x509_cert_store
