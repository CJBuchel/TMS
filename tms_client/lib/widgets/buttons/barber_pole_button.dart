import 'package:flutter/material.dart';
import 'package:tms/widgets/animated/barber_pole_container.dart';

class BarberPoleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? elevation;
  final Color? backgroundColor;
  final Color? overlayColor;
  final Color? stripeColor;
  final BorderRadius? borderRadius;

  const BarberPoleButton({
    required this.child,
    this.onPressed,
    this.elevation,
    this.backgroundColor,
    this.overlayColor,
    this.stripeColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: BarberPoleContainer(
        hoverColor: overlayColor,
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        stripeColor: stripeColor ?? Colors.red,
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
