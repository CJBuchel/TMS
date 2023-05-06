import 'package:flutter/material.dart';

class ScreenCard extends StatelessWidget {
  const ScreenCard({
    super.key,
    required this.level,
    required this.title,
    required this.duration,
    required this.color,
    required this.image,
    required this.textColor,
  });

  final String level;
  final String title;
  final String duration;
  final Color color;
  final Image image;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Card(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    height: 115,
                    child: image,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 93, 0, 0),
                  child: Text(
                    level,
                    style: TextStyle(fontSize: 14, color: textColor, fontFamily: 'MontserratBold'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 110, 0, 0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 28, color: textColor, fontFamily: 'MontserratLight'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 210, 0, 0),
                  child: Text(
                    duration,
                    style: TextStyle(fontSize: 12, color: textColor, fontFamily: 'MontserratSemiBold'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(95, 195, 0, 0),
                  child: ElevatedButton(
                    onPressed: () => {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffEBEAEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    child: Text(
                      "Start",
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
