import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class EditOnTable extends StatefulWidget {
  final GameMatch match;
  final Function(List<OnTable>) onTableChanged;

  const EditOnTable({Key? key, required this.match, required this.onTableChanged}) : super(key: key);

  @override
  State<EditOnTable> createState() => _EditOnTableState();
}

class _EditOnTableState extends State<EditOnTable> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.green),
      onPressed: () {},
    );
  }
}
