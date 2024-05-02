import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/schedule_provider.dart';
import 'package:tms/views/setup/input_setter.dart';

class ScheduleSetup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<ScheduleProvider>(
          builder: (context, provider, child) {
            return InputSetter(
              label: "Upload Schedule:",
              onSet: () async {
                await provider.uploadSchedule();
              },
              input: ElevatedButton(
                onPressed: () async {
                  await provider.selectCSV();
                },
                child: Text(provider.result == null ? "Select CSV" : provider.result?.files.first.name ?? ""),
              ),
            );
          },
        ),
      ],
    );
  }
}
