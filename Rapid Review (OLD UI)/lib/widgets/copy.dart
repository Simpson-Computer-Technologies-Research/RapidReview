import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:rapid_review/data/_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyButton extends StatefulWidget {
  const CopyButton({Key? key, required this.size, required this.to_copy})
      : super(key: key);
  final String to_copy;
  final double size;

  @override
  _CopyButtonState createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 200),
    );
  }

  Future<void> reverseIcon() async {
    await Future.delayed(Duration(milliseconds: 1500));
    animationController.reverse();
  }

  @override
  Widget build(BuildContext context) => AnimatedIconButton(
          animationController: animationController,
          splashRadius: 0.01,
          icons: <AnimatedIconItem>[
            AnimatedIconItem(
                icon: Icon(Icons.copy,
                    color: AppTheme.textColor, size: widget.size),
                onPressed: () async {
                  Clipboard.setData(ClipboardData(text: widget.to_copy));
                  await reverseIcon();
                }),
            AnimatedIconItem(
                onPressed: () async => animationController.reset(),
                icon: Icon(Icons.check,
                    color: AppTheme.textColor, size: widget.size))
          ]);
}
