# Changelog

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
