import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_review/pages/home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import "dart:math";

// Returns a card with random gradients
Widget randomCard(
    {required Widget title,
    required Widget subtitle,
    String? avatar,
    Function? onTap,
    double? height,
    double? width}) {
  Color? gradientStartColor;
  Color? gradientEndColor;

  List<List<Color>> colors = [
    [Color(0xFFCD67FC), Color(0xFF4300FA)],
    [Color(0xFFCD67FC), Color(0xFF4300FA)],
    [Color(0xffFC67A7), Color(0xffF6815B)]
  ];

  // Select random color gradients
  List _colors = colors[Random().nextInt(colors.length)];
  gradientStartColor = _colors[0];
  gradientEndColor = _colors[1];

  // Return the card
  return StyledCard(
      onTap: onTap,
      title: title,
      subtitle: subtitle,
      avatar: avatar,
      height: height,
      width: width,
      gradientStartColor: gradientStartColor,
      gradientEndColor: gradientEndColor);
}

class StyledCard extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final String? avatar;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final double? height;
  final double? width;
  final Function? onTap;
  StyledCard(
      {Key? key,
      this.title,
      this.subtitle,
      this.avatar,
      this.gradientStartColor,
      this.gradientEndColor,
      this.height,
      this.width,
      this.onTap})
      : super(key: key);

  // Get the styled card avatar
  Widget getAvatar() {
    if (avatar != null && avatar != "") {
      return Row(children: <Widget>[
        CircleAvatar(
            radius: 20,
            child: ClipRRect(
                child: Image.network(avatar!,
                    errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) =>
                        Image.asset("assets/images/discord_logo.png")),
                borderRadius: BorderRadius.circular(50))),
        SizedBox(width: 20.w)
      ]);
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () async {
        HomePage.sideMenuKey != null &&
                HomePage.sideMenuKey!.currentState!.isOpened
            ? HomePage.sideMenuKey?.currentState?.closeSideMenu()
            : onTap != null
                ? onTap!()
                : () async => {};
      },
      child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: <Color>[
                gradientStartColor ?? Color(0xff441DFC),
                gradientEndColor ?? Color(0xff4E81EB),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Container(
              height: height == null ? 176.w : height,
              width: width == null ? 305.w : width,
              child: Stack(children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: SizedBox(
                      height: height == null ? 176.w : height,
                      width: width == null ? 305.w : width,
                      child: SvgPicture.asset("assets/svg/vector_wave_2.svg",
                          fit: BoxFit.cover),
                    )),
                ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: SizedBox(
                      height: height == null ? 176.w : height,
                      width: width == null ? 305.w : width,
                      child: SvgPicture.asset("assets/svg/vector_wave_1.svg",
                          fit: BoxFit.cover),
                    )),
                Padding(
                    padding: EdgeInsets.only(
                        right: 24.w, left: 24.w, top: 24.h, bottom: 24.h),
                    child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Row(children: <Widget>[
                          getAvatar(),
                          Flexible(
                              child: Column(children: <Widget>[
                            Material(color: Colors.transparent, child: title!),
                            SizedBox(height: 5.h),
                            subtitle != null ? subtitle! : Container()
                          ]))
                        ])))
              ]))));
}
