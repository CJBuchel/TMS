import 'package:flutter/material.dart';
import 'package:tms_client/views/setup/common/locked_setting.dart';
import 'package:tms_client/views/setup/common/locked_setting_severity.dart';

/// Reusable locked text field setting with unlock/update functionality
/// and optional warning message
class LockedTextFieldSetting extends StatelessWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onUpdate;
  final String? noticeMessage;
  final LockedSettingSeverity severity;

  const LockedTextFieldSetting({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.onUpdate,
    this.noticeMessage,
    this.severity = LockedSettingSeverity.standard,
  });

  /// Factory for standard locked text field
  const LockedTextFieldSetting.standard({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.onUpdate,
    this.noticeMessage,
  }) : severity = LockedSettingSeverity.standard;

  /// Factory for warning-level locked text field
  const LockedTextFieldSetting.warning({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.onUpdate,
    this.noticeMessage,
  }) : severity = LockedSettingSeverity.warning;

  /// Factory for danger-level locked text field
  const LockedTextFieldSetting.danger({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.onUpdate,
    this.noticeMessage,
  }) : severity = LockedSettingSeverity.danger;

  @override
  Widget build(BuildContext context) {
    return LockedSetting(
      label: label,
      description: description,
      severity: severity,
      noticeMessage: noticeMessage,
      actionButtonLabel: 'Update',
      actionIcon: severity == LockedSettingSeverity.standard
          ? Icons.save
          : Icons.warning,
      onAction: onUpdate,
      contentBuilder: (context, isUnlocked) {
        final severityColor = severity.getColor(context);
        return TextField(
          controller: controller,
          enabled: isUnlocked,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hintText,
            prefixIcon: Icon(
              isUnlocked ? Icons.lock_open : Icons.lock,
              color: isUnlocked ? severityColor : null,
            ),
          ),
        );
      },
    );
  }
}
