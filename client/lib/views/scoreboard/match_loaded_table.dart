import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchLoadedTable extends StatefulWidget {
  final List<Team> teams;
  const MatchLoadedTable({
    Key? key,
    required this.teams,
  }) : super(key: key);

  @override
  State<MatchLoadedTable> createState() => _MatchLoadedTableState();
}

class _MatchLoadedTableState extends State<MatchLoadedTable> {
  double headerHeight = 20;

  Widget _buildCell(String text, {Color? backgroundColor, Color? textColor, double? width}) {
    return Container(
      width: width,
      color: backgroundColor,
      child: Center(child: Text(text, style: TextStyle(color: textColor, overflow: TextOverflow.ellipsis))),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      height: headerHeight,
      child: Row(
        children: [
          _buildCell("Table", width: 100, textColor: Colors.black, backgroundColor: Colors.blue),
          Expanded(child: _buildCell("Team", textColor: Colors.black, backgroundColor: Colors.green)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),

        // main team rows
        Expanded(child: LayoutBuilder(
          builder: (context, constraints) {
            return Text("Teams");
          },
        )),
      ],
    );
  }
}
