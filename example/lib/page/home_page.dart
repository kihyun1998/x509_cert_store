import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:x509_cert_store/x509_cert_store.dart';
import 'package:x509_cert_store/x509_cert_store_enum.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final x509CertStorePlugin = X509CertStore();

    /// example certification
    const String certificationBase64Str =
        "MIIDKjCCAhKgAwIBAgIQFSHum2++9bhOXjAo4Z7hZTANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20wHhcNMjQwMzI1MDQwMTAxWhcNMjUwMzI1MDQyMTAxWjAaMRgwFgYDVQQDDA93d3cuZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDD95UVvL2GmO1Sq2XEE/m7yK1YzqAlOo68zx8Zk5DS0SmK3e990VtdCPP6cZxcGsJHlqBEg2yMuheC37/tqKdZgRxWbA6DBwZdO9iTSsQigDYi6Ak5YbPSis2z2IJ/RtYnbVM0TZxxwRbPK6zw+evoRAAaVohDzzV3YolHezLacLuIuc8ZX4w+oNBM1nhnYcBxKHeZlIdnrTvnqmUNsc5RsTVgiKuF3JuwqMp8iGK2I5OXKX0PU9Xu2DWDgNDyYFje9cuUd5V80AABQr9QgalOaLkfknluWulOLl8yLhg/icuFQucGnHxNDfDo2eRgxRjMFb53VdLSG8BDfk+7HXDxAgMBAAGjbDBqMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwEwGgYDVR0RBBMwEYIPd3d3LmV4YW1wbGUuY29tMB0GA1UdDgQWBBTz3vduP0OefbHqptjxpk1V89RpCjANBgkqhkiG9w0BAQsFAAOCAQEAaShA+e6dBaVt9na97fAgGMEdWpfI66WrJOVn5gczcPCzsjtZTkUjKh7IiZHCeyq5vWHmrG20PZpag34vvk0zacwR9PJeCbCzCmGfJ8miKCaywfxRpJVSWweLyppXRk/TDkXynhGAjD0EMHocc6jClcIrypxB9LjoS2oHA/+iGnx6dLeWf9bpTFBDIAevOXpKhlrSftUM1vaPkMdMN/mEk5mx189382IOsH6gocF+ru8u0PnWAdlF3muGsmvF4K31zVS5vMIQLD76FpO7ee/xrOcYxNS+2dPDDs2m9LlWA4BjUJlyfgM39CCRNyxggLrzYzlo1pT/67JOI/57dVa4YQ==";
    return Scaffold(
      appBar: AppBar(title: const Text("Add Certification Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final rst = await x509CertStorePlugin.addCertificate(
                  storeName: X509StoreName.root,
                  certificateBase64: certificationBase64Str,
                  addType: X509AddType.addNew,
                );
                log(rst.msg);
                if (rst.msg == X509ErrorCode.alreadyExist.getString()) {
                  log("key is already exist.");
                } else if ((rst.msg == X509ErrorCode.canceled.getString())) {
                  log("user canceled add certification.");
                }
              },
              child: const Text("Add_New Certification"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final rst = await x509CertStorePlugin.addCertificate(
                  storeName: X509StoreName.root,
                  certificateBase64: certificationBase64Str,
                  addType: X509AddType.addNewer,
                );
                log(rst.msg);
                if (rst.msg == X509ErrorCode.alreadyExist.getString()) {
                  log("key is already exist.");
                } else if ((rst.msg == X509ErrorCode.canceled.getString())) {
                  log("user canceled add certification.");
                }
              },
              child: const Text("Add_Newer Certification"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final rst = await x509CertStorePlugin.addCertificate(
                  storeName: X509StoreName.root,
                  certificateBase64: certificationBase64Str,
                  addType: X509AddType.addReplaceExisting,
                );
                log(rst.msg);
                if (rst.msg == X509ErrorCode.alreadyExist.getString()) {
                  log("key is already exist.");
                } else if ((rst.msg == X509ErrorCode.canceled.getString())) {
                  log("user canceled add certification.");
                }
              },
              child: const Text("Add ReplaceExisting Certification"),
            ),
          ],
        ),
      ),
    );
  }
}
