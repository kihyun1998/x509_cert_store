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

bool AddCertificateToStore(const std::vector<uint8_t>& certificate_der) {
    HCERTSTORE hStore = CertOpenSystemStore(NULL, L"ROOT");
    if (!hStore) {
        return false; // Failed to open the certificate store
    }

    PCCERT_CONTEXT pCertContext = CertCreateCertificateContext(
        X509_ASN_ENCODING | PKCS_7_ASN_ENCODING,
        certificate_der.data(),
        static_cast<DWORD>(certificate_der.size()));

    if (!pCertContext) {
        CertCloseStore(hStore, 0);
        return false; // Failed to create a certificate context
    }

    BOOL result = CertAddCertificateContextToStore(
        hStore,
        pCertContext,
        CERT_STORE_ADD_NEW,
        NULL);

    CertFreeCertificateContext(pCertContext);
    CertCloseStore(hStore, 0);

    return result ? true : false;
}

// static
void X509CertStorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "x509_cert_store",
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
  if(method_call.method_name().compare("addCertificate") == 0){
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    auto it = arguments->find(flutter::EncodableValue("certificate"));

    if (it != arguments->end()) {
      const auto* certificateData = std::get_if<std::vector<uint8_t>>(&it->second);
      if (certificateData && AddCertificateToStore(*certificateData)) {
        result->Success(flutter::EncodableValue(true));
      } else {
        result->Error("CERT_ADD_FAILED", "Failed to add the certificate to the store");
      }
    } else {
      result->Error("INVALID_ARGUMENT", "Missing or invalid certificate data");
    }

  }else if (method_call.method_name().compare("getPlatformVersion") == 0) {
    

    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else {
    result->NotImplemented();
  }
}

}  // namespace x509_cert_store
