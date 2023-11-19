import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/user_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/shared/toolbar/tool_bar.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void loginController(BuildContext context) async {
    loginRequest(_usernameController.text, _passwordController.text).then((res) {
      if (res == HttpStatus.ok) {
        // Pop screen
        Navigator.pop(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("Login Error"),
            content: SingleChildScrollView(
              child: Text(res == HttpStatus.unauthorized ? "Incorrect Username or Password" : "Server Error"),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(displayLogicActions: false),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logos/TMS_LOGO.png',
                height: Responsive.imageSize(context, 1).item1,
                width: Responsive.imageSize(context, 1).item2,
              ),
            ],
          ),

          // Username
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: Responsive.imageSize(context, 1).item2,
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
              )
            ],
          ),

          // Password
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: Responsive.imageSize(context, 1).item2,
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

          // Submit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: Responsive.buttonWidth(context, 1),
                height: Responsive.buttonHeight(context, 1),
                child: ElevatedButton.icon(
                  onPressed: () => loginController(context),
                  icon: const Icon(Icons.login),
                  label: const Text("Login"),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
