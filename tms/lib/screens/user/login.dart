import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/login_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/screens/shared/tool_bar.dart';

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
    var imageSize = <double>[300, 500];
    double buttonWidth = 250;
    double buttonHeight = 50;
    if (Responsive.isTablet(context)) {
      imageSize = [150, 300];
      buttonWidth = 200;
    } else if (Responsive.isMobile(context)) {
      imageSize = [100, 250];
      buttonWidth = 150;
      buttonHeight = 40;
    }

    return Scaffold(
      appBar: TmsToolBar(displayActions: false),
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
                height: imageSize[0],
                width: imageSize[1],
              ),
            ],
          ),

          // Username
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: imageSize[1],
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
                width: imageSize[1],
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
                width: buttonWidth,
                height: buttonHeight,
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
