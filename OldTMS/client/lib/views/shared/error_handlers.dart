import 'package:flutter/material.dart';

class MobileNotImplemented extends StatelessWidget {
  const MobileNotImplemented({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This screen is not yet implemented for mobile devices.",
        style: TextStyle(
          fontSize: 15,
          color: Colors.blueGrey[800],
          fontFamily: "Montserrat",
        ),
      ),
    );
  }
}

class NotImplemented extends StatelessWidget {
  const NotImplemented({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This screen is not yet implemented.",
        style: TextStyle(
          fontSize: 28,
          color: Colors.blueGrey[800],
          fontFamily: "Montserrat",
        ),
      ),
    );
  }
}
