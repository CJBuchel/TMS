import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/utils/color_modifiers.dart';

class PrivateCommentWidget extends StatelessWidget {
  final String? comment;
  final Function(String) onCommentChanged;
  final bool isCommentNeeded;

  PrivateCommentWidget({
    Key? key,
    this.comment,
    required this.onCommentChanged,
    required this.isCommentNeeded,
  }) : super(key: key);

  final TextEditingController _commentController = TextEditingController();

  Color getMissionColor(BuildContext context) {
    Color darkColor = lighten(Theme.of(context).cardColor, 0.05);
    Color lightColor = Theme.of(context).cardColor;
    return Theme.of(context).brightness == Brightness.dark
        ? darkColor
        : lightColor;
  }

  Color? getDecorationColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.purple
        : Colors.purple[300];
  }

  @override
  Widget build(BuildContext context) {
    // TmsLogger().d("Comment required: $isCommentNeeded");
    if (comment != null) {
      _commentController.text = comment!;
    }
    double fontSize = 10;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      fontSize = 16;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      fontSize = 12;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(40, 10, 40, 100),
      decoration: BoxDecoration(
        color: getMissionColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        border: Border.all(
          width: 1,
          color: Colors.black,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            decoration: const BoxDecoration(
              // color: Color(0xFF4C779F),
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Text(
                "Private Comment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Add this: Red text when comment is required
          if (isCommentNeeded)
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                "* A comment is required for context on GP score",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextField(
            maxLines: 5,
            controller: _commentController,
            onChanged: onCommentChanged,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText:
                  "(${isCommentNeeded ? "REQUIRED" : "Optional"}) Enter your private comment here...",
            ),
          ),
          // colored bottom segment (just to make it look nice)
          Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            decoration: BoxDecoration(
              color: getDecorationColor(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
              ),
            ),
            height: 20,
          ),
        ],
      ),
    );
  }
}
