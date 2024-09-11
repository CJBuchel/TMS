import 'package:flutter/material.dart';

class NumberedList extends StatelessWidget {
  const NumberedList({
    Key? key,
    required this.title,
    required this.list,
  }) : super(key: key);

  final String title;
  final List<String> list;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < list.length; i++)
          Text(
            '${i + 1}. ${list[i]}',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
      ],
    );
  }
}
