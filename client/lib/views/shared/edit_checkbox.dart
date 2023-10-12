import 'package:flutter/material.dart';

class EditCheckbox extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;

  const EditCheckbox({Key? key, required this.value, required this.onChanged}) : super(key: key);

  @override
  State<EditCheckbox> createState() => _MatchCheckboxState();
}

class _MatchCheckboxState extends State<EditCheckbox> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  void _toggleState(bool? value) {
    if (mounted && value != null) {
      setState(() {
        _value = value;
        widget.onChanged(_value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _value,
      onChanged: (value) {
        _toggleState(value);
      },
    );
  }
}
