import 'package:flutter/material.dart';
import 'package:tms_client/views/setup/common/setting_row.dart';

/// Reusable dropdown setting with update button
class DropdownSetting<T> extends StatelessWidget {
  final String label;
  final String description;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final VoidCallback onUpdate;

  const DropdownSetting({
    super.key,
    required this.label,
    required this.description,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      label: label,
      description: description,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<T>(
              initialValue: value,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: items,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onUpdate,
            icon: const Icon(Icons.save),
            label: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
