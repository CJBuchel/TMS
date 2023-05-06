import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/screens/selector/screen_card.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class ScreenSelector extends StatefulWidget {
  ScreenSelector({super.key});

  @override
  _ScreenSelectorState createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: TmsToolBar(),
      body: ListView(
        children: <Widget>[
          IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
                  child: Text(
                    "Public Screens",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blueGrey[800],
                      fontFamily: defaultFontFamilyBold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // First Card
          IntrinsicHeight(
            child: Row(children: [
              Flexible(
                flex: 1,
                child: ScreenCard(
                  type: "BASIC",
                  title: "Scoreboard",
                  duration: "7-30 Days",
                  color: Color(0xff8E97FD),
                  textColor: Color(0xff3F414E),
                  image: const Image(
                    image: AssetImage('assets/images/FIRST_LOGO.png'),
                  ),
                  onPress: () {
                    print("Scoreboard pressed");
                  },
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: ScreenCard(
                  type: "BASIC",
                  title: "Timer",
                  duration: "12-35 Days",
                  color: Color(0xffFFC97E),
                  textColor: Color(0xff3F414E),
                  image: const Image(
                    image: AssetImage('assets/images/FIRST_LOGO.png'),
                  ),
                  onPress: () {
                    print("Timer Pressed");
                  },
                ),
              ),
            ]),
          )
        ],
      ),
    ));
  }
}
