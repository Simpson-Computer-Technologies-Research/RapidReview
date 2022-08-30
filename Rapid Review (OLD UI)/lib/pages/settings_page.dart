import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_review/data/_cache.dart';
import 'package:rapid_review/pages/home_page.dart';
import 'package:rapid_review/widgets/refresh.dart';
import 'package:rapid_review/widgets/popups.dart';
import 'package:rapid_review/widgets/copy.dart';
import 'package:rapid_review/data/_theme.dart';
import 'package:rapid_review/data/_http.dart';
import 'package:rapid_review/data/_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List linkedAccounts = Settings.fetch("linked");
  List blockedAccounts = Settings.fetch("blocked");

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    asyncHandler() async => {await refreshAccounts(), await refreshBlocked()};
    WidgetsBinding.instance?.addPostFrameCallback((_) => asyncHandler());
  }

  Future<void> refreshAccounts() async {
    List _linkedAccounts = await Settings.loadLinkedAccounts();
    setState(() {
      linkedAccounts = _linkedAccounts;
    });
  }

  Future<void> refreshBlocked() async {
    List _blockedAccounts = await Settings.loadBlockedAccounts();
    setState(() {
      blockedAccounts = _blockedAccounts;
    });
  }

  Future<void> deleteLinkedAccount(int index) async {
    await Accounts.deleteLinkedAccount(linkedAccounts[index]);
    setState(() {
      linkedAccounts.removeAt(index);
    });
  }

  Future<void> unblockUser(int index) async {
    Recents.addAction("Unblocked ${blockedAccounts[index]}'s request's");
    await Blocked.unblockUser(blockedAccounts[index]);
    setState(() {
      blockedAccounts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onPanUpdate: (details) async {
        if (details.delta.dx > 10) {
          Get.to(() => HomePage(firstLaunch: false),
              transition: Transition.leftToRightWithFade);
        }
      },
      child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          floatingActionButton: FloatingActionButton(
              foregroundColor: AppTheme.backgroundColor,
              backgroundColor: AppTheme.textColor,
              onPressed: () async {
                Get.to(() => HomePage(firstLaunch: false),
                    transition: Transition.rightToLeftWithFade);
              },
              tooltip: "Home",
              child: Icon(Icons.home)),
          body: ListView(physics: BouncingScrollPhysics(), children: <Widget>[
            Padding(
                padding: EdgeInsets.only(
                    left: 28.w, right: 18.w, top: 36.h, bottom: 36.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Settings",
                          style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 34.w,
                              fontWeight: FontWeight.bold)),
                      Padding(
                          padding: EdgeInsets.only(top: 5.h, right: 20.w),
                          child: Icon(Icons.settings,
                              size: 30.w, color: AppTheme.textColor))
                    ])),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text("User ID",
                  style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 24.w,
                      fontWeight: FontWeight.bold)),
              CopyButton(size: 28.h, to_copy: CurrentUser.get()!)
            ]),
            Container(
                padding: EdgeInsets.only(bottom: 20.h),
                alignment: Alignment.center,
                child: SelectableText(CurrentUser.get()!,
                    style: TextStyle(
                        color: AppTheme.textColor,
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        fontFamily: 'Poppins'))),
            blockedAccounts.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: 30.h),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("   Blocked",
                              style: TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 24.w,
                                  fontWeight: FontWeight.bold)),
                          RefreshButton(size: 33.h, function: refreshBlocked)
                        ]))
                : Container(),
            blockedAccounts.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: blockedAccounts.length,
                    itemBuilder: (context, index) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ClipRRect(
                                  child: Image.asset(
                                      "assets/images/discord_logo.png",
                                      width: 30.w,
                                      height: 30.w),
                                  borderRadius: BorderRadius.circular(50)),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: Text(blockedAccounts[index],
                                      style: TextStyle(
                                          color: AppTheme.textColor,
                                          decoration: TextDecoration.none,
                                          fontSize: 18,
                                          fontFamily: 'Poppins'))),
                              GestureDetector(
                                  onTap: () async {
                                    Popup(unblockUser, context).show(
                                        'Unblock ' + blockedAccounts[index],
                                        index);
                                  },
                                  child: Icon(Icons.delete,
                                      color: Colors.redAccent))
                            ]))
                : Container(),
            Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("   Connections",
                          style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 24.w,
                              fontWeight: FontWeight.bold)),
                      RefreshButton(size: 33.h, function: refreshAccounts)
                    ])),
            linkedAccounts.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: linkedAccounts.length,
                    itemBuilder: (context, index) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ClipRRect(
                                  child: Image.asset(
                                      "assets/images/discord_logo.png",
                                      width: 30.w,
                                      height: 30.w),
                                  borderRadius: BorderRadius.circular(50)),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: Text(linkedAccounts[index],
                                      style: TextStyle(
                                          color: AppTheme.textColor,
                                          decoration: TextDecoration.none,
                                          fontSize: 18,
                                          fontFamily: 'Poppins'))),
                              GestureDetector(
                                  onTap: () async {
                                    Popup(deleteLinkedAccount, context).show(
                                        'Remove ' + linkedAccounts[index],
                                        index);
                                  },
                                  child: Icon(Icons.delete,
                                      color: Colors.redAccent))
                            ]))
                : Container(),
            GestureDetector(
                child: Container(
                  height: 50.h,
                  alignment: Alignment.center,
                  child: Text("Link Account",
                      style: TextStyle(
                          color: AppTheme.backgroundColor,
                          fontWeight: FontWeight.w400)),
                  margin: EdgeInsets.only(top: 20.h, left: 100.w, right: 100.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                      color: AppTheme.textColor),
                ),
                onTap: () async {
                  if (linkedAccounts.length < 10) {
                    await Accounts.linkAccount();
                  }
                })
          ])));
}
