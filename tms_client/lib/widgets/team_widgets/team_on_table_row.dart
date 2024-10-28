import 'package:flutter/material.dart';
import 'package:tms/models/team_on_table_info.dart';

class TeamOnTableRow extends StatelessWidget {
  final TeamOnTableInfo info;
  final bool isLeft;
  final TextStyle? textStyle;

  const TeamOnTableRow({
    Key? key,
    required this.info,
    required this.isLeft,
    this.textStyle,
  }) : super(key: key);

  BorderSide _getBorderSide(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return const BorderSide(
        color: Colors.black,
        width: 1,
      );
    } else {
      return BorderSide.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    MainAxisAlignment mainAxisAlignment = isLeft ? MainAxisAlignment.end : MainAxisAlignment.start;

    Widget tNumWidget = Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: ShapeDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(10),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 10 : 0),
            bottomLeft: Radius.circular(isLeft ? 10 : 0),
            topRight: Radius.circular(isLeft ? 0 : 10),
            bottomRight: Radius.circular(isLeft ? 0 : 10),
          ),
          side: _getBorderSide(context),
        ),
      ),
      child: Text(
        textAlign: TextAlign.center,
        info.teamNumber,
        style: const TextStyle(color: Colors.black),
      ),
    );

    Widget tNaWidget = Text(
      textAlign: TextAlign.center,
      info.teamName,
      style: textStyle ?? const TextStyle(color: Colors.white),
    );

    Widget tOnWidget = Text(
      textAlign: TextAlign.center,
      info.onTable,
      style: textStyle ?? const TextStyle(color: Colors.white),
    );

    Widget a = isLeft ? tOnWidget : tNumWidget;
    Widget b = tNaWidget;
    Widget c = isLeft ? tNumWidget : tOnWidget;

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Expanded(
          flex: 1,
          child: a,
        ),
        Expanded(
          flex: 3,
          child: b,
        ),
        Expanded(
          flex: 1,
          child: c,
        ),
      ],
    );
  }
}
