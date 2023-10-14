import 'package:flutter/material.dart';
import 'package:tms/views/shared/edit_checkbox.dart';

class RoundNumber extends StatefulWidget {
  final TextEditingController controller;
  final ValueNotifier<bool> isExhibition;

  const RoundNumber({
    Key? key,
    required this.isExhibition,
    required this.controller,
  }) : super(key: key);

  @override
  State<RoundNumber> createState() => _RoundNumberState();
}

class _RoundNumberState extends State<RoundNumber> {
  Widget _rowPadding(Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: widget,
    );
  }

  Widget _roundNumberInput() {
    return TextFormField(
      enabled: !widget.isExhibition.value,
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: "RoundNumber",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _isExhibitionInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Exhibition Match"),
        EditCheckbox(
          value: widget.isExhibition.value,
          onChanged: (value) {
            if (mounted) {
              if (value) {
                widget.controller.text = "0";
              }
              setState(() {
                widget.isExhibition.value = value;
              });
            }
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // is exhibition
        _rowPadding(_isExhibitionInput()),

        // round number (if not exhibition)
        _rowPadding(_roundNumberInput()),
      ],
    );
  }
}
