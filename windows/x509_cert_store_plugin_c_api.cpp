#include "include/x509_cert_store/x509_cert_store_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "x509_cert_store_plugin.h"

void X509CertStorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  x509_cert_store::X509CertStorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
