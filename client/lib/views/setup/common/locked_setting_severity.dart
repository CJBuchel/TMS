import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';

/// Severity levels for locked settings
enum LockedSettingSeverity {
  /// Standard severity - default blue/neutral styling
  standard,

  /// Warning severity - orange styling for cautionary actions
  warning,

  /// Danger severity - red/error styling for destructive actions
  danger,
}

/// Extension to get theme colors for each severity level
extension LockedSettingSeverityColors on LockedSettingSeverity {
  Color getColor(BuildContext context) {
    switch (this) {
      case LockedSettingSeverity.standard:
        return Theme.of(context).colorScheme.primary;
      case LockedSettingSeverity.warning:
        return supportWarningColor;
      case LockedSettingSeverity.danger:
        return Theme.of(context).colorScheme.error;
    }
  }

  Color getContainerColor(BuildContext context) {
    switch (this) {
      case LockedSettingSeverity.standard:
        return Theme.of(context).colorScheme.primaryContainer;
      case LockedSettingSeverity.warning:
        return supportWarningColor[700]!;
      case LockedSettingSeverity.danger:
        return Theme.of(context).colorScheme.errorContainer;
    }
  }

  Color getOnColor(BuildContext context) {
    switch (this) {
      case LockedSettingSeverity.standard:
        return Theme.of(context).colorScheme.onPrimary;
      case LockedSettingSeverity.warning:
        return Colors.white;
      case LockedSettingSeverity.danger:
        return Theme.of(context).colorScheme.onError;
    }
  }

  IconData getIcon() {
    switch (this) {
      case LockedSettingSeverity.standard:
        return Icons.info_outline;
      case LockedSettingSeverity.warning:
        return Icons.warning_amber;
      case LockedSettingSeverity.danger:
        return Icons.warning_amber;
    }
  }
}
