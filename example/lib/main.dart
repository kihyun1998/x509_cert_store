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
