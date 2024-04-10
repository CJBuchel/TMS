import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/providers/auth_provider.dart';

class Login extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthProvider _authProvider = AuthProvider();

  void _loginController(BuildContext context) async {
    int status = await _authProvider.login(_usernameController.text, _passwordController.text);

    if (status == HttpStatus.ok) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(status == HttpStatus.unauthorized ? "Incorrect Username or Password" : "Server Error: $status"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logos/TMS_LOGO.png',
              width: 200,
            ),
          ],
        ),

        // Username
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0, bottom: 25),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter username, e.g `admin`',
                  ),
                ),
              ),
            ),
          ],
        ),

        // Password
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0, bottom: 25),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter password, e.g `password1!`',
                  ),
                ),
              ),
            )
          ],
        ),

        // Login button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _loginController(context),
                icon: const Icon(Icons.login),
                label: const Text("Login"),
              ),
            )
          ],
        )
      ],
    );
  }
}
