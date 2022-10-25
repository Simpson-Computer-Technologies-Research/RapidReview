import 'package:flutter/material.dart';
import 'package:test/pages/forms_page.dart';
import 'package:test/pages/settings_page.dart';
import 'package:test/pages/home_page.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

int currentIndex = 0;

class _BottomNavBarState extends State<BottomNavBar> {
  List pages = const [HomePage, FormsPage, SettingsPage];
  List<AssetImage> imageAssets = const [
    AssetImage("assets/images/cards.png"),
    AssetImage("assets/images/forms.png"),
    AssetImage("assets/images/settings.png")
  ];

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 15, bottom: 30),
    height: MediaQuery.of(context).size.width * .155,
    child: Center(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: imageAssets.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => InkWell(
          onTap: () async {
            setState(() { currentIndex = index; });
              currentIndex == 0 ? Get.to(() => const HomePage(), transition: Transition.fadeIn)
              : currentIndex == 1 ? Get.to(() => const FormsPage(), transition: Transition.fadeIn)
              : Get.to(() => const SettingsPage(), transition: Transition.fadeIn);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.fastLinearToSlowEaseIn,
                margin: EdgeInsets.only(
                  bottom: index == currentIndex? 0: MediaQuery.of(context).size.width * .029,
                  right: MediaQuery.of(context).size.width * .0422,
                  left: MediaQuery.of(context).size.width * .0422,
                ),
                width: MediaQuery.of(context).size.width * .128,
                height: index == currentIndex ? MediaQuery.of(context).size.width * .014: 0,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                )
              ),
              ImageIcon(
                imageAssets[index],
                size: index == 0 ? 36: index == 1? 23: 25,
                color: index == currentIndex ? Colors.blueAccent: Colors.white,
              ),
              SizedBox(height: MediaQuery.of(context).size.width * .03)
          ])
        )
      )
    )
  );
}
