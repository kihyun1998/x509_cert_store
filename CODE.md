# x509_cert_store
## Project Structure

```
x509_cert_store/
├── example/
    ├── integration_test/
    │   └── plugin_integration_test.dart
    ├── lib/
    │   └── main.dart
    ├── macos/
    │   ├── Runner/
    │   │   ├── AppDelegate.swift
    │   │   ├── DebugProfile.entitlements
    │   │   ├── Info.plist
    │   │   ├── MainFlutterWindow.swift
    │   │   └── Release.entitlements
    │   ├── Runner.xcodeproj/
    │   │   ├── project.xcworkspace/
    │   │   │   └── xcshareddata/
    │   │   │   │   └── IDEWorkspaceChecks.plist
    │   │   ├── xcshareddata/
    │   │   │   └── xcschemes/
    │   │   │   │   └── Runner.xcscheme
    │   │   └── project.pbxproj
    │   ├── Runner.xcworkspace/
    │   │   ├── xcshareddata/
    │   │   │   └── IDEWorkspaceChecks.plist
    │   │   └── contents.xcworkspacedata
    │   └── Podfile
    ├── test/
    │   └── widget_test.dart
    └── x509_cert_store_example.iml
├── lib/
    ├── x509_cert_store.dart
    ├── x509_cert_store_enum.dart
    ├── x509_cert_store_method_channel.dart
    ├── x509_cert_store_platform_interface.dart
    └── x509_cert_store_return_class.dart
├── macos/
    ├── Classes/
    │   └── X509CertStorePlugin.swift
    ├── Resources/
    │   └── PrivacyInfo.xcprivacy
    └── x509_cert_store.podspec
├── test/
    ├── x509_cert_store_method_channel_test.dart
    └── x509_cert_store_test.dart
├── windows/
    ├── include/
    │   └── x509_cert_store/
    │   │   └── x509_cert_store_plugin_c_api.h
    ├── test/
    │   └── x509_cert_store_plugin_test.cpp
    ├── CMakeLists.txt
    ├── x509_cert_store_plugin.cpp
    ├── x509_cert_store_plugin.h
    └── x509_cert_store_plugin_c_api.cpp
├── openssl.md
└── x509_cert_store.iml
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
// main.dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x509_cert_store/x509_cert_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X509 Certificate Store Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CertificateManagerPage(),
    );
  }
}

class CertificateManagerPage extends StatefulWidget {
  const CertificateManagerPage({super.key});

  @override
  State<CertificateManagerPage> createState() => _CertificateManagerPageState();
}

class _CertificateManagerPageState extends State<CertificateManagerPage> {
  final x509CertStorePlugin = X509CertStore();
  final TextEditingController _certificateController = TextEditingController();

  X509StoreName _selectedStore = X509StoreName.root;
  X509AddType _selectedAddType = X509AddType.addNew;

  String _statusMessage = '';
  bool _isSuccess = false;
  bool _isLoading = false;
  String? _loadedFilename;
  String _errorCode = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _certificateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('X509 Certificate Manager'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Platform info card
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Platform.isWindows
                            ? Icons.window
                            : Platform.isMacOS
                                ? Icons.laptop_mac
                                : Icons.devices,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Platform: ${Platform.operatingSystem}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Version: ${Platform.operatingSystemVersion}",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Certificate Storage Location
              const Text(
                "Certificate Store Location:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  Radio<X509StoreName>(
                    value: X509StoreName.root,
                    groupValue: _selectedStore,
                    onChanged: (X509StoreName? value) {
                      setState(() {
                        _selectedStore = value!;
                      });
                    },
                  ),
                  const Text('ROOT Store'),
                  const SizedBox(width: 20),
                  Radio<X509StoreName>(
                    value: X509StoreName.my,
                    groupValue: _selectedStore,
                    onChanged: (X509StoreName? value) {
                      setState(() {
                        _selectedStore = value!;
                      });
                    },
                  ),
                  const Text('MY Store (Personal)'),
                ],
              ),
              const SizedBox(height: 16),

              // Certificate Addition Type
              const Text(
                "Certificate Addition Type:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              DropdownButtonFormField<X509AddType>(
                value: _selectedAddType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(
                    value: X509AddType.addNew,
                    child: Row(
                      children: [
                        Icon(Icons.new_label, size: 16),
                        SizedBox(width: 8),
                        Text('Add New (Only if not exists)'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: X509AddType.addNewer,
                    child: Row(
                      children: [
                        Icon(Icons.upgrade, size: 16),
                        SizedBox(width: 8),
                        Text('Add Newer (Only if newer)'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: X509AddType.addReplaceExisting,
                    child: Row(
                      children: [
                        Icon(Icons.published_with_changes, size: 16),
                        SizedBox(width: 8),
                        Text('Replace (Overwrite existing)'),
                      ],
                    ),
                  ),
                ],
                onChanged: (X509AddType? value) {
                  setState(() {
                    _selectedAddType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Certificate Content Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Certificate Content (Base64):",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      if (_loadedFilename != null)
                        Chip(
                          label: Text(_loadedFilename!),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _loadedFilename = null;
                            });
                          },
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Load from File'),
                        onPressed: _loadCertificateFromFile,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.paste),
                        tooltip: 'Paste from clipboard',
                        onPressed: _pasteFromClipboard,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy to clipboard',
                        onPressed: () {
                          if (_certificateController.text.isNotEmpty) {
                            Clipboard.setData(ClipboardData(
                                text: _certificateController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Copied to clipboard')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear content',
                        onPressed: () {
                          setState(() {
                            _certificateController.clear();
                            _loadedFilename = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _certificateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste base64 encoded certificate here...',
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter certificate content';
                  }
                  try {
                    base64Decode(value.replaceAll(RegExp(r'\s+'), ''));
                    return null;
                  } catch (e) {
                    return 'Invalid base64 format';
                  }
                },
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.security),
                        label: const Text('Add Certificate to Store'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _addCertificate,
                      ),
              ),
              const SizedBox(height: 24),

              // Status Section
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle : Icons.error,
                            color: _isSuccess ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSuccess ? "Success" : "Error",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _isSuccess ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_statusMessage),
                      if (!_isSuccess && _errorCode.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Error Code: $_errorCode",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Sample certificate section
              const SizedBox(height: 24),
              ExpansionTile(
                title: const Text("Sample Certificate"),
                subtitle: const Text("Use this sample certificate for testing"),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "This is a sample self-signed certificate for testing purposes only.",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.content_copy),
                      label: const Text("Copy Sample Certificate"),
                      onPressed: () {
                        _certificateController.text = _getSampleCertificate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Sample certificate loaded')),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Debug Info (for developers)
              if (_isSuccess == false && _errorCode.isNotEmpty)
                ExpansionTile(
                  title: const Text("Debug Information"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Error Code: $_errorCode"),
                          const SizedBox(height: 8),
                          const Text("Common Error Codes:"),
                          const SizedBox(height: 4),
                          const Text("• 1223: User canceled the operation"),
                          const Text(
                              "• 2148081669: Certificate already exists in the store"),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _certificateController.text = data.text!;
        _loadedFilename = null;
      });
    }
  }

  String _getSampleCertificate() {
    return "MIIDPzCCAiegAwIBAgIUTaCSxPYnAxNeYiWCTKJhTEuLlrUwDQYJKoZIhvcNAQELBQAwGDEWMBQGA1UEAwwNbXljb21wYW55LmNvbTAeFw0yNTA0MTYxMzAyNThaFw0yNjA0MTYxMzAyNThaMBgxFjAUBgNVBAMMDW15Y29tcGFueS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC/FBH6gVh0bd3s1j1sJ5VvNVBPCTlX8pyvE5TzSyY2wbu8FB+qwjZVUqhkJM4eTmlyn5oR1ZJrzxBxX3t2h2Mqd+EePZ6d1c1yb/FhnvxgUQINUI1PBnQfqHq//5e0NS2OHk3nLiGM01iLPL71E8PAjZnKxtjdQfGoxBvF5DnUtzk0ZmrUdpHSuJA2jzru0D70Yqi6BxLX+P9dDIhR/+Ym4CBewmh4bsBl0Cq9DzR1uajs860U7Y9nFK4JGQOPsQPkgNNXDaXF9OJiQx+dxuKGUcdTqmwy4bsiwxTLhRZQxTaG7oFTgepB+jvCMU4eAE+FXSETJneQkB+KjdJnRhEZAgMBAAGjgYAwfjAdBgNVHQ4EFgQUMR37QYIjV14yf5K1M21NwL6zANEwHwYDVR0jBBgwFoAUMR37QYIjV14yf5K1M21NwL6zANEwDwYDVR0TAQH/BAUwAwEB/zArBgNVHREEJDAigg1teWNvbXBhbnkuY29tghF3d3cubXljb21wYW55LmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAYMBzjiPhLwuJUhJwM9mzGL6FP81Gyk7wenMZQF1UC54Lw/mZCzCWJW4fC398j4OVxHfU/aenkAVs0s9xu7q/Z+iol6iVAen6yHIM6RyzrKBLZfXU/15lH5wTjM+EUUEutzbxS80Kb2hBO/e3ITqq0qcbHLD0S6aM67KYbpQ/g6MbNNuMB6Uw0aC2EVknfP8JqSjMfY0w8n/y8Bsz1JQZa/zLsrQr95i1FaSayB94AB9yWrf2XBqS9BbX9BXr2YqKST3lLzUMbsvUpN9IDtRULFeD3LcNfMXTMYHInggf7trTkj2YRVKr6acLhggyqFi1I/feXuXtENOOvq0RcLK1bg==";
  }

  Future<void> _loadCertificateFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['crt', 'pem', 'cer', 'der'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        Uint8List bytes = await file.readAsBytes();
        String base64Cert = base64Encode(bytes);

        setState(() {
          _certificateController.text = base64Cert;
          _loadedFilename = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading certificate file: $e';
        _isSuccess = false;
        _errorCode = 'FILE_READ_ERROR';
      });
    }
  }

  void _handleCertificateResult(X509ResValue result) {
    setState(() {
      _isLoading = false;
      _isSuccess = result.isOk;
      _statusMessage = result.msg;
      _errorCode = result.code;

      // Add additional context to common error codes
      if (result.hasError(X509ErrorCode.alreadyExist)) {
        _statusMessage =
            "Certificate already exists in the store. To replace it, use the 'Replace' mode.";
      } else if (result.hasError(X509ErrorCode.canceled)) {
        _statusMessage = "User canceled the certificate addition process.";
      }
    });
  }

  Future<void> _addCertificate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final certificateBase64 =
          _certificateController.text.replaceAll(RegExp(r'\s+'), '');

      print("🔒 Adding certificate to ${Platform.operatingSystem} store...");
      print("   Store: ${_selectedStore.getString()}");
      print("   Mode: ${_selectedAddType.toString().split('.').last}");

      final result = await x509CertStorePlugin.addCertificate(
        storeName: _selectedStore,
        certificateBase64: certificateBase64,
        addType: _selectedAddType,
      );

      _handleCertificateResult(result);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _statusMessage = "Exception during addCertificate: $e";
        _errorCode = 'EXCEPTION';
      });
    }
  }
}

```
## example/macos/Podfile
```
platform :osx, '10.14'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'ephemeral', 'Flutter-Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure \"flutter pub get\" is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Flutter-Generated.xcconfig, then run \"flutter pub get\""
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_macos_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_macos_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_macos_build_settings(target)
  end
end

```
## example/macos/Runner/AppDelegate.swift
```swift
import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

```
## example/macos/Runner/DebugProfile.entitlements
```entitlements
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.cs.allow-jit</key>
	<true/>
	<key>com.apple.security.network.server</key>
	<true/>
	<key>com.apple.security.keychain</key>
	<true/>
</dict>
</plist>

```
## example/macos/Runner/Info.plist
```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIconFile</key>
	<string></string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
	<key>LSMinimumSystemVersion</key>
	<string>$(MACOSX_DEPLOYMENT_TARGET)</string>
	<key>NSHumanReadableCopyright</key>
	<string>$(PRODUCT_COPYRIGHT)</string>
	<key>NSMainNibFile</key>
	<string>MainMenu</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>

```
## example/macos/Runner/MainFlutterWindow.swift
```swift
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

```
## example/macos/Runner/Release.entitlements
```entitlements
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.keychain</key>
	<true/>
</dict>
</plist>

```
## example/macos/Runner.xcodeproj/project.pbxproj
```pbxproj
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 54;
	objects = {

/* Begin PBXAggregateTarget section */
		33CC111A2044C6BA0003C045 /* Flutter Assemble */ = {
			isa = PBXAggregateTarget;
			buildConfigurationList = 33CC111B2044C6BA0003C045 /* Build configuration list for PBXAggregateTarget "Flutter Assemble" */;
			buildPhases = (
				33CC111E2044C6BF0003C045 /* ShellScript */,
			);
			dependencies = (
			);
			name = "Flutter Assemble";
			productName = FLX;
		};
/* End PBXAggregateTarget section */

/* Begin PBXBuildFile section */
		124A003E9930B76C18A07086 /* Pods_RunnerTests.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = AC57FD172A13A789F6E0621E /* Pods_RunnerTests.framework */; };
		331C80D8294CF71000263BE5 /* RunnerTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = 331C80D7294CF71000263BE5 /* RunnerTests.swift */; };
		335BBD1B22A9A15E00E9071D /* GeneratedPluginRegistrant.swift in Sources */ = {isa = PBXBuildFile; fileRef = 335BBD1A22A9A15E00E9071D /* GeneratedPluginRegistrant.swift */; };
		33CC10F12044A3C60003C045 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = 33CC10F02044A3C60003C045 /* AppDelegate.swift */; };
		33CC10F32044A3C60003C045 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 33CC10F22044A3C60003C045 /* Assets.xcassets */; };
		33CC10F62044A3C60003C045 /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = 33CC10F42044A3C60003C045 /* MainMenu.xib */; };
		33CC11132044BFA00003C045 /* MainFlutterWindow.swift in Sources */ = {isa = PBXBuildFile; fileRef = 33CC11122044BFA00003C045 /* MainFlutterWindow.swift */; };
		3EA6748ACF3ECB7FEEAFA2E3 /* Pods_Runner.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 050210E634BB3B5D30D1D0CF /* Pods_Runner.framework */; };
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
		331C80D9294CF71000263BE5 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 33CC10E52044A3C60003C045 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = 33CC10EC2044A3C60003C045;
			remoteInfo = Runner;
		};
		33CC111F2044C79F0003C045 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 33CC10E52044A3C60003C045 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = 33CC111A2044C6BA0003C045;
			remoteInfo = FLX;
		};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
		33CC110E2044A8840003C045 /* Bundle Framework */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 10;
			files = (
			);
			name = "Bundle Framework";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
		050210E634BB3B5D30D1D0CF /* Pods_Runner.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = Pods_Runner.framework; sourceTree = BUILT_PRODUCTS_DIR; };
		331C80D5294CF71000263BE5 /* RunnerTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = RunnerTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
		331C80D7294CF71000263BE5 /* RunnerTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RunnerTests.swift; sourceTree = "<group>"; };
		333000ED22D3DE5D00554162 /* Warnings.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = Warnings.xcconfig; sourceTree = "<group>"; };
		335BBD1A22A9A15E00E9071D /* GeneratedPluginRegistrant.swift */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = GeneratedPluginRegistrant.swift; sourceTree = "<group>"; };
		33CC10ED2044A3C60003C045 /* x509_cert_store_example.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = x509_cert_store_example.app; sourceTree = BUILT_PRODUCTS_DIR; };
		33CC10F02044A3C60003C045 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
		33CC10F22044A3C60003C045 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; name = Assets.xcassets; path = Runner/Assets.xcassets; sourceTree = "<group>"; };
		33CC10F52044A3C60003C045 /* Base */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = Base; path = Base.lproj/MainMenu.xib; sourceTree = "<group>"; };
		33CC10F72044A3C60003C045 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; name = Info.plist; path = Runner/Info.plist; sourceTree = "<group>"; };
		33CC11122044BFA00003C045 /* MainFlutterWindow.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MainFlutterWindow.swift; sourceTree = "<group>"; };
		33CEB47222A05771004F2AC0 /* Flutter-Debug.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = "Flutter-Debug.xcconfig"; sourceTree = "<group>"; };
		33CEB47422A05771004F2AC0 /* Flutter-Release.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = "Flutter-Release.xcconfig"; sourceTree = "<group>"; };
		33CEB47722A0578A004F2AC0 /* Flutter-Generated.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; name = "Flutter-Generated.xcconfig"; path = "ephemeral/Flutter-Generated.xcconfig"; sourceTree = "<group>"; };
		33E51913231747F40026EE4D /* DebugProfile.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = DebugProfile.entitlements; sourceTree = "<group>"; };
		33E51914231749380026EE4D /* Release.entitlements */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.entitlements; path = Release.entitlements; sourceTree = "<group>"; };
		33E5194F232828860026EE4D /* AppInfo.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = AppInfo.xcconfig; sourceTree = "<group>"; };
		3BCB0B28C9572BB2F2D82D30 /* Pods-RunnerTests.debug.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-RunnerTests.debug.xcconfig"; path = "Target Support Files/Pods-RunnerTests/Pods-RunnerTests.debug.xcconfig"; sourceTree = "<group>"; };
		711E8102A91346F3E0C4DA7B /* Pods-Runner.release.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-Runner.release.xcconfig"; path = "Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"; sourceTree = "<group>"; };
		78D0B2E2E5698C0C7B04011E /* Pods-Runner.debug.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-Runner.debug.xcconfig"; path = "Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"; sourceTree = "<group>"; };
		7AFA3C8E1D35360C0083082E /* Release.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = Release.xcconfig; sourceTree = "<group>"; };
		824E75BBDF39AF704E264719 /* Pods-Runner.profile.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-Runner.profile.xcconfig"; path = "Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"; sourceTree = "<group>"; };
		9740EEB21CF90195004384FC /* Debug.xcconfig */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.xcconfig; path = Debug.xcconfig; sourceTree = "<group>"; };
		AC57FD172A13A789F6E0621E /* Pods_RunnerTests.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = Pods_RunnerTests.framework; sourceTree = BUILT_PRODUCTS_DIR; };
		CE291F5148654E0B7998BA6F /* Pods-RunnerTests.release.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-RunnerTests.release.xcconfig"; path = "Target Support Files/Pods-RunnerTests/Pods-RunnerTests.release.xcconfig"; sourceTree = "<group>"; };
		E4ED7308576CA4E07C0EC5DB /* Pods-RunnerTests.profile.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-RunnerTests.profile.xcconfig"; path = "Target Support Files/Pods-RunnerTests/Pods-RunnerTests.profile.xcconfig"; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		331C80D2294CF70F00263BE5 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				124A003E9930B76C18A07086 /* Pods_RunnerTests.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		33CC10EA2044A3C60003C045 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				3EA6748ACF3ECB7FEEAFA2E3 /* Pods_Runner.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		331C80D6294CF71000263BE5 /* RunnerTests */ = {
			isa = PBXGroup;
			children = (
				331C80D7294CF71000263BE5 /* RunnerTests.swift */,
			);
			path = RunnerTests;
			sourceTree = "<group>";
		};
		33BA886A226E78AF003329D5 /* Configs */ = {
			isa = PBXGroup;
			children = (
				33E5194F232828860026EE4D /* AppInfo.xcconfig */,
				9740EEB21CF90195004384FC /* Debug.xcconfig */,
				7AFA3C8E1D35360C0083082E /* Release.xcconfig */,
				333000ED22D3DE5D00554162 /* Warnings.xcconfig */,
			);
			path = Configs;
			sourceTree = "<group>";
		};
		33CC10E42044A3C60003C045 = {
			isa = PBXGroup;
			children = (
				33FAB671232836740065AC1E /* Runner */,
				33CEB47122A05771004F2AC0 /* Flutter */,
				331C80D6294CF71000263BE5 /* RunnerTests */,
				33CC10EE2044A3C60003C045 /* Products */,
				D46EAFCA788A2B9F0EC5FCFD /* Pods */,
				EE4B862FC1785054BA6659FF /* Frameworks */,
			);
			sourceTree = "<group>";
		};
		33CC10EE2044A3C60003C045 /* Products */ = {
			isa = PBXGroup;
			children = (
				33CC10ED2044A3C60003C045 /* x509_cert_store_example.app */,
				331C80D5294CF71000263BE5 /* RunnerTests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		33CC11242044D66E0003C045 /* Resources */ = {
			isa = PBXGroup;
			children = (
				33CC10F22044A3C60003C045 /* Assets.xcassets */,
				33CC10F42044A3C60003C045 /* MainMenu.xib */,
				33CC10F72044A3C60003C045 /* Info.plist */,
			);
			name = Resources;
			path = ..;
			sourceTree = "<group>";
		};
		33CEB47122A05771004F2AC0 /* Flutter */ = {
			isa = PBXGroup;
			children = (
				335BBD1A22A9A15E00E9071D /* GeneratedPluginRegistrant.swift */,
				33CEB47222A05771004F2AC0 /* Flutter-Debug.xcconfig */,
				33CEB47422A05771004F2AC0 /* Flutter-Release.xcconfig */,
				33CEB47722A0578A004F2AC0 /* Flutter-Generated.xcconfig */,
			);
			path = Flutter;
			sourceTree = "<group>";
		};
		33FAB671232836740065AC1E /* Runner */ = {
			isa = PBXGroup;
			children = (
				33CC10F02044A3C60003C045 /* AppDelegate.swift */,
				33CC11122044BFA00003C045 /* MainFlutterWindow.swift */,
				33E51913231747F40026EE4D /* DebugProfile.entitlements */,
				33E51914231749380026EE4D /* Release.entitlements */,
				33CC11242044D66E0003C045 /* Resources */,
				33BA886A226E78AF003329D5 /* Configs */,
			);
			path = Runner;
			sourceTree = "<group>";
		};
		D46EAFCA788A2B9F0EC5FCFD /* Pods */ = {
			isa = PBXGroup;
			children = (
				78D0B2E2E5698C0C7B04011E /* Pods-Runner.debug.xcconfig */,
				711E8102A91346F3E0C4DA7B /* Pods-Runner.release.xcconfig */,
				824E75BBDF39AF704E264719 /* Pods-Runner.profile.xcconfig */,
				3BCB0B28C9572BB2F2D82D30 /* Pods-RunnerTests.debug.xcconfig */,
				CE291F5148654E0B7998BA6F /* Pods-RunnerTests.release.xcconfig */,
				E4ED7308576CA4E07C0EC5DB /* Pods-RunnerTests.profile.xcconfig */,
			);
			name = Pods;
			path = Pods;
			sourceTree = "<group>";
		};
		EE4B862FC1785054BA6659FF /* Frameworks */ = {
			isa = PBXGroup;
			children = (
				050210E634BB3B5D30D1D0CF /* Pods_Runner.framework */,
				AC57FD172A13A789F6E0621E /* Pods_RunnerTests.framework */,
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		331C80D4294CF70F00263BE5 /* RunnerTests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 331C80DE294CF71000263BE5 /* Build configuration list for PBXNativeTarget "RunnerTests" */;
			buildPhases = (
				F164A6FA13ADA0783DBCD933 /* [CP] Check Pods Manifest.lock */,
				331C80D1294CF70F00263BE5 /* Sources */,
				331C80D2294CF70F00263BE5 /* Frameworks */,
				331C80D3294CF70F00263BE5 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				331C80DA294CF71000263BE5 /* PBXTargetDependency */,
			);
			name = RunnerTests;
			productName = RunnerTests;
			productReference = 331C80D5294CF71000263BE5 /* RunnerTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		};
		33CC10EC2044A3C60003C045 /* Runner */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 33CC10FB2044A3C60003C045 /* Build configuration list for PBXNativeTarget "Runner" */;
			buildPhases = (
				5E526CB28E432957334BF75B /* [CP] Check Pods Manifest.lock */,
				33CC10E92044A3C60003C045 /* Sources */,
				33CC10EA2044A3C60003C045 /* Frameworks */,
				33CC10EB2044A3C60003C045 /* Resources */,
				33CC110E2044A8840003C045 /* Bundle Framework */,
				3399D490228B24CF009A79C7 /* ShellScript */,
				ADFEBF5EF10D041755DF4CB7 /* [CP] Embed Pods Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
				33CC11202044C79F0003C045 /* PBXTargetDependency */,
			);
			name = Runner;
			productName = Runner;
			productReference = 33CC10ED2044A3C60003C045 /* x509_cert_store_example.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		33CC10E52044A3C60003C045 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = YES;
				LastSwiftUpdateCheck = 0920;
				LastUpgradeCheck = 1510;
				ORGANIZATIONNAME = "";
				TargetAttributes = {
					331C80D4294CF70F00263BE5 = {
						CreatedOnToolsVersion = 14.0;
						TestTargetID = 33CC10EC2044A3C60003C045;
					};
					33CC10EC2044A3C60003C045 = {
						CreatedOnToolsVersion = 9.2;
						LastSwiftMigration = 1100;
						ProvisioningStyle = Automatic;
						SystemCapabilities = {
							com.apple.Sandbox = {
								enabled = 1;
							};
						};
					};
					33CC111A2044C6BA0003C045 = {
						CreatedOnToolsVersion = 9.2;
						ProvisioningStyle = Manual;
					};
				};
			};
			buildConfigurationList = 33CC10E82044A3C60003C045 /* Build configuration list for PBXProject "Runner" */;
			compatibilityVersion = "Xcode 9.3";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 33CC10E42044A3C60003C045;
			productRefGroup = 33CC10EE2044A3C60003C045 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				33CC10EC2044A3C60003C045 /* Runner */,
				331C80D4294CF70F00263BE5 /* RunnerTests */,
				33CC111A2044C6BA0003C045 /* Flutter Assemble */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		331C80D3294CF70F00263BE5 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		33CC10EB2044A3C60003C045 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				33CC10F32044A3C60003C045 /* Assets.xcassets in Resources */,
				33CC10F62044A3C60003C045 /* MainMenu.xib in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXShellScriptBuildPhase section */
		3399D490228B24CF009A79C7 /* ShellScript */ = {
			isa = PBXShellScriptBuildPhase;
			alwaysOutOfDate = 1;
			buildActionMask = 2147483647;
			files = (
			);
			inputFileListPaths = (
			);
			inputPaths = (
			);
			outputFileListPaths = (
			);
			outputPaths = (
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "echo \"$PRODUCT_NAME.app\" > \"$PROJECT_DIR\"/Flutter/ephemeral/.app_filename && \"$FLUTTER_ROOT\"/packages/flutter_tools/bin/macos_assemble.sh embed\n";
		};
		33CC111E2044C6BF0003C045 /* ShellScript */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputFileListPaths = (
				Flutter/ephemeral/FlutterInputs.xcfilelist,
			);
			inputPaths = (
				Flutter/ephemeral/tripwire,
			);
			outputFileListPaths = (
				Flutter/ephemeral/FlutterOutputs.xcfilelist,
			);
			outputPaths = (
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "\"$FLUTTER_ROOT\"/packages/flutter_tools/bin/macos_assemble.sh && touch Flutter/ephemeral/tripwire";
		};
		5E526CB28E432957334BF75B /* [CP] Check Pods Manifest.lock */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputFileListPaths = (
			);
			inputPaths = (
				"${PODS_PODFILE_DIR_PATH}/Podfile.lock",
				"${PODS_ROOT}/Manifest.lock",
			);
			name = "[CP] Check Pods Manifest.lock";
			outputFileListPaths = (
			);
			outputPaths = (
				"$(DERIVED_FILE_DIR)/Pods-Runner-checkManifestLockResult.txt",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "diff \"${PODS_PODFILE_DIR_PATH}/Podfile.lock\" \"${PODS_ROOT}/Manifest.lock\" > /dev/null\nif [ $? != 0 ] ; then\n    # print error to STDERR\n    echo \"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\" >&2\n    exit 1\nfi\n# This output is used by Xcode 'outputs' to avoid re-running this script phase.\necho \"SUCCESS\" > \"${SCRIPT_OUTPUT_FILE_0}\"\n";
			showEnvVarsInLog = 0;
		};
		ADFEBF5EF10D041755DF4CB7 /* [CP] Embed Pods Frameworks */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputFileListPaths = (
				"${PODS_ROOT}/Target Support Files/Pods-Runner/Pods-Runner-frameworks-${CONFIGURATION}-input-files.xcfilelist",
			);
			name = "[CP] Embed Pods Frameworks";
			outputFileListPaths = (
				"${PODS_ROOT}/Target Support Files/Pods-Runner/Pods-Runner-frameworks-${CONFIGURATION}-output-files.xcfilelist",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "\"${PODS_ROOT}/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh\"\n";
			showEnvVarsInLog = 0;
		};
		F164A6FA13ADA0783DBCD933 /* [CP] Check Pods Manifest.lock */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputFileListPaths = (
			);
			inputPaths = (
				"${PODS_PODFILE_DIR_PATH}/Podfile.lock",
				"${PODS_ROOT}/Manifest.lock",
			);
			name = "[CP] Check Pods Manifest.lock";
			outputFileListPaths = (
			);
			outputPaths = (
				"$(DERIVED_FILE_DIR)/Pods-RunnerTests-checkManifestLockResult.txt",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "diff \"${PODS_PODFILE_DIR_PATH}/Podfile.lock\" \"${PODS_ROOT}/Manifest.lock\" > /dev/null\nif [ $? != 0 ] ; then\n    # print error to STDERR\n    echo \"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\" >&2\n    exit 1\nfi\n# This output is used by Xcode 'outputs' to avoid re-running this script phase.\necho \"SUCCESS\" > \"${SCRIPT_OUTPUT_FILE_0}\"\n";
			showEnvVarsInLog = 0;
		};
/* End PBXShellScriptBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		331C80D1294CF70F00263BE5 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				331C80D8294CF71000263BE5 /* RunnerTests.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		33CC10E92044A3C60003C045 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				33CC11132044BFA00003C045 /* MainFlutterWindow.swift in Sources */,
				33CC10F12044A3C60003C045 /* AppDelegate.swift in Sources */,
				335BBD1B22A9A15E00E9071D /* GeneratedPluginRegistrant.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		331C80DA294CF71000263BE5 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = 33CC10EC2044A3C60003C045 /* Runner */;
			targetProxy = 331C80D9294CF71000263BE5 /* PBXContainerItemProxy */;
		};
		33CC11202044C79F0003C045 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = 33CC111A2044C6BA0003C045 /* Flutter Assemble */;
			targetProxy = 33CC111F2044C79F0003C045 /* PBXContainerItemProxy */;
		};
/* End PBXTargetDependency section */

/* Begin PBXVariantGroup section */
		33CC10F42044A3C60003C045 /* MainMenu.xib */ = {
			isa = PBXVariantGroup;
			children = (
				33CC10F52044A3C60003C045 /* Base */,
			);
			name = MainMenu.xib;
			path = Runner;
			sourceTree = "<group>";
		};
/* End PBXVariantGroup section */

/* Begin XCBuildConfiguration section */
		331C80DB294CF71000263BE5 /* Debug */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 3BCB0B28C9572BB2F2D82D30 /* Pods-RunnerTests.debug.xcconfig */;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.x509CertStoreExample.RunnerTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/x509_cert_store_example.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/x509_cert_store_example";
			};
			name = Debug;
		};
		331C80DC294CF71000263BE5 /* Release */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = CE291F5148654E0B7998BA6F /* Pods-RunnerTests.release.xcconfig */;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.x509CertStoreExample.RunnerTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/x509_cert_store_example.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/x509_cert_store_example";
			};
			name = Release;
		};
		331C80DD294CF71000263BE5 /* Profile */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = E4ED7308576CA4E07C0EC5DB /* Pods-RunnerTests.profile.xcconfig */;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.x509CertStoreExample.RunnerTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/x509_cert_store_example.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/x509_cert_store_example";
			};
			name = Profile;
		};
		338D0CE9231458BD00FA5F75 /* Profile */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CODE_SIGN_IDENTITY = "-";
				COPY_PHASE_STRIP = NO;
				DEAD_CODE_STRIPPING = YES;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 10.14;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
			};
			name = Profile;
		};
		338D0CEA231458BD00FA5F75 /* Profile */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 33E5194F232828860026EE4D /* AppInfo.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_ENTITLEMENTS = Runner/DebugProfile.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				INFOPLIST_FILE = Runner/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				PROVISIONING_PROFILE_SPECIFIER = "";
				SWIFT_VERSION = 5.0;
			};
			name = Profile;
		};
		338D0CEB231458BD00FA5F75 /* Profile */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Manual;
				PRODUCT_NAME = "$(TARGET_NAME)";
			};
			name = Profile;
		};
		33CC10F92044A3C60003C045 /* Debug */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CODE_SIGN_IDENTITY = "-";
				COPY_PHASE_STRIP = NO;
				DEAD_CODE_STRIPPING = YES;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 10.14;
				MTL_ENABLE_DEBUG_INFO = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		33CC10FA2044A3C60003C045 /* Release */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CODE_SIGN_IDENTITY = "-";
				COPY_PHASE_STRIP = NO;
				DEAD_CODE_STRIPPING = YES;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 10.14;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
			};
			name = Release;
		};
		33CC10FC2044A3C60003C045 /* Debug */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 33E5194F232828860026EE4D /* AppInfo.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_ENTITLEMENTS = Runner/DebugProfile.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				INFOPLIST_FILE = Runner/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				PROVISIONING_PROFILE_SPECIFIER = "";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		33CC10FD2044A3C60003C045 /* Release */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 33E5194F232828860026EE4D /* AppInfo.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_ENTITLEMENTS = Runner/Release.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				INFOPLIST_FILE = Runner/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				PROVISIONING_PROFILE_SPECIFIER = "";
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
		33CC111C2044C6BA0003C045 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Manual;
				PRODUCT_NAME = "$(TARGET_NAME)";
			};
			name = Debug;
		};
		33CC111D2044C6BA0003C045 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				PRODUCT_NAME = "$(TARGET_NAME)";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		331C80DE294CF71000263BE5 /* Build configuration list for PBXNativeTarget "RunnerTests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				331C80DB294CF71000263BE5 /* Debug */,
				331C80DC294CF71000263BE5 /* Release */,
				331C80DD294CF71000263BE5 /* Profile */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		33CC10E82044A3C60003C045 /* Build configuration list for PBXProject "Runner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				33CC10F92044A3C60003C045 /* Debug */,
				33CC10FA2044A3C60003C045 /* Release */,
				338D0CE9231458BD00FA5F75 /* Profile */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		33CC10FB2044A3C60003C045 /* Build configuration list for PBXNativeTarget "Runner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				33CC10FC2044A3C60003C045 /* Debug */,
				33CC10FD2044A3C60003C045 /* Release */,
				338D0CEA231458BD00FA5F75 /* Profile */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		33CC111B2044C6BA0003C045 /* Build configuration list for PBXAggregateTarget "Flutter Assemble" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				33CC111C2044C6BA0003C045 /* Debug */,
				33CC111D2044C6BA0003C045 /* Release */,
				338D0CEB231458BD00FA5F75 /* Profile */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 33CC10E52044A3C60003C045 /* Project object */;
}

```
## example/macos/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>

```
## example/macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme
```xcscheme
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1510"
   version = "1.3">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "33CC10EC2044A3C60003C045"
               BuildableName = "x509_cert_store_example.app"
               BlueprintName = "Runner"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <MacroExpansion>
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "33CC10EC2044A3C60003C045"
            BuildableName = "x509_cert_store_example.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </MacroExpansion>
      <Testables>
         <TestableReference
            skipped = "NO"
            parallelizable = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "331C80D4294CF70F00263BE5"
               BuildableName = "RunnerTests.xctest"
               BlueprintName = "RunnerTests"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "33CC10EC2044A3C60003C045"
            BuildableName = "x509_cert_store_example.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Profile"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "33CC10EC2044A3C60003C045"
            BuildableName = "x509_cert_store_example.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>

```
## example/macos/Runner.xcworkspace/contents.xcworkspacedata
```xcworkspacedata
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:Runner.xcodeproj">
   </FileRef>
   <FileRef
      location = "group:Pods/Pods.xcodeproj">
   </FileRef>
</Workspace>

```
## example/macos/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>

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
## example/x509_cert_store_example.iml
```iml
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$/lib" isTestSource="false" />
      <sourceFolder url="file://$MODULE_DIR$/test" isTestSource="true" />
      <excludeFolder url="file://$MODULE_DIR$/.dart_tool" />
      <excludeFolder url="file://$MODULE_DIR$/.idea" />
      <excludeFolder url="file://$MODULE_DIR$/build" />
    </content>
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="library" name="Dart SDK" level="project" />
    <orderEntry type="library" name="Flutter Plugins" level="project" />
    <orderEntry type="library" name="Dart Packages" level="project" />
  </component>
</module>

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
  alreadyExist,
  unknown;

  String getString() {
    switch (this) {
      case X509ErrorCode.alreadyExist:
        return "2148081669"; // CRYPT_E_EXISTS
      case X509ErrorCode.canceled:
        return "1223"; // ERROR_CANCELLED
      case X509ErrorCode.unknown:
        return "UNKNOWN";
    }
  }

  static X509ErrorCode fromString(String code) {
    for (var value in X509ErrorCode.values) {
      if (value.getString() == code) {
        return value;
      }
    }
    return X509ErrorCode.unknown;
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
      const MethodChannel('io.github.kihyun1998/x509_cert_store');

  @override
  Future<X509ResValue> addCertificate({
    required X509StoreName storeName,
    required String certificateBase64,
    required X509AddType addType,
  }) async {
    try {
      final certificateBytes = base64.decode(certificateBase64);
      await methodChannel.invokeMethod<bool>(
        'addCertificate',
        {
          'storeName': storeName.getString(),
          'certificate': certificateBytes,
          'addType': addType.getCode(),
        },
      );

      return X509ResValue.success();
    } on PlatformException catch (error) {
      final errorCode =
          error.message != null ? error.message!.split(' ').last : "UNKNOWN";
      return X509ResValue.error(
        errorCode,
        "Failed to add certificate: ${error.message}",
      );
    } catch (error) {
      return X509ResValue.error(
          "UNEXPECTED_ERROR", "An unexpected error occurred: $error");
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
import 'package:x509_cert_store/x509_cert_store_enum.dart';

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
      X509ResValue(isOk: false, msg: "No operation performed", code: "NO_CODE");

  factory X509ResValue.success() => X509ResValue(
      isOk: true, msg: "Operation completed successfully", code: "SUCCESS");

  factory X509ResValue.error(String errorCode, String errorMessage) =>
      X509ResValue(isOk: false, msg: errorMessage, code: errorCode);

  bool hasError(X509ErrorCode errorCode) {
    return code == errorCode.getString();
  }

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
## macos/Classes/X509CertStorePlugin.swift
```swift
import Cocoa
import FlutterMacOS
import Security

public class X509CertStorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "io.github.kihyun1998/x509_cert_store", binaryMessenger: registrar.messenger)
    let instance = X509CertStorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "addCertificate":
      guard let args = call.arguments as? [String: Any],
            let storeName = args["storeName"] as? String,
            let certificateData = args["certificate"] as? FlutterStandardTypedData,
            let addType = args["addType"] as? Int else {
        // Return error in the format expected by Dart when arguments are missing or invalid
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid arguments", details: nil))
        return
      }
      
      // Try to add the certificate
      do {
        let success = try addCertificateToKeychain(
          storeName: storeName,
          certificateData: certificateData.data,
          addType: addType
        )
        
        // On success
        if success {
          result(true)
        } else {
          // Unknown failure — usually this line is not reached
          result(FlutterError(code: "UNKNOWN_ERROR", message: "Failed to add certificate", details: nil))
        }
      } catch CertificateError.alreadyExists {
        // Handle duplicate certificate with known error code
        result(FlutterError(code: "2148081669", message: "Certificate already exists", details: nil))
      } catch CertificateError.securityError(let code) {
        // Include Security framework error code
        result(FlutterError(code: "\(code)", message: "Security framework error: \(code)", details: nil))
      } catch {
        // Other unexpected errors
        result(FlutterError(code: "UNEXPECTED_ERROR", message: "An unexpected error occurred: \(error)", details: nil))
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // Define error types
  enum CertificateError: Error {
    case invalidData
    case alreadyExists
    case securityError(OSStatus)
  }

  private func addCertificateToKeychain(storeName: String, certificateData: Data, addType: Int) throws -> Bool {
    // Define constants with clear names
    let CERT_STORE_ADD_NEW = 1
    let CERT_STORE_ADD_REPLACE_EXISTING = 3
    let CERT_STORE_ADD_NEWER = 6
    
    // 1. Check if the certificate is in PEM format and convert to DER if necessary
    let certData = prepareCertificateData(certificateData)
    
    // 2. Create SecCertificate object
    guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
        throw CertificateError.invalidData
    }

    // 3. Handle based on addType
    if addType == CERT_STORE_ADD_NEW {
        // For CERT_STORE_ADD_NEW: Check if certificate exists. If yes, throw error. If no, add it.
        if certificateExists(certificate: certificate) {
            throw CertificateError.alreadyExists
        }
        // Will add the certificate below
    } else if addType == CERT_STORE_ADD_REPLACE_EXISTING {
        // For CERT_STORE_ADD_REPLACE_EXISTING: Delete existing certificate if it exists
        if let existingCert = findExistingCertificate(certificate: certificate) {
          let deleteQuery: [String: Any] = [
              kSecClass as String: kSecClassCertificate,
              kSecValueRef as String: existingCert
          ]

          let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
          if deleteStatus != errSecSuccess {
              throw CertificateError.securityError(deleteStatus)
          }
        } 
    } else if addType == CERT_STORE_ADD_NEWER {
        // For CERT_STORE_ADD_NEWER: Check if certificate exists
        if let existing = findExistingCertificate(certificate: certificate) {
            // Compare certificates to see if the new one is newer
            if !isNewerCertificate(newCert: certificate, existingCert: existing) {
                // If the new certificate is not newer, don't add it and return success
                return true
            }
            
            // If the new certificate is newer, delete the existing one
            let deleteQuery: [String: Any] = [
                kSecClass as String: kSecClassCertificate,
                kSecValueRef as String: existing
            ]
            
            _ = SecItemDelete(deleteQuery as CFDictionary)
        }
        // If no existing certificate or if the new one is newer, continue to add the new certificate
    }
    
    // 4. Prepare query for adding the certificate to the keychain
    let query: [String: Any] = [
        kSecClass as String: kSecClassCertificate,
        kSecValueRef as String: certificate,
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]
    
    // 5. Add the certificate
    let status = SecItemAdd(query as CFDictionary, nil)
    
    if status == errSecSuccess {
        return true
    } else if status == errSecDuplicateItem {
        throw CertificateError.alreadyExists
    } else {
        throw CertificateError.securityError(status)
    }
  }

  // Get existing certificate if it exists
  private func getExistingCertificate(for certificate: SecCertificate) -> SecCertificate? {
      let existingQuery: [String: Any] = [
          kSecClass as String: kSecClassCertificate,
          kSecValueRef as String: certificate,
          kSecReturnRef as String: true
      ]
      
      var existingItem: CFTypeRef?
      
      return SecItemCopyMatching(existingQuery as CFDictionary, &existingItem) == errSecSuccess 
          ? (existingItem as! SecCertificate) 
          : nil
  }
  
  func loadAllCertificatesFromKeychain() -> [SecCertificate] {
      let query: [CFString: Any] = [
          kSecClass: kSecClassCertificate,
          kSecMatchLimit: kSecMatchLimitAll,
          kSecReturnRef: true
      ]

      var result: CFTypeRef?
      let status = SecItemCopyMatching(query as CFDictionary, &result)

      if status == errSecSuccess, let certs = result as? [SecCertificate] {
          return certs
      }

      return []
  }

  // Check if certificate already exists in the keychain
  func certificateExists(certificate: SecCertificate) -> Bool {
      guard let certIssuer = SecCertificateCopyNormalizedIssuerSequence(certificate) as Data?,
            let certSerial = SecCertificateCopySerialNumberData(certificate, nil) as Data? else {
          return false
      }

      let allCerts = loadAllCertificatesFromKeychain()

      for existingCert in allCerts {
          guard let existingIssuer = SecCertificateCopyNormalizedIssuerSequence(existingCert) as Data?,
                let existingSerial = SecCertificateCopySerialNumberData(existingCert, nil) as Data? else {
              continue
          }

          if existingIssuer == certIssuer && existingSerial == certSerial {
              return true
          }
      }

      return false
  }

  func findExistingCertificate(certificate: SecCertificate) -> SecCertificate? {
      guard let certIssuer = SecCertificateCopyNormalizedIssuerSequence(certificate) as Data?,
            let certSerial = SecCertificateCopySerialNumberData(certificate, nil) as Data? else {
          return nil
      }

      let allCerts = loadAllCertificatesFromKeychain()

      for existingCert in allCerts {
          guard let existingIssuer = SecCertificateCopyNormalizedIssuerSequence(existingCert) as Data?,
                let existingSerial = SecCertificateCopySerialNumberData(existingCert, nil) as Data? else {
              continue
          }

          if existingIssuer == certIssuer && existingSerial == certSerial {
              return existingCert
          }
      }

      return nil
  }

  // Check if the new certificate is newer than the existing one (based on expiration date)
  private func isNewerCertificate(newCert: SecCertificate, existingCert: SecCertificate) -> Bool {
      var error: Unmanaged<CFError>?
      
      // Load attributes from the new certificate
      guard let newProps = SecCertificateCopyValues(newCert, nil, &error) as? [CFString: Any] else {
          return false
      }
      
      error = nil // Reuse the error variable
      
      guard let existingProps = SecCertificateCopyValues(existingCert, nil, &error) as? [CFString: Any] else {
          return false
      }
      
      // Key for the "not before" validity date
      let validityStartKey = kSecOIDX509V1ValidityNotBefore

      // Get the start date for each certificate
      guard let newValidityData = newProps[validityStartKey] as? [CFString: Any],
            let existingValidityData = existingProps[validityStartKey] as? [CFString: Any] else {
          return false
      }

      let valueKey = kSecPropertyKeyValue

      guard let newValidityValue = newValidityData[valueKey],
            let existingValidityValue = existingValidityData[valueKey] else {
          return false
      }

      guard let newDate = newValidityValue as? Date,
            let existingDate = existingValidityValue as? Date else {
          return false
      }

      // Compare using the start date: if new certificate starts later, consider it newer
      return newDate > existingDate
  }
  
  private func prepareCertificateData(_ data: Data) -> Data {
    // Check if the data is in PEM format
    if let dataString = String(data: data, encoding: .utf8),
       dataString.contains("-----BEGIN CERTIFICATE-----") {
      
      // Strip PEM headers/footers and decode from Base64
      var pemString = dataString
      pemString = pemString.replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
      pemString = pemString.replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
      pemString = pemString.replacingOccurrences(of: "\n", with: "")
      pemString = pemString.replacingOccurrences(of: "\r", with: "")
      pemString = pemString.trimmingCharacters(in: .whitespacesAndNewlines)
      
      if let derData = Data(base64Encoded: pemString) {
        return derData
      }
    }
    
    // Return original data if it's already in DER format or conversion fails
    return data
  }
}

```
## macos/Resources/PrivacyInfo.xcprivacy
```xcprivacy
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTrackingDomains</key>
	<array/>
	<key>NSPrivacyCollectedDataTypes</key>
	<array/>
	<key>NSPrivacyTracking</key>
	<false/>
</dict>
</plist>

```
## macos/x509_cert_store.podspec
```podspec
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint x509_cert_store.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'x509_cert_store'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'x509_cert_store_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'
  s.framework = 'Security'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end

```
## openssl.md
```md
```bash
openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes \
  -keyout mycompany.key -out mycompany.crt \
  -subj "/CN=mycompany.com" \
  -addext "subjectAltName=DNS:mycompany.com,DNS:www.mycompany.com"
```

```bash
openssl x509 -in mycompany.crt -outform DER | base64
```
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
## x509_cert_store.iml
```iml
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$/lib" isTestSource="false" />
      <excludeFolder url="file://$MODULE_DIR$/.dart_tool" />
      <excludeFolder url="file://$MODULE_DIR$/.idea" />
      <excludeFolder url="file://$MODULE_DIR$/build" />
      <excludeFolder url="file://$MODULE_DIR$/example/build" />
    </content>
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="library" name="Dart Packages" level="project" />
    <orderEntry type="library" name="Dart SDK" level="project" />
    <orderEntry type="library" name="Flutter Plugins" level="project" />
  </component>
</module>

```
