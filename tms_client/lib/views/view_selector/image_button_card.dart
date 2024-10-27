import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/utils/color_modifiers.dart';

class ImageButtonCard extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final Color? color;
  final Color? textColor;
  final Image? image;
  final VoidCallback? onPressed;

  const ImageButtonCard({
    Key? key,
    this.title,
    this.subTitle,
    this.color,
    this.textColor,
    this.image,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double titleSize;
    double cardHeight;
    double imageHeight;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      titleSize = 28;
      cardHeight = 220;
      imageHeight = 115;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      titleSize = 24;
      cardHeight = 200;
      imageHeight = 100;
    } else {
      titleSize = 20; // mobile
      cardHeight = 150;
      imageHeight = 80;
    }

    return SizedBox(
      height: cardHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),

          // ink splash card
          child: InkWell(
            splashColor: darken(color ?? Theme.of(context).cardColor),
            hoverColor: lighten(color ?? Theme.of(context).cardColor),
            borderRadius: BorderRadius.circular(10.0),
            onTap: onPressed,
            child: Stack(
              children: [
                // image
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    height: imageHeight,
                    child: image,
                  ),
                ),

                // title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subTitle ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        Text(
                          title ?? '',
                          style: TextStyle(
                            fontSize: titleSize,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
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
