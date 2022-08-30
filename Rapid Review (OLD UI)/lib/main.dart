import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rapid_review/data/_theme.dart';
import 'package:rapid_review/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  AppTheme.dark();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => GoogleAuthentication(),
      child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: () => GetMaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(),
                home: AuthPage(),
              )));
}
