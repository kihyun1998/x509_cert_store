import 'dart:ffi';

import 'core_foundation.dart';

/// FFI bindings to the Security framework entry points used by the keychain
/// backend, plus the CFString constants that form the query dictionaries.
final DynamicLibrary _security = DynamicLibrary.open(
    '/System/Library/Frameworks/Security.framework/Security');

/// `SecCertificateRef SecCertificateCreateWithData(CFAllocatorRef, CFDataRef)`
///
/// Returns null when the data is not a valid DER certificate, which is how
/// the backend detects `invalidFormat`.
final Pointer<Void> Function(Pointer<Void>, Pointer<Void>)
    secCertificateCreateWithData = _security.lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Void>),
        Pointer<Void> Function(
            Pointer<Void>, Pointer<Void>)>('SecCertificateCreateWithData');

/// `CFDataRef SecCertificateCopyData(SecCertificateRef)`
///
/// Recovers the DER of a certificate already in the keychain so its identity
/// fields can be parsed in Dart.
final Pointer<Void> Function(Pointer<Void>) secCertificateCopyData =
    _security.lookupFunction<Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)>('SecCertificateCopyData');

/// `OSStatus SecItemAdd(CFDictionaryRef, CFTypeRef*)`
final int Function(Pointer<Void>, Pointer<Pointer<Void>>) secItemAdd =
    _security.lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Pointer<Void>>),
        int Function(Pointer<Void>, Pointer<Pointer<Void>>)>('SecItemAdd');

/// `OSStatus SecItemCopyMatching(CFDictionaryRef, CFTypeRef*)`
final int Function(Pointer<Void>, Pointer<Pointer<Void>>) secItemCopyMatching =
    _security.lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Pointer<Void>>),
        int Function(
            Pointer<Void>, Pointer<Pointer<Void>>)>('SecItemCopyMatching');

/// `OSStatus SecItemDelete(CFDictionaryRef)`
final int Function(Pointer<Void>) secItemDelete = _security.lookupFunction<
    Int32 Function(Pointer<Void>),
    int Function(Pointer<Void>)>('SecItemDelete');

/// Keychain query keys and values, each a `CFStringRef` global.
final Pointer<Void> kSecClass = cfConstant(_security, 'kSecClass');
final Pointer<Void> kSecClassCertificate =
    cfConstant(_security, 'kSecClassCertificate');
final Pointer<Void> kSecValueRef = cfConstant(_security, 'kSecValueRef');
final Pointer<Void> kSecAttrAccessible =
    cfConstant(_security, 'kSecAttrAccessible');
final Pointer<Void> kSecAttrAccessibleAfterFirstUnlock =
    cfConstant(_security, 'kSecAttrAccessibleAfterFirstUnlock');
final Pointer<Void> kSecMatchLimit = cfConstant(_security, 'kSecMatchLimit');
final Pointer<Void> kSecMatchLimitAll =
    cfConstant(_security, 'kSecMatchLimitAll');
final Pointer<Void> kSecReturnRef = cfConstant(_security, 'kSecReturnRef');

/// `OSStatus` values that map onto an [X509ErrorCode] category.
const int errSecSuccess = 0;
const int errSecUserCanceled = -128;
const int errSecAuthFailed = -25293;
const int errSecDuplicateItem = -25299;
const int errSecItemNotFound = -25300;
const int errSecDecode = -26275;
