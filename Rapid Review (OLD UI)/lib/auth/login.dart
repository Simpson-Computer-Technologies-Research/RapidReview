import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rapid_review/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Google authentication
class GoogleAuthentication extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  // Login to google account
  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  // Logout of google account
  Future googleLogout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
  notifyListeners();
}

// Login page
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xff121421),
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 0),
              child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Image.asset("assets/images/wave_logo.png", width: 300.w, height: 300.h),
                    Center(
                        child: Text("Rapid Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold))),
                    SizedBox(height: 15.h),
                    Center(
                        child: Text("Welcome Back!",
                            style: TextStyle(
                                color: Color(0xFFDEDEDE), fontSize: 16))),
                    GestureDetector(
                        child: Container(
                            padding: EdgeInsets.all(10.h * 10.w / 10),
                            margin: EdgeInsets.only(
                                left: 40.w, right: 40.w, top: 25.h),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFF171A2C)),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset("assets/images/google_logo.png",
                                      width: 40.w, height: 40.h),
                                  SizedBox(width: 10.w),
                                  Text("Sign in with Google",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400))
                                ])),
                        onTap: () {
                          final provider = Provider.of<GoogleAuthentication>(context, listen: false);
                          provider.googleLogin();
                        })
                  ]))));
}

// Auth status page
class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Connecting to snapshot
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SpinKitRing(color: Color(0xFF6764FF), size: 80),
            Text("Loading",
                style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 16))
          ]);
        }
        // User is logged in
        else if (snapshot.hasData) {
          return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: HomePage(firstLaunch: true));
        } else {
          return AnimatedSwitcher(
              duration: Duration(milliseconds: 300), child: LoginPage());
        }
      });
}
