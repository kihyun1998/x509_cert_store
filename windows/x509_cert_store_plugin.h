#ifndef FLUTTER_PLUGIN_X509_CERT_STORE_PLUGIN_H_
#define FLUTTER_PLUGIN_X509_CERT_STORE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace x509_cert_store {

class X509CertStorePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  X509CertStorePlugin();

  virtual ~X509CertStorePlugin();

  // Disallow copy and assign.
  X509CertStorePlugin(const X509CertStorePlugin&) = delete;
  X509CertStorePlugin& operator=(const X509CertStorePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace x509_cert_store

#endif  // FLUTTER_PLUGIN_X509_CERT_STORE_PLUGIN_H_
