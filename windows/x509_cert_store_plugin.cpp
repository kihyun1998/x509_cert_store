#include "x509_cert_store_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <wincrypt.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <vector>

using flutter::EncodableMap;
using flutter::EncodableValue;

namespace x509_cert_store {
// static
void X509CertStorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "io.github.kihyun1998/cert_installer",
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
  
  // Check method channel's name
  if(method_call.method_name().compare("addCertificate") == 0){
    try{
      const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());

      // Check arguments are exist storeName & certificate
      if ((arguments->find(flutter::EncodableValue("storeName")) != arguments->end()) && 
      (arguments->find(flutter::EncodableValue("certificate")) != arguments->end()) &&
      (arguments->find(flutter::EncodableValue("addType")) != arguments->end())) {

        
        auto& storeNameValue = arguments->at(flutter::EncodableValue("storeName"));
        auto& certificateValue = arguments->at(flutter::EncodableValue("certificate"));
        auto& addTypeValue = arguments->at(flutter::EncodableValue("addType"));
        
        // Check arguments type's are correct
        if((std::holds_alternative<std::string>(storeNameValue)) && 
        (std::holds_alternative<std::vector<uint8_t>>(certificateValue)) &&
        (std::holds_alternative<int>(addTypeValue))){

          // If arguments type's are correct
          auto storeNameData = std::get<std::string>(storeNameValue);
          auto certificateData = std::get<std::vector<uint8_t>>(certificateValue);
          auto addTypeData = std::get<int>(addTypeValue);

          HCERTSTORE hStore = CertOpenSystemStoreA(NULL, storeNameData.c_str());
          
          if (certificateData[0] != 0x30) {
              std::stringstream errorDetails;
              errorDetails << "The certificate data does not appear to be in valid DER format.";
              result->Error("INVALID_FORMAT", errorDetails.str());
              return;
          }


          if (!hStore) {
            DWORD dwError = GetLastError();
            std::stringstream ss;
            ss << dwError;
            result->Error("CERT_OPEN_FAILED", ss.str());
          }


          PCCERT_CONTEXT pCertContext = CertCreateCertificateContext(
              X509_ASN_ENCODING | PKCS_7_ASN_ENCODING,
              certificateData.data(),
              static_cast<DWORD>(certificateData.size()));

          if (!pCertContext) {
            DWORD dwError = GetLastError();
            std::stringstream errorDetails;
            errorDetails << "Failed to create a certificate context. Error code : " << dwError;
            CertCloseStore(hStore, 0);
            result->Error("CONTEXT_CREATE_FAILED",errorDetails.str());
            return;
          }

          BOOL rst = CertAddCertificateContextToStore(
              hStore,
              pCertContext,
              addTypeData,
              NULL
          );

          CertFreeCertificateContext(pCertContext);
          CertCloseStore(hStore, 0);

          if(!rst){
            DWORD dwError = GetLastError();
            std::stringstream errorDetails;
            errorDetails << "Failed to add the certificate to the store. Error code : " << dwError;
            result->Error("CERT_ADD_FAILED", errorDetails.str());
            return;
          }

          result->Success(flutter::EncodableValue(true)); 

        }
        else {
          DWORD dwError = GetLastError();
          std::stringstream errorDetails;
          errorDetails << "Failed to add the certificate to the store. Error code : " << dwError;
          result->Error("CERT_ADD_FAILED", errorDetails.str());
          return;
        }
      } else {
        DWORD dwError = GetLastError();
        std::stringstream errorDetails;
        errorDetails << "Missing or invalid certificate data. : " << dwError;
        result->Error("INVALID_ARGUMENT", errorDetails.str());
        return;
      }
    }catch(const std::runtime_error& e){
      DWORD dwError = GetLastError();
      std::stringstream errorDetails;
      errorDetails << "run time error : " << e.what() << "Error Code :" << dwError;
      result->Error("RUNTIME_ERROR", errorDetails.str());
      return;
    }catch(...){
      DWORD dwError = GetLastError();
      std::stringstream errorDetails;
      errorDetails << "Unknow error occurred. Error Code :" << dwError;
      result->Error("UNKNOWN_ERROR", errorDetails.str());
      return;
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace x509_cert_store
