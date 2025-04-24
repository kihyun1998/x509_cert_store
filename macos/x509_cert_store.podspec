#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint x509_cert_store.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'x509_cert_store'
  s.version          = '1.1.0'
  s.summary          = 'A Flutter plugin for macOS and Windows that enables adding X.509 certificates to the local certificate store.'
  s.description      = <<-DESC
A Flutter plugin for macOS and Windows desktop applications that enables adding X.509 certificates to the local certificate store or Keychain. This plugin provides a simple and efficient way to manage certificates in desktop environments, with support for certificate addition types, error handling, and automatic format detection.
                       DESC
  s.homepage         = 'https://github.com/kihyun1998/x509_cert_store'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'kihyun1998' => 'github.com/kihyun1998' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'x509_cert_store_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'
  s.framework = 'Security'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end