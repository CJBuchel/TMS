import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class Setup extends StatelessWidget {
  const Setup({Key? key}) : super(key: key);

  Widget mainSetup() {
    return Expanded(
      child: Container(
        // color: Colors.,
        child: const Center(
          child: Text("Normal Setup"),
        ),
      ),
    );
  }

  Widget apiSetup() {
    return Expanded(
      child: Container(
        color: bgSecondaryColor,
        child: const Center(
          child: Text("API Setup (Optional)"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var imageSize = <double>[200, 500];
    double buttonWidth = 250;
    double buttonHeight = 50;
    if (Responsive.isTablet(context)) {
      imageSize = [150, 300];
      buttonWidth = 200;
    } else if (Responsive.isMobile(context)) {
      imageSize = [100, 250];
      buttonWidth = 150;
      buttonHeight = 40;
    }

    return Scaffold(
      appBar: TmsToolBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (Responsive.isMobile(context)) {
            return Column(
              children: [
                mainSetup(),
                apiSetup(),
              ],
            );
          } else {
            return Row(
              children: [
                mainSetup(),
                apiSetup(),
              ],
            );
          }
        },
      ),
    );
  }
}
