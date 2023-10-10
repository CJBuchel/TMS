import 'package:flutter/material.dart';
import 'package:tms/views/shared/parse_util.dart';

class EditTime extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? initialTime;
  final Function(String)? onChange;

  const EditTime({
    Key? key,
    this.label,
    this.initialTime,
    this.onChange,
    required this.controller,
  }) : super(key: key);

  @override
  State<EditTime> createState() => _EditStartTimeState();
}

class _EditStartTimeState extends State<EditTime> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.initialTime ?? "";
  }

  void setTime(TimeOfDay time) {
    if (mounted) {
      setState(() {
        widget.controller.text = parseTimeOfDayToString(time);
        widget.onChange?.call(widget.controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: 'Select time',
        prefixIcon: const Icon(Icons.calendar_today),
      ),

      // on tap select time (10:00 AM format)
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: parseStringTimeToTimeOfDay(widget.controller.text) ?? TimeOfDay.now(),
        );

        // if time is not null set time
        if (time != null) {
          setTime(time);
        }
      },
    );
  }
}
