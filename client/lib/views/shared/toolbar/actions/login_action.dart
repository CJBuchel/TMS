import 'package:flutter/material.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/utils/navigator_wrappers.dart';

class TmsToolBarLoginAction extends StatelessWidget {
  final bool? listTile;
  const TmsToolBarLoginAction({
    Key? key,
    this.listTile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: NetworkAuth.loginState,
      builder: (context, loggedIn, _) {
        if (listTile ?? false) {
          return ListTile(
            leading: Icon(
              loggedIn ? Icons.person : Icons.login,
              color: loggedIn ? Colors.white : Colors.red,
            ),
            title: Text(loggedIn ? "Logout" : "Login"),
            onTap: () => pushTo(context, loggedIn ? "/logout" : "/login"),
          );
        } else {
          return IconButton(
            icon: Icon(
              loggedIn ? Icons.person : Icons.login,
              color: loggedIn ? Colors.white : Colors.red,
            ),
            onPressed: () => pushTo(context, loggedIn ? "/logout" : "/login"),
          );
        }
      },
    );
  }
}
