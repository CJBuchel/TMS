import 'package:flutter/material.dart';

class LiveCheckbox extends StatefulWidget {
  final bool? defaultValue;
  final Color? color;
  final Function(bool)? onChanged;

  LiveCheckbox({
    this.defaultValue,
    this.color = Colors.orange,
    this.onChanged,
  });

  @override
  _LiveCheckboxState createState() => _LiveCheckboxState();
}

class _LiveCheckboxState extends State<LiveCheckbox> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.defaultValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      activeColor: widget.color,
      value: _value,
      onChanged: (bool? newValue) {
        if (newValue != null) {
          // Update the local state and rebuild the widget with the new value.
          setState(() {
            _value = newValue;
          });
          // Call the onChanged callback if it's provided.
          widget.onChanged?.call(newValue);
        }
      },
    );
  }
}
