import 'package:flutter/material.dart';
import 'package:test/widgets/bottom_nav_bar.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({Key? key}) : super(key: key);

  @override
  _FormsPageState createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
      bottomNavigationBar: BottomNavBar(), backgroundColor: Colors.black);
}
