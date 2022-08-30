import 'package:flutter/material.dart';

class AppTheme {
  static late Color textColor;
  static late Color backgroundColor;
  static late Color primaryColor;
  static late Color headerColor;

  // Dark theme
  static Future<void> dark() async {
    textColor = Color(0xFFFFFFFF);
    backgroundColor = Color.fromARGB(255, 0, 0, 0);
    headerColor = Color(0xff515979);
    primaryColor = Color(0xFF7D8CF4);
  }

  // Light theme
  static Future<void> light() async {
    textColor = Color(0xff121421);
    backgroundColor = Color(0xFFFFFFFF);
    headerColor = Color(0xff515979);
    primaryColor = Color(0xFF7D8CF4);
  }
}
