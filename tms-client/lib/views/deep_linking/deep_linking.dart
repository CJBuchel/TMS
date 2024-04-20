import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeepLinking extends StatelessWidget {
  void _continueToBrowser(BuildContext context) {
    context.go('/');
  }

  void _openInApp(BuildContext context) async {
    // launch url tms_server://deep_linking
    const deepLink = 'tms_app://connect';
    if (await canLaunchUrlString(deepLink)) {
      await launchUrlString(deepLink);
    } else {
      _continueToBrowser(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    overlayColor: MaterialStateProperty.all(Colors.lightGreen[800]),
                  ),
                  onPressed: () => _openInApp(context),
                  icon: const Icon(Icons.phone_android),
                  label: const Text("Open in App"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _continueToBrowser(context),
                  icon: const Icon(Icons.web),
                  label: const Text("Continue in Browser"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
