import 'dart:ffi';

/// FFI bindings to the CoreFoundation types the Security framework calls
/// take and return.
///
/// Lazily initialized top-level `final`s, so importing this file on Windows
/// never attempts to open the framework.
final DynamicLibrary _coreFoundation = DynamicLibrary.open(
    '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation');

/// Reads a CoreFoundation constant, which is exported as a pointer-sized
/// variable holding the object reference, so the symbol must be dereferenced.
Pointer<Void> cfConstant(DynamicLibrary library, String symbol) =>
    library.lookup<Pointer<Void>>(symbol).value;

/// `void CFRelease(CFTypeRef)`
final void Function(Pointer<Void>) cfRelease = _coreFoundation.lookupFunction<
    Void Function(Pointer<Void>), void Function(Pointer<Void>)>('CFRelease');

/// `CFTypeRef CFRetain(CFTypeRef)`
///
/// Needed to hold a certificate past the lifetime of the CFArray that
/// `SecItemCopyMatching` returned it in: array elements are owned by the
/// array, so using one after releasing the array would be a use-after-free.
final Pointer<Void> Function(Pointer<Void>) cfRetain =
    _coreFoundation.lookupFunction<Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)>('CFRetain');

/// `CFDataRef CFDataCreate(CFAllocatorRef, const UInt8*, CFIndex)`
final Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>, int) cfDataCreate =
    _coreFoundation.lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Uint8>, IntPtr),
        Pointer<Void> Function(
            Pointer<Void>, Pointer<Uint8>, int)>('CFDataCreate');

/// `const UInt8* CFDataGetBytePtr(CFDataRef)`
final Pointer<Uint8> Function(Pointer<Void>) cfDataGetBytePtr =
    _coreFoundation.lookupFunction<Pointer<Uint8> Function(Pointer<Void>),
        Pointer<Uint8> Function(Pointer<Void>)>('CFDataGetBytePtr');

/// `CFIndex CFDataGetLength(CFDataRef)`
final int Function(Pointer<Void>) cfDataGetLength =
    _coreFoundation.lookupFunction<IntPtr Function(Pointer<Void>),
        int Function(Pointer<Void>)>('CFDataGetLength');

/// `CFDictionaryRef CFDictionaryCreate(CFAllocatorRef, const void** keys,
/// const void** values, CFIndex, const CFDictionaryKeyCallBacks*,
/// const CFDictionaryValueCallBacks*)`
final Pointer<Void> Function(Pointer<Void>, Pointer<Pointer<Void>>,
        Pointer<Pointer<Void>>, int, Pointer<Void>, Pointer<Void>)
    cfDictionaryCreate = _coreFoundation.lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Pointer<Void>>,
            Pointer<Pointer<Void>>, IntPtr, Pointer<Void>, Pointer<Void>),
        Pointer<Void> Function(
            Pointer<Void>,
            Pointer<Pointer<Void>>,
            Pointer<Pointer<Void>>,
            int,
            Pointer<Void>,
            Pointer<Void>)>('CFDictionaryCreate');

/// `CFIndex CFArrayGetCount(CFArrayRef)`
final int Function(Pointer<Void>) cfArrayGetCount =
    _coreFoundation.lookupFunction<IntPtr Function(Pointer<Void>),
        int Function(Pointer<Void>)>('CFArrayGetCount');

/// `const void* CFArrayGetValueAtIndex(CFArrayRef, CFIndex)`
final Pointer<Void> Function(Pointer<Void>, int) cfArrayGetValueAtIndex =
    _coreFoundation.lookupFunction<
        Pointer<Void> Function(Pointer<Void>, IntPtr),
        Pointer<Void> Function(Pointer<Void>, int)>('CFArrayGetValueAtIndex');

/// The retain/release callback tables that make a CFDictionary own its keys
/// and values. These symbols are structs, so the symbol address is the value
/// to pass - unlike the object constants read through [cfConstant].
final Pointer<Void> kCFTypeDictionaryKeyCallBacks =
    _coreFoundation.lookup<Void>('kCFTypeDictionaryKeyCallBacks');
final Pointer<Void> kCFTypeDictionaryValueCallBacks =
    _coreFoundation.lookup<Void>('kCFTypeDictionaryValueCallBacks');

/// `const CFBooleanRef kCFBooleanTrue`
final Pointer<Void> kCFBooleanTrue =
    cfConstant(_coreFoundation, 'kCFBooleanTrue');
