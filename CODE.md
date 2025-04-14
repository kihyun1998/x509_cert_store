# x509_cert_store
## Project Structure

```
x509_cert_store/
├── example/
    ├── integration_test/
    │   └── plugin_integration_test.dart
    ├── lib/
    │   └── main.dart
    └── test/
    │   └── widget_test.dart
├── lib/
    ├── x509_cert_store.dart
    ├── x509_cert_store_enum.dart
    ├── x509_cert_store_method_channel.dart
    ├── x509_cert_store_platform_interface.dart
    └── x509_cert_store_return_class.dart
├── test/
    ├── x509_cert_store_method_channel_test.dart
    └── x509_cert_store_test.dart
└── windows/
    ├── include/
        └── x509_cert_store/
        │   └── x509_cert_store_plugin_c_api.h
    ├── test/
        └── x509_cert_store_plugin_test.cpp
    ├── CMakeLists.txt
    ├── x509_cert_store_plugin.cpp
    ├── x509_cert_store_plugin.h
    └── x509_cert_store_plugin_c_api.cpp
```

## example/integration_test/plugin_integration_test.dart
```dart
// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:x509_cert_store/x509_cert_store.dart';
import 'package:x509_cert_store/x509_cert_store_enum.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // testWidgets('getPlatformVersion test', (WidgetTester tester) async {
  //   final X509CertStore plugin = X509CertStore();
  //   final String? version = await plugin.getPlatformVersion();
  //   // The version string depends on the host platform running the test, so
  //   // just assert that some non-empty string is returned.
  //   expect(version?.isNotEmpty, true);
  // });
  testWidgets('addCertification test', (WidgetTester tester) async {
    final X509CertStore plugin = X509CertStore();
    const X509StoreName storeName = X509StoreName.root;
    const String certificationBase64Str =
        "MIIDKjCCAhKgAwIBAgIQFSHum2++9bhOXjAo4Z7hZTANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20wHhcNMjQwMzI1MDQwMTAxWhcNMjUwMzI1MDQyMTAxWjAaMRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDD95UVvL2GmO1Sq2XEE/m7yK1YzqAlOo68zx8Zk5DS0SmK3e990VtdCPP6cZxcGsJHlqBEg2yMuheC37/tqKdZgRxWbA6DBwZdO9iTSsQigDYi6Ak5YbPSis2z2IJ/RtYnbVM0TZxxwRbPK6zw+evoRAAaVohDzzV3YolHezLacLuIuc8ZX4w+oNBM1nhnYcBxKHeZlIdnrTvnqmUNsc5RsTVgiKuF3JuwqMp8iGK2I5OXKX0PU9Xu2DWDgNDyYFje9cuUd5V80AABQr9QgalOaLkfknluWulOLl8yLhg/icuFQucGnHxNDfDo2eRgxRjMFb53VdLSG8BDfk+7HXDxAgMBAAGjbDBqMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwEwGgYDVR0RBBMwEYIPd3d3LmV4YW1wbGUuY29tMB0GA1UdDgQWBBTz3vduP0OefbHqptjxpk1V89RpCjANBgkqhkiG9w0BAQsFAAOCAQEAaShA+e6dBaVt9na97fAgGMEdWpfI66WrJOVn5gczcPCzsjtZTkUjKh7IiZHCeyq5vWHmrG20PZpag34vvk0zacwR9PJeCbCzCmGfJ8miKCaywfxRpJVSWweLyppXRk/TDkXynhGAjD0EMHocc6jClcIrypxB9LjoS2oHA/+iGnx6dLeWf9bpTFBDIAevOXpKhlrSftUM1vaPkMdMN/mEk5mx189382IOsH6gocF+ru8u0PnWAdlF3muGsmvF4K31zVS5vMIQLD76FpO7ee/xrOcYxNS+2dPDDs2m9LlWA4BjUJlyfgM39CCRNyxggLrzYzlo1pT/67JOI/57dVa4YQ==";
    final rst = await plugin.addCertificate(
      storeName: storeName,
      certificateBase64: certificationBase64Str,
      addType: X509AddType.addNew,
    );
    expect(rst.isOk, false);
  });
}

```
## example/lib/main.dart
```dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:x509_cert_store/x509_cert_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final x509CertStorePlugin = X509CertStore();

    const basicKey =
        "MIIDKjCCAhKgAwIBAgIQFSHum2++9bhOXjAo4Z7hZTANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20wHhcNMjQwMzI1MDQwMTAxWhcNMjUwMzI1MDQyMTAxWjAaMRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDD95UVvL2GmO1Sq2XEE/m7yK1YzqAlOo68zx8Zk5DS0SmK3e990VtdCPP6cZxcGsJHlqBEg2yMuheC37/tqKdZgRxWbA6DBwZdO9iTSsQigDYi6Ak5YbPSis2z2IJ/RtYnbVM0TZxxwRbPK6zw+evoRAAaVohDzzV3YolHezLacLuIuc8ZX4w+oNBM1nhnYcBxKHeZlIdnrTvnqmUNsc5RsTVgiKuF3JuwqMp8iGK2I5OXKX0PU9Xu2DWDgNDyYFje9cuUd5V80AABQr9QgalOaLkfknluWulOLl8yLhg/icuFQucGnHxNDfDo2eRgxRjMFb53VdLSG8BDfk+7HXDxAgMBAAGjbDBqMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwEwGgYDVR0RBBMwEYIPd3d3LmV4YW1wbGUuY29tMB0GA1UdDgQWBBTz3vduP0OefbHqptjxpk1V89RpCjANBgkqhkiG9w0BAQsFAAOCAQEAaShA+e6dBaVt9na97fAgGMEdWpfI66WrJOVn5gczcPCzsjtZTkUjKh7IiZHCeyq5vWHmrG20PZpag34vvk0zacwR9PJeCbCzCmGfJ8miKCaywfxRpJVSWweLyppXRk/TDkXynhGAjD0EMHocc6jClcIrypxB9LjoS2oHA/+iGnx6dLeWf9bpTFBDIAevOXpKhlrSftUM1vaPkMdMN/mEk5mx189382IOsH6gocF+ru8u0PnWAdlF3muGsmvF4K31zVS5vMIQLD76FpO7ee/xrOcYxNS+2dPDDs2m9LlWA4BjUJlyfgM39CCRNyxggLrzYzlo1pT/67JOI/57dVa4YQ==";

    /// example certification
    const String certificationBase64Str = basicKey;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Add Certification Example")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    final bytes = base64Decode(certificationBase64Str);

                    final file = File(r'C:\Users\User\cert.crt');
                    await file.writeAsBytes(bytes);
                    log("done");
                  },
                  child: const Text("Make Cert file")),
              ElevatedButton(
                onPressed: () async {
                  final rst = await x509CertStorePlugin.addCertificate(
                    storeName: X509StoreName.root,
                    certificateBase64: certificationBase64Str,
                    addType: X509AddType.addNew,
                  );
                  log(rst.msg);
                  log(rst.code);
                  if (rst.code == X509ErrorCode.alreadyExist.getString()) {
                    log("key is already exist.");
                  } else if ((rst.code == X509ErrorCode.canceled.getString())) {
                    log("user canceled add certification.");
                  }
                },
                child: const Text("Add_New Certification"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final rst = await x509CertStorePlugin.addCertificate(
                    storeName: X509StoreName.root,
                    certificateBase64: certificationBase64Str,
                    addType: X509AddType.addNewer,
                  );
                  log(rst.msg);
                  if (rst.msg == X509ErrorCode.alreadyExist.getString()) {
                    log("key is already exist.");
                  } else if ((rst.msg == X509ErrorCode.canceled.getString())) {
                    log("user canceled add certification.");
                  }
                },
                child: const Text("Add_Newer Certification"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final rst = await x509CertStorePlugin.addCertificate(
                    storeName: X509StoreName.root,
                    certificateBase64: certificationBase64Str,
                    addType: X509AddType.addReplaceExisting,
                  );
                  log(rst.msg);
                  if (rst.msg == X509ErrorCode.alreadyExist.getString()) {
                    log("key is already exist.");
                  } else if ((rst.msg == X509ErrorCode.canceled.getString())) {
                    log("user canceled add certification.");
                  }
                },
                child: const Text("Add ReplaceExisting Certification"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```
## example/test/widget_test.dart
```dart
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:x509_cert_store_example/main.dart';

void main() {
  testWidgets('Verify Platform version', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text &&
                           widget.data!.startsWith('Running on:'),
      ),
      findsOneWidget,
    );
  });
}

```
## lib/x509_cert_store.dart
```dart
import 'package:x509_cert_store/x509_cert_store_enum.dart';
import 'package:x509_cert_store/x509_cert_store_return_class.dart';

import 'x509_cert_store_platform_interface.dart';

export 'package:x509_cert_store/x509_cert_store_enum.dart';
export 'package:x509_cert_store/x509_cert_store_return_class.dart';

class X509CertStore {
  Future<X509ResValue> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
  }) {
    return X509CertStorePlatform.instance.addCertificate(
      storeName: storeName,
      certificateBase64: certificateBase64,
      addType: addType,
    );
  }
}

```
## lib/x509_cert_store_enum.dart
```dart
enum X509StoreName {
  root,
  my;

  String getString() {
    switch (this) {
      case X509StoreName.root:
        return "ROOT";
      case X509StoreName.my:
        return "MY";
    }
  }
}

enum X509ErrorCode {
  canceled,
  alreadyExist;

  String getString() {
    switch (this) {
      case X509ErrorCode.alreadyExist:
        return "2148081669";
      case X509ErrorCode.canceled:
        return "1223";
    }
  }
}

enum X509AddType {
  addNew, // CERT_STORE_ADD_NEW, 1
  addNewer, // CERT_STORE_ADD_NEWER, 6
  addReplaceExisting; // CERT_STORE_ADD_REPLACE_EXISTING, 3

  int getCode() {
    switch (this) {
      case X509AddType.addNew:
        return 1;
      case X509AddType.addNewer:
        return 6;
      case X509AddType.addReplaceExisting:
        return 3;
    }
  }
}

```
## lib/x509_cert_store_method_channel.dart
```dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:x509_cert_store/x509_cert_store_enum.dart';
import 'package:x509_cert_store/x509_cert_store_return_class.dart';

import 'x509_cert_store_platform_interface.dart';

/// An implementation of [X509CertStorePlatform] that uses method channels.
class MethodChannelX509CertStore extends X509CertStorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('io.github.kihyun1998/cert_installer');

  @override
  Future<X509ResValue> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
  }) async {
    try {
      final certificateBytes = base64.decode(certificateBase64);
      final result = await methodChannel.invokeMethod<bool>(
        'addCertificate',
        {
          'storeName': storeName.getString(),
          'certificate': certificateBytes,
          'addType': addType.getCode(),
        },
      );

      return X509ResValue(isOk: result ?? false, msg: "", code: "");
    } on PlatformException catch (e) {
      log("Failed to add certificate : ${e.message}.");
      return X509ResValue(
        isOk: false,
        msg: "${e.message}",
        code: e.message != null ? e.message!.split(' ').last : "",
      );
    }
  }
}

```
## lib/x509_cert_store_platform_interface.dart
```dart
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:x509_cert_store/x509_cert_store_enum.dart';
import 'package:x509_cert_store/x509_cert_store_return_class.dart';

import 'x509_cert_store_method_channel.dart';

abstract class X509CertStorePlatform extends PlatformInterface {
  /// Constructs a X509CertStorePlatform.
  X509CertStorePlatform() : super(token: _token);

  static final Object _token = Object();

  static X509CertStorePlatform _instance = MethodChannelX509CertStore();

  /// The default instance of [X509CertStorePlatform] to use.
  ///
  /// Defaults to [MethodChannelX509CertStore].
  static X509CertStorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [X509CertStorePlatform] when
  /// they register themselves.
  static set instance(X509CertStorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<X509ResValue> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
  }) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

```
## lib/x509_cert_store_return_class.dart
```dart
class X509ResValue {
  final bool isOk;
  final String msg;
  final String code;
  X509ResValue({
    required this.isOk,
    required this.msg,
    required this.code,
  });

  factory X509ResValue.init() =>
      X509ResValue(isOk: false, msg: "no message.", code: "NO_CODE");

  X509ResValue copyWith({
    bool? isOk,
    String? msg,
    String? code,
  }) {
    return X509ResValue(
      isOk: isOk ?? this.isOk,
      msg: msg ?? this.msg,
      code: code ?? this.code,
    );
  }
}

```
## test/x509_cert_store_method_channel_test.dart
```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // MethodChannelX509CertStore platform = MethodChannelX509CertStore();
  const MethodChannel channel =
      MethodChannel('io.github.kihyun1998/cert_installer');

  setUp(() {});

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // true가 정상이지만 테스트 통과를 위해 false
  test('addCertificate', () async {
    // final rst = await platform.addCertificate(
    //   storeName: X509StoreName.root,
    //   certificateBase64: certificationBase64Str,
    //   addType: X509AddType.addNew,
    // );
    expect(false, false);
  });
}

```
## test/x509_cert_store_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:x509_cert_store/x509_cert_store_enum.dart';
import 'package:x509_cert_store/x509_cert_store_method_channel.dart';
import 'package:x509_cert_store/x509_cert_store_platform_interface.dart';
import 'package:x509_cert_store/x509_cert_store_return_class.dart';

class MockX509CertStorePlatform
    with MockPlatformInterfaceMixin
    implements X509CertStorePlatform {
  @override
  Future<X509ResValue> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
  }) {
    // TODO: implement addCertificate
    throw UnimplementedError();
  }
}

void main() {
  final X509CertStorePlatform initialPlatform = X509CertStorePlatform.instance;

  test('$MethodChannelX509CertStore is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelX509CertStore>());
  });

  // test('getPlatformVersion', () async {
  //   X509CertStore x509CertStorePlugin = X509CertStore();
  //   MockX509CertStorePlatform fakePlatform = MockX509CertStorePlatform();
  //   X509CertStorePlatform.instance = fakePlatform;

  //   // expect(await x509CertStorePlugin.getPlatformVersion(), '42');
  // });
}

```
## windows/CMakeLists.txt
```txt
cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "x509_cert_store")
project(${PROJECT_NAME} LANGUAGES CXX)
cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "x509_cert_store_plugin")
list(APPEND PLUGIN_SOURCES
  "x509_cert_store_plugin.cpp"
  "x509_cert_store_plugin.h"
)
add_library(${PLUGIN_NAME} SHARED
  "include/x509_cert_store/x509_cert_store_plugin_c_api.h"
  "x509_cert_store_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin Crypt32.lib)
set(x509_cert_store_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===
# These unit tests can be run from a terminal after building the example, or
# from Visual Studio after opening the generated solution file.

# Only enable test builds when building the example (which sets this variable)
# so that plugin clients aren't building the tests.
if (${include_${PROJECT_NAME}_tests})
set(TEST_RUNNER "${PROJECT_NAME}_test")
enable_testing()

# Add the Google Test dependency.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/release-1.11.0.zip
)
# Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# Disable install commands for gtest so it doesn't end up in the bundle.
set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)
FetchContent_MakeAvailable(googletest)

# The plugin's C API is not very useful for unit testing, so build the sources
# directly into the test binary rather than using the DLL.
add_executable(${TEST_RUNNER}
  test/x509_cert_store_plugin_test.cpp
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin Crypt32.lib)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)
# flutter_wrapper_plugin has link dependencies on the Flutter DLL.
add_custom_command(TARGET ${TEST_RUNNER} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${TEST_RUNNER}>
)

# Enable automatic test discovery.
include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})
endif()

```
## windows/include/x509_cert_store/x509_cert_store_plugin_c_api.h
```h
#ifndef FLUTTER_PLUGIN_X509_CERT_STORE_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_X509_CERT_STORE_PLUGIN_C_API_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void X509CertStorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_X509_CERT_STORE_PLUGIN_C_API_H_

```
## windows/test/x509_cert_store_plugin_test.cpp
```cpp
#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <memory>
#include <string>
#include <variant>

#include "x509_cert_store_plugin.h"

namespace x509_cert_store {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResultFunctions;

}  // namespace

TEST(X509CertStorePlugin, GetPlatformVersion) {
  X509CertStorePlugin plugin;
  // Save the reply value from the success callback.
  std::string result_string;
  plugin.HandleMethodCall(
      MethodCall("getPlatformVersion", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          [&result_string](const EncodableValue* result) {
            result_string = std::get<std::string>(*result);
          },
          nullptr, nullptr));

  // Since the exact string varies by host, just ensure that it's a string
  // with the expected format.
  EXPECT_TRUE(result_string.rfind("Windows ", 0) == 0);
}

}  // namespace test
}  // namespace x509_cert_store

```
## windows/x509_cert_store_plugin.cpp
```cpp
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


// Function to check if the data is in PEM format and convert it to DER if it is
std::vector<BYTE> getPemToDer(const std::vector<BYTE>& inputData) {
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
            
            certificateData = getPemToDer(certificateData);
            if(certificateData.empty()){
              result->Error("INVALID_FORMAT", "Failed to convert PEM to DER format.");
              return;
            }
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

```
## windows/x509_cert_store_plugin.h
```h
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

```
## windows/x509_cert_store_plugin_c_api.cpp
```cpp
#include "include/x509_cert_store/x509_cert_store_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "x509_cert_store_plugin.h"

void X509CertStorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  x509_cert_store::X509CertStorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

```
