import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Direct FFI bindings to the handful of wincrypt entry points the plugin
/// needs. All of them take and return opaque handles, so no Win32 struct
/// layout has to be reproduced in Dart.
///
/// These are top-level `final`s, which Dart initializes lazily. The libraries
/// are therefore only opened when a Windows store operation actually runs,
/// which keeps this file importable on macOS.
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
/// The last-error value is thread-local, so it must be read on the same
/// thread as the failing call and before any other call can overwrite it.
/// Each use below reads it immediately after the call it describes.
final int Function() getLastError =
    _kernel32.lookupFunction<Uint32 Function(), int Function()>('GetLastError');

/// `X509_ASN_ENCODING | PKCS_7_ASN_ENCODING`, the encoding pair the previous
/// C++ implementation passed to `CertCreateCertificateContext`.
const int x509AsnEncoding = 0x00000001;
const int pkcs7AsnEncoding = 0x00010000;
const int certEncodingTypes = x509AsnEncoding | pkcs7AsnEncoding;

/// Win32 error values that map onto an [X509ErrorCode] category.
const int cryptEExists = 0x80092005; // 2148081669
const int errorCancelled = 1223;
const int errorAccessDenied = 5;
