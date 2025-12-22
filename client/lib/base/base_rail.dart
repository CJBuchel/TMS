import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/router/app_routes.dart';

class BaseRail extends HookConsumerWidget {
  const BaseRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Derive selected index from current route instead of local state
    final selectedIndex = AppRoute.currentRailIndex(context) ?? 0;
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
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              // Type-safe navigation using the enum
              final route = AppRoute.fromRailIndex(index);
              route?.go(context);
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
                ),
                icon: Icon(isExtended.value ? Icons.chevron_left : Icons.menu),
                onPressed: () => isExtended.value = !isExtended.value,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.handyman),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shuffle),
                label: Text('Match Controller'),
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
