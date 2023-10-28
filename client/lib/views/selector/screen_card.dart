import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/views/shared/color_utils.dart';

class ScreenCard extends StatelessWidget {
  const ScreenCard({
    super.key,
    required this.type,
    required this.title,
    required this.color,
    required this.image,
    required this.textColor,
    required this.onPress,
  });
  final String type;
  final String title;
  final Color color;
  final Image image;
  final Color textColor;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 280,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Card(
              color: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                splashColor: darken(color),
                hoverColor: lighten(color),
                borderRadius: BorderRadius.circular(10),
                onTap: onPress,
                onHover: (value) {},
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
                      padding: const EdgeInsets.fromLTRB(18, 110, 0, 0),
                      child: Text(
                        type,
                        style: TextStyle(fontSize: 14, color: textColor, fontFamily: defaultFontFamilyBold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 130, 0, 0),
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 28, color: textColor, fontFamily: defaultFontFamily),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
