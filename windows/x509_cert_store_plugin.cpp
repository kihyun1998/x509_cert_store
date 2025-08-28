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

// for send error
void SendErrorResponse(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result,
    const std::string& error_code, 
    const std::string& error_message, 
    DWORD win_error_code = 0) {
  std::stringstream error_details;
  error_details << error_message;
  
  if (win_error_code != 0) {
    error_details << " Error code: " << win_error_code;
  }
  
  result->Error(error_code, error_details.str());
}

// pem to der
std::vector<BYTE> ConvertPemToDer(const std::vector<BYTE>& inputData) {
  std::string pemCert(inputData.begin(), inputData.end());

  // Find the PEM header and footer
  auto beginPos = pemCert.find("-----BEGIN CERTIFICATE-----");
  auto endPos = pemCert.find("-----END CERTIFICATE-----");

  if (beginPos != std::string::npos && endPos != std::string::npos) {
    beginPos += strlen("-----BEGIN CERTIFICATE-----");

    // Extract the base64 encoded section
    std::string base64Cert = pemCert.substr(beginPos, endPos - beginPos);
    base64Cert.erase(std::remove(base64Cert.begin(), base64Cert.end(), '\n'), base64Cert.end());
    base64Cert.erase(std::remove(base64Cert.begin(), base64Cert.end(), '\r'), base64Cert.end());
    base64Cert.erase(std::remove(base64Cert.begin(), base64Cert.end(), ' '), base64Cert.end());

    // Convert base64 string to binary data
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

  return inputData;  // Return original if not PEM
}

// add cert func
// Note: setTrusted parameter is not supported on Windows - certificates added to ROOT store are automatically trusted
bool AddCertificateToStore(
    const std::string& storeName, 
    std::vector<BYTE>& certificateData, 
    int addType,
    std::string& errorCode,
    std::string& errorMessage) {
  
  // 1. open store
  HCERTSTORE hStore = CertOpenSystemStoreA(NULL, storeName.c_str());
  if (!hStore) {
    DWORD dwError = GetLastError();
    errorCode = "CERT_OPEN_FAILED";
    errorMessage = "Failed to open certificate store. Error code: " + std::to_string(dwError);
    return false;
  }
  
  // 2. return
  if (certificateData[0] != 0x30) {
    certificateData = ConvertPemToDer(certificateData);
    if(certificateData.empty()){
      errorCode = "INVALID_FORMAT";
      errorMessage = "Failed to convert PEM to DER format.";
      CertCloseStore(hStore, 0);
      return false;
    }
  }
  
  // 3. create context
  PCCERT_CONTEXT pCertContext = CertCreateCertificateContext(
      X509_ASN_ENCODING | PKCS_7_ASN_ENCODING,
      certificateData.data(),
      static_cast<DWORD>(certificateData.size()));
      
  if (!pCertContext) {
    DWORD dwError = GetLastError();
    errorCode = "CONTEXT_CREATE_FAILED";
    errorMessage = "Failed to create certificate context. Error code: " + std::to_string(dwError);
    CertCloseStore(hStore, 0);
    return false;
  }
  
  // 4. add cert
  BOOL result = CertAddCertificateContextToStore(
    hStore,
    pCertContext,
    addType,
    NULL
  );
  
  // 5. free
  CertFreeCertificateContext(pCertContext);
  CertCloseStore(hStore, 0);
  
  if (!result) {
    DWORD dwError = GetLastError();
    errorCode = "CERT_ADD_FAILED";
    errorMessage = "Failed to add certificate to store. Error code: " + std::to_string(dwError);
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
  
  // check method name
  if(method_call.method_name() == "addCertificate") {
    try {
      const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
      
      // check required argument
      if (!arguments) {
        SendErrorResponse(result, "INVALID_ARGUMENT", "Missing or invalid arguments");
        return;
      }
      
      // check required key
      auto storeNameIter = arguments->find(flutter::EncodableValue("storeName"));
      auto certificateIter = arguments->find(flutter::EncodableValue("certificate"));
      auto addTypeIter = arguments->find(flutter::EncodableValue("addType"));
      
      if (storeNameIter == arguments->end() || 
          certificateIter == arguments->end() || 
          addTypeIter == arguments->end()) {
        SendErrorResponse(result, "INVALID_ARGUMENT", "Missing required parameters");
        return;
      }
      
      // check type
      if (!std::holds_alternative<std::string>(storeNameIter->second) || 
          !std::holds_alternative<std::vector<uint8_t>>(certificateIter->second) ||
          !std::holds_alternative<int>(addTypeIter->second)) {
        SendErrorResponse(result, "INVALID_ARGUMENT", "Parameters have incorrect type");
        return;
      }
     
      auto storeName = std::get<std::string>(storeNameIter->second);
      auto certificate = std::get<std::vector<uint8_t>>(certificateIter->second);
      auto addType = std::get<int>(addTypeIter->second);
      
      // Note: setTrusted parameter is ignored on Windows - ROOT store certificates are automatically trusted
      
      // add certificate
      std::string errorCode, errorMessage;
      bool success = AddCertificateToStore(storeName, certificate, addType, errorCode, errorMessage);
      
      if (success) {
        result->Success(flutter::EncodableValue(true));
      } else {
        SendErrorResponse(result, errorCode, errorMessage);
      }
      
    } catch(const std::runtime_error& e) {
      SendErrorResponse(result, "RUNTIME_ERROR", e.what(), GetLastError());
    } catch(...) {
      SendErrorResponse(result, "UNKNOWN_ERROR", "Unknown error occurred", GetLastError());
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace x509_cert_store