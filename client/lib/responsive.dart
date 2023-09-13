import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  static const double _mobileWidthThreshold = 810; // ipad air is 820 in portrait mode
  static const double _tabletWidthThreshold = 1100;

  static const double _mobileHeightThreshold = 600;
  static const double _tabletHeightThreshold = 800;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  // This isMobile, isTablet, isDesktop helps us later
  static bool isMobile(BuildContext context) {
    if (MediaQuery.of(context).size.width < _mobileWidthThreshold || MediaQuery.of(context).size.height < _mobileHeightThreshold) {
      return true;
    }

    return false;
  }

  static bool isTablet(BuildContext context) {
    if (MediaQuery.of(context).size.width < _tabletWidthThreshold && MediaQuery.of(context).size.width >= _mobileWidthThreshold) {
      return true;
    }

    if (MediaQuery.of(context).size.height < _tabletHeightThreshold && MediaQuery.of(context).size.height >= _mobileHeightThreshold) {
      return true;
    }

    return false;
  }

  static bool isDesktop(BuildContext context) {
    if (MediaQuery.of(context).size.width >= _tabletWidthThreshold && MediaQuery.of(context).size.height >= _tabletHeightThreshold) {
      return true;
    }

    return false;
  }

  static double fontSize(BuildContext context, double scale) {
    double fontSize = 25;
    if (isTablet(context)) {
      fontSize = 24;
    } else if (isMobile(context)) {
      fontSize = 18;
    }

    return fontSize * (scale <= 0 ? 1 : scale);
  }

  static double buttonWidth(BuildContext context, double scale) {
    double buttonWidth = 250;
    if (isTablet(context)) {
      buttonWidth = 200;
    } else if (isMobile(context)) {
      buttonWidth = 150;
    }

    return buttonWidth * (scale <= 0 ? 1 : scale);
  }

  static double buttonHeight(BuildContext context, double scale) {
    double buttonHeight = 50;
    if (isMobile(context)) {
      buttonHeight = 40;
    }

    return buttonHeight * (scale <= 0 ? 1 : scale);
  }

  // image size Tuple2(hight,width)
  static Tuple2<double, double> imageSize(BuildContext context, double scale) {
    double height = 300;
    double width = 500;
    if (isTablet(context)) {
      height = 150;
      width = 300;
    } else if (isMobile(context)) {
      height = 100;
      width = 250;
    }

    return Tuple2<double, double>(height * (scale <= 0 ? 1 : scale), width * (scale <= 0 ? 1 : scale));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // If our width is more than 1100 then we consider it a desktop
    if (size.width >= 1100) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (size.width >= 850 && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}
