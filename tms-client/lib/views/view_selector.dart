import 'package:flutter/material.dart';
import 'package:tms/requests/user_requests.dart';

class ViewSelector extends StatelessWidget {
  const ViewSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ElevatedButton(
          onPressed: () => loginRequest("admin", "admin"),
          child: const Text("Login"),
        ),
      ],
    );
  }
}
