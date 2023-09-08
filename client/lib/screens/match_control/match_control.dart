import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/screens/selector/screen_selector.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class MatchControl extends StatefulWidget {
  const MatchControl({Key? key}) : super(key: key);

  @override
  _MatchControlState createState() => _MatchControlState();
}

class _MatchControlState extends State<MatchControl> {
  List<Widget> _getControl() {
    return [
      const Text("Information 1"),
      const Text("Information 2"),
      ElevatedButton(onPressed: () {}, child: const Text("Button 1")),
      ElevatedButton(onPressed: () {}, child: const Text("Button 2")),
    ];
  }

  Widget _getTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text("Header A")),
        DataColumn(label: Text("Header B")),
      ],
      rows: List.generate(
        60,
        (index) => DataRow(
          cells: [
            DataCell(Text("Cell A$index")),
            DataCell(Text("Cell B$index")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (!Responsive.isMobile(context)) {
            return Row(
              children: [
                Container(
                  width: constraints.maxWidth / 3, // 1/3 dedicated to control
                  child: Column(
                    children: _getControl(),
                  ),
                ),
                Container(
                  width: (constraints.maxWidth / 3) * 2, // 2/3 dedicated to match table,
                  child: SingleChildScrollView(
                    child: _getTable(),
                  ),
                ),
              ],
            );
          } else {
            return SizedBox(
              width: constraints.maxWidth,
              child: const Text("Mobile View not available"),
            );
          }
        },
      ),
    );
  }
}
