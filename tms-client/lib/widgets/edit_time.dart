import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_time.dart';
import 'package:tms/utils/tms_time_utils.dart';

class EditTimeWidget extends StatefulWidget {
  final String? label;
  final TmsDateTime? initialTime;
  final Function(TmsDateTime)? onChanged;

  EditTimeWidget({
    Key? key,
    this.label,
    this.initialTime,
    this.onChanged,
  }) : super(key: key);

  @override
  _EditTimeWidgetState createState() => _EditTimeWidgetState();
}

class _EditTimeWidgetState extends State<EditTimeWidget> {
  late ValueNotifier<TmsDateTime> _time = ValueNotifier(widget.initialTime ?? dateTimeToTmsDateTime(DateTime.now()));

  void _setTime(TimeOfDay time) {
    _time.value = TmsDateTime(time: TmsTime(hour: time.hour, minute: time.minute, second: 0));
    widget.onChanged?.call(_time.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _time,
      builder: (context, time, _) {
        return TextFormField(
          controller: TextEditingController(text: time.toString()),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'Select time',
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(tmsDateTimeToDateTime(time)),
            );

            if (t != null) _setTime(t);
          },
        );
      },
    );
  }
}
