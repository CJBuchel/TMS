import 'package:flutter/material.dart';

/// Reusable layout for settings pages with consistent styling
class SettingsPageLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final double maxWidth;

  const SettingsPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
