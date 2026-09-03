import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Direct FFI bindings to the handful of wincrypt entry points the plugin
/// needs. All of them take and return opaque handles, so no Win32 struct
/// layout has to be reproduced in Dart.
///
/// These are top-level `final`s, which Dart initializes lazily. The libraries
/// are therefore only opened when a Windows store operation actually runs,
/// which keeps this file importable on macOS. That laziness has a sharp edge
/// on Windows specifically - see [ensureBindingsResolved].
final DynamicLibrary _crypt32 = DynamicLibrary.open('crypt32.dll');
final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

/// `HCERTSTORE CertOpenSystemStoreA(HCRYPTPROV_LEGACY, LPCSTR)`
final Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>)
    certOpenSystemStoreA = _crypt32.lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>),
        Pointer<Void> Function(
            Pointer<Void>, Pointer<Utf8>)>('CertOpenSystemStoreA');

/// `PCCERT_CONTEXT CertCreateCertificateContext(DWORD, const BYTE*, DWORD)`
final Pointer<Void> Function(int, Pointer<Uint8>, int)
    certCreateCertificateContext = _crypt32.lookupFunction<
        Pointer<Void> Function(Uint32, Pointer<Uint8>, Uint32),
        Pointer<Void> Function(
            int, Pointer<Uint8>, int)>('CertCreateCertificateContext');

/// `BOOL CertAddCertificateContextToStore(HCERTSTORE, PCCERT_CONTEXT, DWORD,
/// PCCERT_CONTEXT*)`
final int Function(Pointer<Void>, Pointer<Void>, int, Pointer<Pointer<Void>>)
    certAddCertificateContextToStore = _crypt32.lookupFunction<
        Int32 Function(
            Pointer<Void>, Pointer<Void>, Uint32, Pointer<Pointer<Void>>),
        int Function(Pointer<Void>, Pointer<Void>, int,
            Pointer<Pointer<Void>>)>('CertAddCertificateContextToStore');

/// `BOOL CertFreeCertificateContext(PCCERT_CONTEXT)`
final int Function(Pointer<Void>) certFreeCertificateContext = _crypt32
    .lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>(
        'CertFreeCertificateContext');

/// `BOOL CertCloseStore(HCERTSTORE, DWORD)`
final int Function(Pointer<Void>, int) certCloseStore = _crypt32.lookupFunction<
    Int32 Function(Pointer<Void>, Uint32),
    int Function(Pointer<Void>, int)>('CertCloseStore');

/// `DWORD GetLastError(void)`
///
/// The last-error value is thread-local, so it must be read on the same thread
/// as the failing call and before anything else can overwrite it - including
/// the loader, which is what [ensureBindingsResolved] exists to prevent.
final int Function() getLastError =
    _kernel32.lookupFunction<Uint32 Function(), int Function()>('GetLastError');

/// Forces every binding above to resolve, before any of them is called for
/// real. Call this once at the start of a store operation.
///
/// wincrypt reports failures through the thread-local Win32 last-error value.
/// Dart initializes top-level `final`s lazily and gives each isolate its own
/// copy, so without this the first read of [getLastError] runs `LoadLibrary`
/// and `GetProcAddress` - and those *succeed*, resetting the last error to 0.
/// When that first read is the one immediately after a failed wincrypt call,
/// the error it was meant to report is already gone: every failure collapsed
/// into `X509ErrorCode.unknown` with `nativeCode: 0`, which made
/// `alreadyExist` (`CRYPT_E_EXISTS`), `canceled` (`ERROR_CANCELLED`), and
/// `accessDenied` (`ERROR_ACCESS_DENIED`) unreachable.
///
/// Measured, not assumed: with the bindings warm, the value survives the FFI
/// call boundary on both a main and a worker isolate, and `isLeaf` makes no
/// difference either way. Resolving up front is the whole fix.
///
/// macOS needs no equivalent: `OSStatus` is a return value rather than
/// thread-local state, so nothing can overwrite it in between.
void ensureBindingsResolved() {
  final bindings = <Function>[
    certOpenSystemStoreA,
    certCreateCertificateContext,
    certAddCertificateContextToStore,
    certFreeCertificateContext,
    certCloseStore,
    getLastError,
  ];
  assert(bindings.length == 6);
  // Discard whatever the loader left in the last-error slot.
  getLastError();
}

/// `X509_ASN_ENCODING | PKCS_7_ASN_ENCODING`, the encoding pair the previous
/// C++ implementation passed to `CertCreateCertificateContext`.
const int x509AsnEncoding = 0x00000001;
const int pkcs7AsnEncoding = 0x00010000;
const int certEncodingTypes = x509AsnEncoding | pkcs7AsnEncoding;

/// Win32 error values that map onto an [X509ErrorCode] category.
const int cryptEExists = 0x80092005; // 2148081669
const int errorCancelled = 1223;
const int errorAccessDenied = 5;
