import 'package:rapid_review/pages/home_page.dart';
import 'package:flutter/material.dart';

class CircleTimer extends StatefulWidget {
  const CircleTimer({Key? key}) : super(key: key);

  @override
  State<CircleTimer> createState() => _CircleTimerState();
}

class _CircleTimerState extends State<CircleTimer>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void createController() {
    // Get starting point
    String date = DateTime.now().toString();
    String seconds = date.split(":")[2].split(".")[0];
    if (seconds[0] == "0") {
      seconds = seconds[1];
    }

    // Create controller
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 60))
          ..addListener(() {
            if (controller.status == AnimationStatus.completed) {
              HomePage.setState(() {
                controller.dispose();
                createController();
              });
            }
            setState(() {});
          });
    controller.forward(from: (int.parse(seconds) * (100 / 60)) / 100);
  }

  @override
  void initState() {
    createController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        color: Color(0xFFFFFFFF),
        value: controller.value,
        semanticsLabel: 'Timer',
      );
}
