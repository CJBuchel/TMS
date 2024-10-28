import 'package:flutter/material.dart';

class ExpansionController extends ValueNotifier<bool> {
  ExpansionController({bool isExpanded = false}) : super(isExpanded);

  bool get isExpanded => value;

  void toggle() {
    value = !value;
  }

  void expand() {
    value = true;
  }

  void collapse() {
    value = false;
  }
}

class ExpandableTile extends StatefulWidget {
  final Widget header;
  final Widget body;
  final BorderRadius borderRadius;
  final Function(bool isExpanded)? onChange;
  final ExpansionController? controller;

  const ExpandableTile({
    Key? key,
    required this.header,
    required this.body,
    this.controller,
    this.onChange,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late ExpansionController _expansionController;

  @override
  void initState() {
    super.initState();

    _expansionController = widget.controller ?? ExpansionController(isExpanded: false);

    // animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    // add listener
    _expansionController.addListener(_handleExpandChange);

    // initial state
    _handleExpandChange();
  }

  @override
  void dispose() {
    super.dispose();
    _expansionController.removeListener(_handleExpandChange);
    _animationController.dispose();
    if (widget.controller == null) {
      _expansionController.dispose();
    }
  }

  void _handleExpandChange() {
    if (_expansionController.isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    widget.onChange?.call(_expansionController.isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: widget.borderRadius,
      onTap: _expansionController.toggle,
      child: Column(
        children: [
          widget.header,
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: 1.0,
            child: widget.body,
          ),
        ],
      ),
    );
  }
}
