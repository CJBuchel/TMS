import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tms_client/views/match_controller/match_selector/match_selector.dart';

class MatchControllerView extends HookWidget {
  const MatchControllerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isPanelOpen = useState(false);
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 900;

    return Stack(
      children: [
        // Main content
        Row(
          children: [
            // Left side - always visible
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Stage
                  Expanded(flex: 1, child: Center(child: Text('Match Stage'))),
                  // Match Control
                  Expanded(
                    flex: 1,
                    child: Center(child: Text('Match Control')),
                  ),
                  // Timer Control
                  Expanded(
                    flex: 1,
                    child: Center(child: Text('Timer Control')),
                  ),
                ],
              ),
            ),
            // Right side - always visible on large screens
            if (!isSmallScreen) Expanded(flex: 1, child: MatchSelector()),
          ],
        ),

        // Backdrop for small screens when panel is open
        if (isSmallScreen && isPanelOpen.value)
          GestureDetector(
            onTap: () => isPanelOpen.value = false,
            child: Container(color: Colors.black54),
          ),

        // Sliding panel for small screens
        if (isSmallScreen)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: isPanelOpen.value ? 0 : -mediaQuery.size.width * 0.8,
            top: 0,
            bottom: 0,
            width: mediaQuery.size.width * 0.8,
            child: Material(elevation: 8, child: MatchSelector()),
          ),

        // Toggle button for small screens
        if (isSmallScreen)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => isPanelOpen.value = !isPanelOpen.value,
              child: Icon(isPanelOpen.value ? Icons.close : Icons.table_chart),
            ),
          ),
      ],
    );
  }
}
