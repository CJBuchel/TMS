import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';

class ScoringFooter extends StatefulWidget {
  final double height;
  final Team? nextTeam;
  final GameMatch? nextMatch;
  final List<ScoreError> errors;
  final Function() onClear;
  const ScoringFooter({
    Key? key,
    required this.height,
    required this.errors,
    required this.onClear,
    this.nextMatch,
    this.nextTeam,
  }) : super(key: key);

  @override
  State<ScoringFooter> createState() => _ScoringFooterState();
}

class _ScoringFooterState extends State<ScoringFooter> {
  @override
  Widget build(BuildContext context) {
    bool isValidSubmit = widget.errors.isEmpty && widget.nextMatch != null && widget.nextTeam != null;
    bool isValidNoShow = isValidSubmit;
    double? fontSize = Responsive.isDesktop(context)
        ? 25
        : Responsive.isTablet(context)
            ? 16
            : null;
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        // color: AppTheme.isDarkTheme ? Colors.blueGrey[800] : Colors.white,
        color: AppTheme.isDarkTheme ? Colors.transparent : Colors.white,

        border: Border(
          top: BorderSide(color: AppTheme.isDarkTheme ? Colors.white : Colors.black),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isValidNoShow) {}
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(isValidNoShow ? Colors.orange : Colors.grey),
                    ),
                    icon: Icon(Icons.no_accounts, size: fontSize),
                    label: Text("No Show", style: TextStyle(color: Colors.white, fontSize: fontSize)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onClear();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    icon: Icon(Icons.clear, size: fontSize),
                    label: Text("Clear", style: TextStyle(color: Colors.white, fontSize: fontSize)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isValidSubmit) {}
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(isValidSubmit ? Colors.green : Colors.grey),
                    ),
                    icon: Icon(Icons.send, size: fontSize),
                    label: Text("Submit", style: TextStyle(color: Colors.white, fontSize: fontSize)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
