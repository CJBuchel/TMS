import 'package:flutter/material.dart';
import 'package:tms_client/views/setup/common/locked_setting.dart';
import 'package:tms_client/views/setup/common/locked_setting_severity.dart';

/// Reusable locked button setting with unlock/action functionality
/// and notice message for various operation severities
class LockedButtonSetting extends StatelessWidget {
  final String label;
  final String description;
  final String actionButtonLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final String noticeMessage;
  final LockedSettingSeverity severity;

  const LockedButtonSetting({
    super.key,
    required this.label,
    required this.description,
    required this.actionButtonLabel,
    required this.actionIcon,
    required this.onAction,
    required this.noticeMessage,
    this.severity = LockedSettingSeverity.standard,
  });

  /// Factory for standard locked button (neutral/informational)
  const LockedButtonSetting.standard({
    super.key,
    required this.label,
    required this.description,
    required this.actionButtonLabel,
    required this.actionIcon,
    required this.onAction,
    required this.noticeMessage,
  }) : severity = LockedSettingSeverity.standard;

  /// Factory for warning-level locked button (cautionary)
  const LockedButtonSetting.warning({
    super.key,
    required this.label,
    required this.description,
    required this.actionButtonLabel,
    required this.actionIcon,
    required this.onAction,
    required this.noticeMessage,
  }) : severity = LockedSettingSeverity.warning;

  /// Factory for danger-level locked button (destructive)
  const LockedButtonSetting.danger({
    super.key,
    required this.label,
    required this.description,
    required this.actionButtonLabel,
    required this.actionIcon,
    required this.onAction,
    required this.noticeMessage,
  }) : severity = LockedSettingSeverity.danger;

  @override
  Widget build(BuildContext context) {
    return LockedSetting(
      label: label,
      description: description,
      severity: severity,
      noticeMessage: noticeMessage,
      actionButtonLabel: actionButtonLabel,
      actionIcon: actionIcon,
      onAction: onAction,
      contentBuilder: (context, isUnlocked) {
        final severityColor = severity.getColor(context);
        final containerColor = severity.getContainerColor(context);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isUnlocked
                  ? severityColor
                  : Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(4),
            color: isUnlocked ? containerColor.withValues(alpha: 0.5) : null,
          ),
          child: Row(
            children: [
              Icon(
                isUnlocked ? Icons.lock_open : Icons.lock,
                color: isUnlocked
                    ? severityColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                isUnlocked ? _getUnlockedText() : 'Action locked for safety',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isUnlocked
                      ? severityColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getUnlockedText() {
    switch (severity) {
      case LockedSettingSeverity.standard:
        return 'Action unlocked';
      case LockedSettingSeverity.warning:
        return 'Action unlocked - proceed with caution';
      case LockedSettingSeverity.danger:
        return 'Action unlocked - DANGEROUS operation';
    }
  }
}
