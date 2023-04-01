// import 'package:tms_bindings/tms_bindings.dart' as tms_bindings;

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:json_to_dart/json_to_dart.dart';

String _getSchemaPath() {
  return path.normalize(path.join(path.current, "..${path.separator}schemas"));
}

String _getBindingsPath() {
  return path.normalize(path.join(path.current, "${path.separator}lib"));
}

void main(List<String> arguments) {
  final classGenerator = new ModelGenerator('Sample');
  final schemaFilePath = path.normalize(path.join(_getSchemaPath(), 'sample.json'));

  final jsonRawData = new File(schemaFilePath).readAsStringSync();
  DartCode dartCode = classGenerator.generateDartClasses(jsonRawData);

  final bindingsFilePath = path.normalize(path.join(_getBindingsPath(), 'tms_bindings.dart'));
  // var bindings_file = File(bindingsFilePath).create(recursive: true, exclusive: true);
  // var bindings_file = File(bindingsFilePath).writeAsString(dartCode.code);
  print(dartCode.code);
}
