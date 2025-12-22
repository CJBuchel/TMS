import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tms_client/views/setup/common/locked_setting_severity.dart';
import 'package:tms_client/views/setup/common/setting_row.dart';

/// Generic locked setting with unlock/action functionality
/// Supports custom content via builder pattern
class LockedSetting extends HookWidget {
  final String label;
  final String description;
  final Widget Function(BuildContext context, bool isUnlocked) contentBuilder;
  final String actionButtonLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final String? noticeMessage;
  final LockedSettingSeverity severity;

  const LockedSetting({
    super.key,
    required this.label,
    required this.description,
    required this.contentBuilder,
    required this.actionButtonLabel,
    required this.actionIcon,
    required this.onAction,
    this.noticeMessage,
    this.severity = LockedSettingSeverity.standard,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = useState(false);
    final severityColor = severity.getColor(context);
    final containerColor = severity.getContainerColor(context);
    final onColor = severity.getOnColor(context);

    return SettingRow(
      label: label,
      description: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: contentBuilder(context, isUnlocked.value)),
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
                    onAction();
                    isUnlocked.value = false;
                  },
                  style: severity != LockedSettingSeverity.standard
                      ? FilledButton.styleFrom(
                          backgroundColor: severityColor,
                          foregroundColor: onColor,
                        )
                      : null,
                  icon: Icon(actionIcon),
                  label: Text(actionButtonLabel),
                ),
              ],
            ],
          ),
          if (isUnlocked.value && noticeMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: containerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: severityColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(severity.getIcon(), color: severityColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      noticeMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: severityColor,
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
