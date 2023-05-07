import 'package:flutter/material.dart';
import 'package:tms/constants.dart';

class ScreenCard extends StatefulWidget {
  ScreenCard({
    super.key,
    required this.type,
    required this.title,
    required this.duration,
    required this.color,
    required this.image,
    required this.textColor,
    required this.onPress,
  });
  final String type;
  final String title;
  final String duration;
  final Color color;
  final Image image;
  final Color textColor;
  void Function() onPress;

  @override
  _ScreenCardState createState() => _ScreenCardState();
}

class _ScreenCardState extends State<ScreenCard> {
  Color _color = Colors.black;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Card(
          color: _color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: widget.onPress,
            onHover: (value) {
              if (value) {
                setState(() {
                  _color = widget.color.withOpacity(0.8);
                });
              } else {
                setState(() {
                  _color = widget.color;
                });
              }
            },
            splashColor: widget.color.withOpacity(0.8),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    height: 115,
                    child: widget.image,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 110, 0, 0),
                  child: Text(
                    widget.type,
                    style: TextStyle(fontSize: 14, color: widget.textColor, fontFamily: defaultFontFamilyBold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 130, 0, 0),
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 28, color: widget.textColor, fontFamily: defaultFontFamily),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
