import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AccordionItem {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget child;
  final bool initiallyExpanded;

  const AccordionItem({
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.initiallyExpanded = false,
  });
}

class Accordion extends StatelessWidget {
  final List<AccordionItem> items;

  const Accordion({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return _AccordionState(items: items);
  }
}

class _AccordionState extends HookWidget {
  final List<AccordionItem> items;

  const _AccordionState({required this.items});

  @override
  Widget build(BuildContext context) {
    final expandedIndex = useState<int?>(() {
      for (int i = 0; i < items.length; i++) {
        if (items[i].initiallyExpanded) {
          return i;
        }
      }
      return null;
    }());

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isExpanded = expandedIndex.value == index;

            // Calculate available height for expanded content
            // Total height minus height of all collapsed tiles
            final tileHeight = 72.0; // Approximate ListTile height
            final availableHeight =
                constraints.maxHeight - (items.length * tileHeight);

            return _AccordionTile(
              item: item,
              isExpanded: isExpanded,
              availableHeight: availableHeight,
              onToggle: () {
                if (isExpanded) {
                  expandedIndex.value = null;
                } else {
                  expandedIndex.value = index;
                }
              },
            );
          }),
        );
      },
    );
  }
}

class _AccordionTile extends HookWidget {
  final AccordionItem item;
  final bool isExpanded;
  final double availableHeight;
  final VoidCallback onToggle;

  const _AccordionTile({
    required this.item,
    required this.isExpanded,
    required this.availableHeight,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final heightAnimation = useMemoized(
      () => CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn,
      ),
      [animationController],
    );

    useEffect(() {
      if (isExpanded) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [isExpanded]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: isExpanded ? theme.colorScheme.surfaceContainerHighest : null,
          child: InkWell(
            onTap: onToggle,
            child: ListTile(
              leading: item.leading,
              title: DefaultTextStyle(
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: isExpanded ? theme.colorScheme.primary : null,
                ),
                child: item.title,
              ),
              subtitle: item.subtitle != null
                  ? DefaultTextStyle(
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      child: item.subtitle!,
                    )
                  : null,
              trailing: RotationTransition(
                turns: Tween<double>(
                  begin: 0.0,
                  end: 0.5,
                ).animate(heightAnimation),
                child:
                    item.trailing ??
                    Icon(
                      Icons.expand_more,
                      color: isExpanded ? theme.colorScheme.primary : null,
                    ),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: heightAnimation,
          builder: (context, child) {
            return SizedBox(
              height: availableHeight * heightAnimation.value,
              child: heightAnimation.value > 0 ? ClipRect(child: child) : null,
            );
          },
          child: item.child,
        ),
      ],
    );
  }
}
