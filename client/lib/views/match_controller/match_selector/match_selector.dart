import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/match_provider.dart';

class MatchSelector extends ConsumerWidget {
  const MatchSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchesProvider);

    if (matches.isEmpty) {
      return const Center(child: Text('No matches'));
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final entry = matches.entries.elementAt(index);
        final id = entry.key;
        final match = entry.value;

        return ListTile(
          title: Text(match.matchNumber),
          subtitle: Text('ID: $id'),
        );
      },
    );
  }
}
