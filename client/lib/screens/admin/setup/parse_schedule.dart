import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

String _detectEol(String input) {
  if (input.contains('\r\n')) {
    return '\r\n';
  } else if (input.contains('\n')) {
    return '\n';
  } else {
    return '\n';
  }
}

// CSV Parser
void parseSchedule(FilePickerResult result) {
  final input = result.files.single.bytes!;
  // convert bytes to string
  final csvString = String.fromCharCodes(input);

  // parse the csv string
  final eol = _detectEol(csvString);
  final rows = CsvToListConverter(eol: eol).convert(csvString);

  if (rows[0][1] != 1) {
    // check version is 1
    return; // @TODO, return with bad flag
  }

  // blocks (teams = 1, matches = 2, judging = 3)
  final teamBlock = <List<dynamic>>[];
  final matchBlock = <List<dynamic>>[];
  final judgingBlock = <List<dynamic>>[];

  const blockFormat = "Block Format";
  int currentBlock = 0;

  // separate into blocks
  for (var line in rows) {
    if (line[0] == blockFormat) {
      currentBlock = line[1];
    }

    // add to respective block
    switch (currentBlock) {
      case 1:
        teamBlock.add(line);
        break;
      case 2:
        matchBlock.add(line);
        break;
      case 3:
        judgingBlock.add(line);
        break;
      default:
        break;
    }
  }
}
