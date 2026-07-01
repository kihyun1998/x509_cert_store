#ifndef FLUTTER_PLUGIN_X509_CERT_STORE_CATEGORIES_H_
#define FLUTTER_PLUGIN_X509_CERT_STORE_CATEGORIES_H_

#include <windows.h>

#include <optional>
#include <string>

namespace x509_cert_store {

// The X509ErrorCode category keys sent over the method channel. These strings
// are the wire contract shared with the Dart and Swift layers; keep them in
// sync with lib/src/x509_cert_store_method_channel.dart and
// macos/Classes/CategoryKeys.swift.
namespace category {
constexpr char kCanceled[] = "canceled";
constexpr char kAlreadyExist[] = "alreadyExist";
constexpr char kAccessDenied[] = "accessDenied";
constexpr char kInvalidFormat[] = "invalidFormat";
constexpr char kUnknown[] = "unknown";
}  // namespace category

// Map a Win32 / wincrypt errcode to a category key, or std::nullopt if the code
// is unmapped.
std::optional<std::string> MapWinErrorToCategory(DWORD code);

// Category key for a Win32 errcode; unmapped codes collapse to category::kUnknown.
std::string CategoryFromWinError(DWORD code);

}  // namespace x509_cert_store

#endif  // FLUTTER_PLUGIN_X509_CERT_STORE_CATEGORIES_H_
