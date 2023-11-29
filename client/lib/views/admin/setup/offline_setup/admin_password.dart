import 'package:flutter/material.dart';

class AdminPasswordSetup extends StatelessWidget {
  final TextEditingController adminPasswordController;
  const AdminPasswordSetup({Key? key, required this.adminPasswordController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Admin Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Admin Password',
              hintText: 'Enter the admin password (default: `password`)',
            ),
          ),
        ),
      ],
    );
  }
}
