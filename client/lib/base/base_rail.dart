import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BaseRail extends HookConsumerWidget {
  const BaseRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);
    final isExtended = useState(false);
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Row(
        children: [
          NavigationRail(
            extended: isExtended.value,
            minWidth: 48,
            minExtendedWidth: 200,
            selectedIndex: selectedIndex.value,
            onDestinationSelected: (index) {
              selectedIndex.value = index;
              // Handle navigation here
            },
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                icon: Icon(isExtended.value ? Icons.chevron_left : Icons.menu),
                onPressed: () => isExtended.value = !isExtended.value,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info),
                label: Text('Information'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.help),
                label: Text('Help'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
        ],
      ),
    );
  }
}
