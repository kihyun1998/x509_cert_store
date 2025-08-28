## 1.2.1

### Fixed
- Fixed Swift compilation errors in macOS implementation
- Corrected protocol conformance issues in SystemKeyChain class
- Fixed missing bracket in certificate deletion logic

## 1.2.0

### Added
- Certificate trust functionality for macOS platform (using `setTrusted` parameter)
- Enhanced certificate management with trust settings support on macOS
- Comprehensive certificate existence checking with keychain-specific operations

### Fixed  
- Fixed certificate addition issues on macOS that were preventing certificates from being added properly
- Improved certificate duplicate detection and replacement logic
- Enhanced error handling and logging for better debugging

### Improved
- Implemented fallback mechanisms for certificate trust operations when system-level permissions are not available
- Added detailed logging for certificate operations to help with troubleshooting

## 1.1.3

- update license

## 1.1.2

- update license

## 1.1.1

- Raised macOS deployment target to 10.13 for CocoaPods compatibility.

## 1.1.0

- Added macOS platform support
- Implemented certificate management on macOS:
  - Support for adding certificates to the macOS Keychain
  - Automatic conversion between PEM and DER formats on macOS
  - Certificate duplicate detection and management
  - Proper error handling with descriptive error codes
- Updated documentation to reflect macOS support
- Code organization improvements for cross-platform support

## 1.0.0

- First stable release
- Major code improvements:
  - Consistent error handling across platforms
  - Improved code organization with better separation of concerns
  - Enhanced memory management in C++ code
  - Better type safety in Dart code
  - Proper resource cleanup and error handling in Windows implementation
- Complete documentation with usage examples
- Added proper error code handling with helper functions
- Enhanced certificate format detection (PEM/DER)
- Comprehensive test suite
- Added additional safeguards for certificate context management

## 0.9.5

- Added error code checking functionality with `hasError()` method
- Improved error reporting with specific error codes
- Enhanced return value structure for better error diagnosis

## 0.9.4

- Added support for PEM format certificates
- Automatic detection and conversion between PEM and DER formats
- Improved certificate parsing logic

## 0.9.3

- Improved error catching and reporting
- Better exception handling in native code
- More descriptive error messages

## 0.9.2

- Updated README.md with improved documentation
- Enhanced example code with proper error handling
- Exported necessary packages for easier use

## 0.9.1

- Improved README.md with better installation and usage instructions
- Added code examples and API reference

## 0.9.0

- Initial release
- Basic functionality to add certificates to the Windows certificate store
- Support for ROOT and MY store locations
- Support for different certificate addition modes
