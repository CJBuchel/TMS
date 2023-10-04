import 'package:flutter/material.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/tool_bar.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => LogoutState();
}

class LogoutState extends State<Logout> {
  void logoutController(BuildContext context) async {
    NetworkAuth.setUser(User(password: "", username: "", permissions: Permissions(admin: false)));
    NetworkAuth.setToken("");
    NetworkAuth.setLoginState(false);
    Navigator.popAndPushNamed(context, "/login");
  }

  User _user = User(password: "", permissions: Permissions(admin: false), username: "");

  @override
  void initState() {
    super.initState();
    NetworkAuth.getUser().then((user) {
      setState(() {
        _user = user;
      });
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
      appBar: const TmsToolBar(displayActions: false),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                child: Text(
                  "Logged in as: ",
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
                child: Text(
                  _user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[900]),
                  onPressed: () => logoutController(context),
                  icon: const Icon(Icons.logout_sharp),
                  label: const Text("Logout"),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
