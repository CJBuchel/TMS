import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tms/services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();
  FilePickerResult? result;

  Future<void> selectCSV() async {
    // file picker
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      notifyListeners();
    }
  }

  Future<void> uploadSchedule() async {
    if (result != null) {
      await _scheduleService.uploadSchedule(result!.files.first.bytes!);
    }
  }
}
