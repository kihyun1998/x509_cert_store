import 'dart:io';
import 'dart:typed_data';

import '../pem.dart';
import '../x509_store_enums.dart' show X509StoreName;

/// Configures a certificate as trusted by invoking `/usr/bin/security`.
///
/// The Security framework exposes no supported API for writing trust settings
/// to the admin domain, so the Swift implementation already shelled out to the
/// `security` tool; the only part that was Objective-C was the `NSAppleScript`
/// used to elevate, which `osascript` replaces one-for-one. `security
/// add-trusted-cert` only accepts a file path, hence the temporary PEM.
///
/// Trust configuration is best effort: the certificate has already been added
/// by the time this runs, so a failure here must not fail the operation. Every
/// path swallows its errors, matching the Swift `try?`.
Future<void> applyTrust(Uint8List der, X509StoreName storeName) async {
  Directory? tempDir;
  try {
    tempDir = await Directory.systemTemp.createTemp('x509_cert_store_');
    final pemFile = File('${tempDir.path}${Platform.pathSeparator}cert.pem');
    await pemFile.writeAsString(Pem.encodePem(der));

    // The system keychain needs administrator rights. Fall back to an
    // unelevated invocation when elevation is unavailable or declined, which
    // is what the Swift implementation did on any NSAppleScript error.
    if (storeName == X509StoreName.root) {
      if (await _addTrustedCertElevated(pemFile.path)) return;
    }
    await _addTrustedCert(pemFile.path);
  } catch (_) {
    // Best effort - see the doc comment.
  } finally {
    try {
      await tempDir?.delete(recursive: true);
    } catch (_) {
      // A leftover temp file is not worth failing over.
    }
  }
}

/// Flags shared by both invocations: add to the admin trust domain as a
/// trusted root for the four policies the plugin has always requested.
const List<String> _trustArguments = [
  'add-trusted-cert',
  '-d',
  '-r',
  'trustRoot',
  '-p',
  'ssl',
  '-p',
  'smime',
  '-p',
  'codeSign',
  '-p',
  'basic',
];

Future<bool> _addTrustedCert(String pemPath) async {
  final result =
      await Process.run('/usr/bin/security', [..._trustArguments, pemPath]);
  return result.exitCode == 0;
}

/// Runs the same command with administrator privileges, targeting the system
/// keychain explicitly.
///
/// The script is passed to `osascript` as a single argument, so no shell
/// expands it; the path is single-quoted for the inner `do shell script`.
Future<bool> _addTrustedCertElevated(String pemPath) async {
  final command = [
    'security',
    ..._trustArguments,
    '-k',
    '/Library/Keychains/System.keychain',
    "'$pemPath'",
  ].join(' ');
  final script = 'do shell script "$command" with administrator privileges';

  final result = await Process.run('/usr/bin/osascript', ['-e', script]);
  return result.exitCode == 0;
}
