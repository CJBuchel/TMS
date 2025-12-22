import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tms_client/views/setup/common/setting_row.dart';

/// Reusable text field setting with update button
class TextFieldSetting extends StatelessWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onUpdate;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool obscureText;

  const TextFieldSetting({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.onUpdate,
    this.enabled = true,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      label: label,
      description: description,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hintText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: enabled ? onUpdate : null,
            icon: const Icon(Icons.save),
            label: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
