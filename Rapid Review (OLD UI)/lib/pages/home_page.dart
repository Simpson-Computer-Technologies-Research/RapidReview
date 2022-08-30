import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rapid_review/widgets/requestsStream.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rapid_review/pages/settings_page.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:rapid_review/widgets/refresh.dart';
import 'package:rapid_review/pages/form_page.dart';
import 'package:rapid_review/widgets/popups.dart';
import 'package:rapid_review/widgets/timer.dart';
import 'package:rapid_review/widgets/cards.dart';
import 'package:rapid_review/widgets/copy.dart';
import 'package:rapid_review/data/_cache.dart';
import 'package:rapid_review/data/_theme.dart';
import 'package:rapid_review/auth/login.dart';
import 'package:rapid_review/data/_user.dart';
import 'package:rapid_review/data/_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.firstLaunch}) : super(key: key);
  static dynamic panelController = PanelController();
  static dynamic sideMenuKey;
  static dynamic setState;
  bool firstLaunch;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  BannerAd bannerAd = Ads.loadBanner();

  @override
  void dispose() {
    bannerAd.dispose();
    super.dispose();
  }

  @override
  void initState() {
    HomePage.sideMenuKey = GlobalKey<SideMenuState>();
    HomePage.setState = setState;
    bannerAd.load();

    if (widget.firstLaunch) {
      widget.firstLaunch = false;
      Forms.launch();
      Recents.launch();
      Settings.loadBlockedAccounts();
      Settings.loadLinkedAccounts();
    }
    super.initState();
  }

  Color recentsTextColor(String text) {
    if (text.contains(RegExp(r'accept', caseSensitive: false)) ||
        text.contains(RegExp(r'create', caseSensitive: false)) ||
        text.contains(RegExp(r'unblocked', caseSensitive: false))) {
      return Colors.greenAccent;
    } else if (text.contains(RegExp(r'delete', caseSensitive: false)) ||
        text.contains(RegExp(r'block', caseSensitive: false)) ||
        text.contains(RegExp(r'decline', caseSensitive: false))) {
      return Colors.redAccent;
    }
    return const Color(0xFF868BAD);
  }

  @override
  Widget build(BuildContext context) => SlidingUpPanel(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      controller: HomePage.panelController,
      color: AppTheme.backgroundColor,
      maxHeight: MediaQuery.of(context).size.height,
      minHeight: 0,
      panel: FormPage(),
      body: SideMenu(
          closeIcon: Icon(Icons.close, color: AppTheme.textColor, size: 30.w),
          key: HomePage.sideMenuKey,
          menu: MenuBar(homeContext: context),
          maxMenuWidth: 270.w,
          type: SideMenuType.slide,
          background: AppTheme.backgroundColor,
          radius: BorderRadius.circular(40),
          child: Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: GestureDetector(
                  onTap: () async {
                    if (HomePage.sideMenuKey.currentState!.isOpened)
                      HomePage.sideMenuKey.currentState!.closeSideMenu();
                  },
                  child: SafeArea(
                      child:
                          ListView(physics: BouncingScrollPhysics(), children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(
                            left: 28.w, right: 18.w, top: 36.h, bottom: 36.h),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Rapid",
                                  style: TextStyle(
                                      color: AppTheme.textColor,
                                      fontSize: 34.w,
                                      fontWeight: FontWeight.bold)),
                              GestureDetector(
                                  onTap: () async {
                                    if (HomePage
                                        .sideMenuKey.currentState!.isOpened) {
                                      HomePage.sideMenuKey.currentState!
                                          .closeSideMenu();
                                    } else {
                                      HomePage.sideMenuKey.currentState!
                                          .openSideMenu();
                                    }
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 5.h, right: 20.w),
                                      child: Icon(Icons.menu_rounded,
                                          size: 30.w,
                                          color: AppTheme.textColor)))
                            ])),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Requests",
                                  style: TextStyle(
                                      color: AppTheme.headerColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.w))
                            ])),
                    SizedBox(height: 16.h),
                    RequestsStream(),
                    SizedBox(height: 28.h),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Properties",
                                  style: TextStyle(
                                      color: AppTheme.headerColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.w))
                            ])),
                    SizedBox(height: 16.h),
                    SizedBox(
                        height: 236.h,
                        child: ListView(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              SizedBox(width: 18.w),
                              randomCard(
                                  height: 236.h,
                                  title: Row(children: <Widget>[
                                    Text("Forms",
                                        style: TextStyle(
                                            fontSize: 23.w,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textColor))
                                  ]),
                                  subtitle: Column(children: <Widget>[
                                    ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            Cache.fetch("form-codes").length,
                                        itemBuilder: (context, index) =>
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: 8.h,
                                                    bottom: 8.h,
                                                    left: 15.w,
                                                    right: 15.w),
                                                child: GestureDetector(
                                                    onTap: () async {
                                                      if (HomePage
                                                          .sideMenuKey
                                                          .currentState!
                                                          .isOpened) {
                                                        HomePage.sideMenuKey
                                                            .currentState!
                                                            .closeSideMenu();
                                                      } else {
                                                        setState(() {
                                                          Forms
                                                              .currentCode = Cache
                                                                  .fetch(
                                                                      "form-codes")
                                                              .keys
                                                              .toList()[index];
                                                        });
                                                        HomePage.panelController
                                                            .open();
                                                      }
                                                    },
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20.w),
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10), // radius of 10
                                                                color: AppTheme
                                                                    .backgroundColor),
                                                        child: Row(
                                                            children: <Widget>[
                                                              Flexible(
                                                                  child: Text(
                                                                      Cache.fetch("form-codes")
                                                                              .keys
                                                                              .toList()[
                                                                          index],
                                                                      style: TextStyle(
                                                                          color: AppTheme
                                                                              .textColor),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .fade,
                                                                      softWrap:
                                                                          false)),
                                                              Spacer(),
                                                              CopyButton(
                                                                  size: 23.h,
                                                                  to_copy: CurrentUser
                                                                          .get()! +
                                                                      "-" +
                                                                      Cache.fetch(
                                                                              "form-codes")
                                                                          .keys
                                                                          .toList()[index]),
                                                              IconButton(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  splashRadius:
                                                                      0.01,
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .delete_rounded),
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      Forms.currentCode =
                                                                          "";
                                                                    });
                                                                    Popup(Forms.deleteCode, context).show(
                                                                        'Delete ' +
                                                                            Cache.fetch("form-codes").keys.toList()[index],
                                                                        index);
                                                                  })
                                                            ]))))),
                                    Cache.fetch("form-codes").length <
                                            CurrentUser.maxForms
                                        ? GestureDetector(
                                            onTap: () async {
                                              if (HomePage.sideMenuKey
                                                  .currentState!.isOpened) {
                                                HomePage
                                                    .sideMenuKey.currentState!
                                                    .closeSideMenu();
                                              } else {
                                                String _code =
                                                    await Forms.create();
                                                setState(() {
                                                  Forms.currentCode = _code;
                                                });
                                                HomePage.panelController.open();
                                              }
                                            },
                                            child: Container(
                                                padding: EdgeInsets.only(
                                                    right: 15.w,
                                                    left: 15.w,
                                                    bottom: 12.h,
                                                    top: 12.h),
                                                child: Text("Create new form",
                                                    style: TextStyle(
                                                        color: AppTheme
                                                            .backgroundColor)),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // radius of 10
                                                    color: AppTheme.textColor)))
                                        : Container()
                                  ])),
                              SizedBox(width: 34.w),
                              randomCard(
                                  height: 236.h,
                                  title: Row(children: <Widget>[
                                    Text("Confirmations",
                                        style: TextStyle(
                                            fontSize: 23.w,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textColor))
                                  ]),
                                  subtitle: Column(children: <Widget>[
                                    Row(children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.only(
                                              top: 12.h,
                                              left: 8.w,
                                              right: 20.w,
                                              bottom: 8.h),
                                          child: CircleTimer()),
                                      RichText(
                                          text: TextSpan(children: <TextSpan>[
                                        TextSpan(
                                            text: 'Code  ',
                                            style: TextStyle(
                                                color: AppTheme.textColor,
                                                fontSize: 21,
                                                fontWeight: FontWeight.w600)),
                                        TextSpan(
                                            text: Confirmations.newCode()
                                                .toString(),
                                            style: TextStyle(
                                                color: AppTheme.textColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 18.5)),
                                      ]))
                                    ]),
                                  ])),
                              SizedBox(width: 34.w),
                              randomCard(
                                  height: 236.h,
                                  title: Row(children: <Widget>[
                                    Text("Recent",
                                        style: TextStyle(
                                            fontSize: 23.w,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textColor))
                                  ]),
                                  subtitle: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: Recents.getActions().length,
                                      itemBuilder: (context, index) => Padding(
                                          padding: EdgeInsets.only(
                                              top: 4.h,
                                              bottom: 4.h,
                                              left: 15.w,
                                              right: 15.w),
                                          child: Container(
                                              padding: !Recents.getActions()[index].contains(RegExp(r'undo', caseSensitive: false)) &&
                                                      !Recents.getActions()[index]
                                                          .contains(RegExp(
                                                              r'create',
                                                              caseSensitive:
                                                                  false)) &&
                                                      !Recents.getActions()[index]
                                                          .contains(RegExp(
                                                              r'block',
                                                              caseSensitive:
                                                                  false))
                                                  ? EdgeInsets.only(
                                                      left: 20.w,
                                                      top: 5.h,
                                                      bottom: 5.h)
                                                  : EdgeInsets.only(
                                                      left: 20.w,
                                                      top: 22.5.h,
                                                      bottom: 22.5.h),
                                              child: Row(children: <Widget>[
                                                Flexible(
                                                    child:
                                                        SingleChildScrollView(
                                                            physics:
                                                                BouncingScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Text(
                                                              Recents.getActions()[
                                                                  index],
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14.w,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: recentsTextColor(
                                                                      Recents.getActions()[
                                                                          index])),
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                              softWrap: false,
                                                            ))),
                                                !Recents.getActions()[index]
                                                            .contains(RegExp(
                                                                r'undo',
                                                                caseSensitive:
                                                                    false)) &&
                                                        !Recents.getActions()[index]
                                                            .contains(RegExp(
                                                                r'create',
                                                                caseSensitive:
                                                                    false)) &&
                                                        !Recents.getActions()[index]
                                                            .contains(RegExp(
                                                                r'block',
                                                                caseSensitive:
                                                                    false))
                                                    ? RefreshButton(
                                                        size: 33.h,
                                                        function: () async =>
                                                            Recents.undoAction(Recents.getActions()[index]))
                                                    : Container()
                                              ]),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10), // radius of 10
                                                  color: AppTheme.backgroundColor))))),
                              SizedBox(width: 16.w),
                            ])),
                    if (Ads.bannerState)
                      Container(
                        margin: EdgeInsets.only(
                            top: 15.h, bottom: 10.h, right: 30.w),
                        alignment: Alignment.center,
                        child: AdWidget(ad: bannerAd),
                        width: bannerAd.size.width.toDouble(),
                        height: bannerAd.size.height.toDouble(),
                      )
                  ]))))));
}

class MenuBar extends StatelessWidget {
  const MenuBar({Key? key, required this.homeContext}) : super(key: key);
  final dynamic homeContext;

  @override
  Widget build(BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20.w),
            Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: CircleAvatar(
                    radius: 25,
                    child: ClipRRect(
                        child: Image.network(CurrentUser.getAvatar()!,
                            errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) =>
                                Image.asset(
                                    "assets/images/no_profile_picture.png")),
                        borderRadius: BorderRadius.circular(50)))),
            SizedBox(height: 16.h),
            Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Text(
                  "Welcome",
                  style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 14.w,
                      fontWeight: FontWeight.w400),
                )),
            SizedBox(height: 3.h),
            Row(children: [
              Flexible(
                  child: Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 10.w),
                      child: Text(
                        " " + CurrentUser.getDisplayName()!,
                        style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 20.w,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ))),
              GestureDetector(
                  onTap: () async {
                    HomePage.setState(() {
                      Provider.of<GoogleAuthentication>(homeContext,
                            listen: false)
                        .googleLogout();
                    });
                    Get.to(LoginPage(), transition: Transition.downToUp);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: Icon(Icons.logout,
                        size: 24.w, color: AppTheme.textColor),
                  ))
            ]),
            SizedBox(height: 6.3.h),
            GestureDetector(
                onTap: () async => Get.to(() => SettingsPage(),
                      transition: Transition.rightToLeftWithFade),
                child: Padding(
                    padding:
                        EdgeInsets.only(top: 20.w, left: 20.w, bottom: 20.w),
                    child: Row(children: <Widget>[
                      Icon(Icons.settings,
                          size: 24.w, color: AppTheme.textColor),
                      SizedBox(width: 15.w),
                      Text("Settings",
                          style: TextStyle(
                              color: AppTheme.textColor, fontSize: 17))
                    ]))),
          ]);
}
