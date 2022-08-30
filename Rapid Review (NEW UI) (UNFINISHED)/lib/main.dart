import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/pages/home_page.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(const GetMaterialApp(home: HomePage())));
}
