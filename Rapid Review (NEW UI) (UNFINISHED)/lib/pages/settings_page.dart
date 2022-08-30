// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:test/widgets/bottom_nav_bar.dart';
import 'package:test/widgets/settings_panel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var panelController, barText;

  @override
  void initState() {
    super.initState();
    barText = "Profile";
    panelController = PanelController();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      backgroundColor: Colors.black,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 80,
          backgroundColor: Colors.black,
          title: Row(children: [
            Padding(
                padding: const EdgeInsets.only(left: 15),
                child: GestureDetector(
                    onTap: () async {
                      panelController.isPanelOpen
                          ? panelController.close()
                          : panelController.open();
                    },
                    child: const ImageIcon(
                        AssetImage("assets/images/filter.png"),
                        size: 23,
                        color: Colors.white))),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(barText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Aeonik-Bold"))),
            const Spacer()
          ])),
      body: SlidingUpPanel(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onPanelSlide: (pos) async {
            if (pos < 0.95 && barText == "Filters") {
              setState(() {
                barText = "Profile";
              });
            } else if (pos > 0.95 && barText == "Profile") {
              setState(() {
                barText = "Filters";
              });
            }
          },
          color: Colors.black,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height - 200,
          controller: panelController,
          panel: const ProfilePanel(),
          body: Padding(
              padding: EdgeInsets.all(10),
              child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: <
                        Widget>[
                      const CircleAvatar(
                          backgroundColor: Colors.white, radius: 30),
                      Column(children: <Widget>[
                        Text("heytristaann",
                            style:
                                TextStyle(color: Colors.white, fontSize: 30)),
                        Row(children: [
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: Text("dwy2b8db2udwsjnhb28ydb2bsjnd3",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 177, 177, 177),
                                      fontSize: 15)))
                        ])
                      ])
                    ])
                  ]))));
}
