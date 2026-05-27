#include "x509_cert_store_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <wincrypt.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <vector>

using flutter::EncodableMap;
using flutter::EncodableValue;

namespace x509_cert_store {

// Send an error response on the method channel.
//
// For the v2.0.0 baseline, callers always pass `error_code` as "unknown";
// the categorical mapping (alreadyExist / canceled / accessDenied /
// invalidFormat) is filled in by a follow-up slice. The raw Win32 error
// (`win_error_code`) is forwarded to Dart via the `nativeCode` field on
// `details`, where it surfaces as `X509Failure.nativeCode`.
void SendErrorResponse(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result,
    const std::string& error_code,
    const std::string& error_message,
    DWORD win_error_code = 0) {
  EncodableMap details;
  if (win_error_code != 0) {
    details[EncodableValue("nativeCode")] =
        EncodableValue(static_cast<int64_t>(win_error_code));
  } else {
    details[EncodableValue("nativeCode")] = EncodableValue();  // null
  }
  result->Error(error_code, error_message, EncodableValue(details));
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
// On failure, `errorMessage` carries diagnostic text and `nativeCode`
// carries the raw Win32 error (0 when no native error applies). The error
// category is not set here — callers always use "unknown" for the v2.0.0
// baseline; a follow-up slice introduces a categorical mapping function.
//
// Note: setTrusted is not supported on Windows — certificates added to the
// ROOT store are automatically trusted by the system.
bool AddCertificateToStore(
    const std::string& storeName,
    std::vector<BYTE>& certificateData,
    int addType,
    std::string& errorMessage,
    DWORD& nativeCode) {
  nativeCode = 0;

  HCERTSTORE hStore = CertOpenSystemStoreA(NULL, storeName.c_str());
  if (!hStore) {
    nativeCode = GetLastError();
    errorMessage = "Failed to open certificate store (Win32 error " + std::to_string(nativeCode) + ")";
    return false;
  }

  if (certificateData[0] != 0x30) {
    certificateData = ConvertPemToDer(certificateData);
    if (certificateData.empty()) {
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

      std::string errorMessage;
      DWORD nativeCode = 0;
      bool success = AddCertificateToStore(storeName, certificate, addType, errorMessage, nativeCode);

      if (success) {
        result->Success(flutter::EncodableValue(true));
      } else {
        SendErrorResponse(result, "unknown", errorMessage, nativeCode);
      }

    } catch (const std::runtime_error& e) {
      SendErrorResponse(result, "unknown", e.what(), GetLastError());
    } catch (...) {
      SendErrorResponse(result, "unknown", "Unknown error occurred", GetLastError());
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace x509_cert_store
