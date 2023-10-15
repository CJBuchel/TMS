import 'package:flutter/material.dart';
import 'package:tms/constants.dart';

class ScoringComments extends StatelessWidget {
  final Color? color;
  final TextEditingController? publicCommentController;
  final TextEditingController? privateCommentController;
  final Function(String)? onPublicCommentChange;
  final Function(String)? onPrivateCommentChange;
  const ScoringComments({
    Key? key,
    this.publicCommentController,
    this.privateCommentController,
    this.onPublicCommentChange,
    this.onPrivateCommentChange,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        border: Border.all(
          color: AppTheme.isDarkTheme ? Colors.black : Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: Text("Comments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: TextField(
              controller: publicCommentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Public Comment (optional)',
                hintText: "Enter public comment (teams may see this)",
              ),
              onChanged: onPublicCommentChange,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: TextField(
              controller: privateCommentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Private Comment (optional)',
                hintText: "Enter private comment (only judges will see this)",
              ),
              onChanged: onPublicCommentChange,
            ),
          )
        ],
      ),
    );
  }
}
