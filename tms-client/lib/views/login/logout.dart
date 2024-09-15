import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/providers/auth_provider.dart';

class Logout extends StatelessWidget {
  final AuthProvider _authProvider = AuthProvider();

  void _logoutController(BuildContext context) async {
    int status = await _authProvider.logout();
    if (status == HttpStatus.ok) {
      context.canPop() ? context.pop() : GoRouter.of(context).go('/');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout Failed'),
          content: Text('Server Error: $status'),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.canPop() ? context.pop() : GoRouter.of(context).go('/'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Image.asset(
            'assets/logos/TMS_LOGO_NO_TEXT.png',
            width: 200,
          ),
        ),
      ],
    );
  }

  Widget _currentUser() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Text(
            'Logged in as: ${_authProvider.username}',
            // style: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget _logoutButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
              overlayColor: WidgetStateProperty.all<Color>(Colors.orange[800] ?? Colors.orange),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            onPressed: () => _logoutController(context),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _logo(),
              _currentUser(),
              _logoutButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
