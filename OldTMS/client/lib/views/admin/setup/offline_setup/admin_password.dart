import 'package:flutter/material.dart';

class AdminPasswordSetup extends StatelessWidget {
  final TextEditingController adminPasswordController;
  const AdminPasswordSetup({Key? key, required this.adminPasswordController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Admin Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextField(
            controller: adminPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Set Admin Password',
              hintText: 'Set the admin password (default: `password`)',
            ),
          ),
        ),
      ],
    );
  }
}
