import 'dart:math';

import 'package:flutter/material.dart';

class _BarberPolePainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double strokeWidth;
  final bool shiny;

  _BarberPolePainter({
    this.color = Colors.red,
    this.spacing = 40.0,
    this.strokeWidth = 20,
    this.shiny = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    ;
    final diagonalLength = sqrt(size.width * size.width + size.height * size.height);

    for (double x = -diagonalLength; x < diagonalLength; x += spacing) {
      canvas.drawLine(
        Offset(x, -spacing),
        Offset(x + diagonalLength, diagonalLength),
        paint,
      );
      if (shiny) {
        canvas.drawLine(
          Offset(x - spacing, -spacing),
          Offset(x + diagonalLength - spacing, diagonalLength),
          Paint()..color = Colors.white,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarberPoleContainer extends StatefulWidget {
  // barber pole
  final int duration; // directly effects speed (lower is faster)
  final Color stripeColor;
  final bool shiny;
  final bool active;

  // container
  final Widget? child;
  final Color? color;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;

  const BarberPoleContainer({
    Key? key,

    // barber pole
    this.duration = 2,
    this.stripeColor = Colors.red,
    this.shiny = false,
    this.active = true,

    // container
    this.child,
    this.color,
    this.width,
    this.height,
    this.border,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<BarberPoleContainer> createState() => _BarberPoleContainerState();
}

class _BarberPoleContainerState extends State<BarberPoleContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _barberPole(AnimationController controller) {
    final double spacing = 40.0;
    final double stokeWidth = 20;

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(controller.value * spacing, 0),
            child: child,
          );
        },
        child: CustomPaint(
          painter: _BarberPolePainter(
            color: widget.stripeColor,
            spacing: spacing,
            strokeWidth: stokeWidth,
            shiny: widget.shiny,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color,
        border: widget.border,
        borderRadius: widget.borderRadius,
      ),

      // child
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Stack(
          children: [
            if (widget.active) _barberPole(_controller),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}
