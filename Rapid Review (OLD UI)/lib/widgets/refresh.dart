import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:rapid_review/pages/home_page.dart';
import 'package:rapid_review/data/_theme.dart';
import 'package:flutter/material.dart';

class RefreshButton extends StatefulWidget {
  const RefreshButton({Key? key, required this.size, required this.function})
      : super(key: key);
  final double size;
  final Function function;

  @override
  _RefreshButtonState createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) => AnimatedIconButton(
          animationController: animationController,
          splashRadius: 0.01,
          icons: <AnimatedIconItem>[
            AnimatedIconItem(
                icon: Icon(Icons.refresh,
                    color: AppTheme.textColor, size: widget.size),
                onPressed: () async => HomePage.setState(() {
                      widget.function();
                    }))
          ]);
}
