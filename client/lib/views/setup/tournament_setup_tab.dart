import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum Season {
  fall,
  winter,
  spring,
  summer;

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class TournamentSetupTab extends HookConsumerWidget {
  const TournamentSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: 'Tournament Name');
    final eventKeyController = useTextEditingController(text: 'EVENT_KEY');
    final selectedSeason = useState<Season>(Season.fall);
    final isEventKeyUnlocked = useState(false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tournament Setup',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Configure your tournament settings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              _SettingRow(
                label: 'Tournament Name',
                description: 'The display name for your tournament',
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter tournament name',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        // TODO: Update tournament name
                        print('Update name: ${nameController.text}');
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Update'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SettingRow(
                label: 'Season',
                description: 'The season this tournament takes place in',
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Season>(
                        value: selectedSeason.value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: Season.values.map((season) {
                          return DropdownMenuItem(
                            value: season,
                            child: Text(season.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedSeason.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        // TODO: Update season
                        print('Update season: ${selectedSeason.value}');
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Update'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SettingRow(
                label: 'Event Key',
                description: 'Unique identifier for this tournament event',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: eventKeyController,
                            enabled: isEventKeyUnlocked.value,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter event key',
                              prefixIcon: Icon(
                                isEventKeyUnlocked.value
                                    ? Icons.lock_open
                                    : Icons.lock,
                                color: isEventKeyUnlocked.value
                                    ? Theme.of(context).colorScheme.error
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (!isEventKeyUnlocked.value)
                          OutlinedButton.icon(
                            onPressed: () {
                              isEventKeyUnlocked.value = true;
                            },
                            icon: const Icon(Icons.lock_open),
                            label: const Text('Unlock'),
                          )
                        else ...[
                          OutlinedButton.icon(
                            onPressed: () {
                              isEventKeyUnlocked.value = false;
                            },
                            icon: const Icon(Icons.lock),
                            label: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: () {
                              // TODO: Update event key
                              print(
                                'Update event key: ${eventKeyController.text}',
                              );
                              isEventKeyUnlocked.value = false;
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onError,
                            ),
                            icon: const Icon(Icons.warning),
                            label: const Text('Update'),
                          ),
                        ],
                      ],
                    ),
                    if (isEventKeyUnlocked.value) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.errorContainer.withOpacity(0.5),
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
                                'WARNING: Changing the event key can cause data inconsistencies and break integrations. Only modify if absolutely necessary.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String description;
  final Widget child;

  const _SettingRow({
    required this.label,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
