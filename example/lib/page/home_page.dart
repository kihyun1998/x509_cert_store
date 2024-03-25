import 'package:flutter/material.dart';
import 'package:x509_cert_store_example/page/test_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const TestPage();
                  },
                ));
              },
              child: const Text("Go to test page."),
            ),
          ),
        ],
      ),
    );
  }
}
