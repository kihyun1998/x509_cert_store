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
    );
    expect(rst.isOk, false);
  });
}
