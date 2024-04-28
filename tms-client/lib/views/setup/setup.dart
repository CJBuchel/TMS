import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tms/views/setup/event_name_setup.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/views/setup/schedule_setup.dart';

class Setup extends StatelessWidget {
  final FilePickerResult? result = null;
  final TextEditingController _eventNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: 800,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "Schedule Setup",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ScheduleSetup(),
              EventNameSetup(),
            ],
          ),
        ),
      ),
    );
  }
}
