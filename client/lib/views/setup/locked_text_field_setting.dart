import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tms_client/views/setup/setting_row.dart';

/// Reusable locked text field setting with unlock/update functionality
/// and optional warning message
class LockedTextFieldSetting extends HookWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onUpdate;
  final String? warningMessage;
  final bool useErrorStyle;

  const LockedTextFieldSetting({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.onUpdate,
    this.warningMessage,
    this.useErrorStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = useState(false);

    return SettingRow(
      label: label,
      description: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: isUnlocked.value,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: hintText,
                    prefixIcon: Icon(
                      isUnlocked.value ? Icons.lock_open : Icons.lock,
                      color: isUnlocked.value && useErrorStyle
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (!isUnlocked.value)
                OutlinedButton.icon(
                  onPressed: () {
                    isUnlocked.value = true;
                  },
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Unlock'),
                )
              else ...[
                OutlinedButton.icon(
                  onPressed: () {
                    isUnlocked.value = false;
                  },
                  icon: const Icon(Icons.lock),
                  label: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    onUpdate();
                    isUnlocked.value = false;
                  },
                  style: useErrorStyle
                      ? FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                        )
                      : null,
                  icon: Icon(useErrorStyle ? Icons.warning : Icons.save),
                  label: const Text('Update'),
                ),
              ],
            ],
          ),
          if (isUnlocked.value && warningMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      warningMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
