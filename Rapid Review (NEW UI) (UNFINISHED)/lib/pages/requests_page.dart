// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:test/data/cache.dart';
import 'package:test/pages/home_page.dart';
import 'package:test/widgets/bottom_nav_bar.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class RoleTag extends StatelessWidget {
  const RoleTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(left: 10, top: 10),
        padding: EdgeInsets.all(3),
        height: 25,
        width: 100,
        child: Text("@Moderator",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: "Aeonik-Normal")),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
      );
}

class _RequestsPageState extends State<RequestsPage> {
  List profilePictures = <String>[
    'https://cdn.discordapp.com/attachments/934513685605523558/946220899022012433/e74a42ae0c5e26867baacb8c5873a604.png',
    'https://cdn.discordapp.com/attachments/934513685605523558/946432869864177694/unknown.png',
    'https://cdn.discordapp.com/attachments/934513685605523558/946433014886457414/unknown.png',
    'https://media.discordapp.net/attachments/934513685605523558/946449207416459304/unknown.png',
    "https://cdn.discordapp.com/attachments/855448636880191499/920723959954153472/discord_wave_logo.png",
    "https://cdn.discordapp.com/attachments/855448636880191499/910725950608658452/bill_gates.jpeg",
    "https://cdn.discordapp.com/attachments/855448636880191499/906203658444755034/athena_logo.png",
    "https://cdn.discordapp.com/attachments/855448636880191499/855492820574797840/v.gif",
    'https://media.discordapp.net/attachments/934513685605523558/947584168827707402/image0.jpg',
    'https://media.discordapp.net/attachments/934513685605523558/947584093208592444/image0.jpg',
    'https://media.discordapp.net/attachments/934513685605523558/947584003089772604/image0.jpg?width=900&height=961'
  ];

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) {
    bool t = true;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          NotificationListener<ScrollUpdateNotification>(
              onNotification: (n) {
                if ((n.metrics.pixels + (widget.index * 390)) < -50) {
                  if (t) {
                    t = false;
                    Navigator.push(context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => HomePage(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 200),
                      ),
                    );
                  }
                }
                return true;
              },
              child: ScrollablePositionedList.builder(
                  physics: PageScrollPhysics(parent: BouncingScrollPhysics()),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: profilePictures.length,
                  initialScrollIndex: widget.index,
                  itemBuilder: (BuildContext context, int index) => Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode( Colors.black.withOpacity(0.22), BlendMode.dstATop),
                                image: Cache.getImageFromMemory(profilePictures[index]),
                                fit: BoxFit.cover)),
                        child: ListView(
                            physics: BouncingScrollPhysics(),
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 20, left: 15),
                                child: Text("Tristan#2230",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 45,
                                        fontFamily: "Aeonik-Bold")),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 15, bottom: 5),
                                padding: EdgeInsets.all(3),
                                child: Text("From Testing Server",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: "Aeonik-Bold")),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Row(children: const <Widget>[
                                    RoleTag(),
                                    RoleTag(),
                                    RoleTag(),
                                  ])),

                              // QUESTION #1 HOW OLD ARE YOU?
                              Container(
                                padding: EdgeInsets.only(top: 20, left: 15),
                                child: Text("How old are you?",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23,
                                        fontFamily: "Aeonik-Bold")),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5, left: 15, bottom: 10, right: 90),
                                child: Text(
                                    "Hello my name is tristan and I would like to apply for moderator on your server",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "Aeonik-Normal")),
                              ),
                              // QUESTION #2 WHERE ARE YOU FROM?
                              Container(
                                padding: EdgeInsets.only(top: 20, left: 15),
                                child: Text("Where are you from?",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23,
                                        fontFamily: "Aeonik-Bold")),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5, left: 15, bottom: 10, right: 90),
                                child: Text(
                                    "Hello my name is tristan and I would like to apply for moderator on your server",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "Aeonik-Normal")),
                              ),
                            ]),
                      ))),
          const Align(alignment: Alignment.bottomCenter, child: BottomNavBar())
        ]));
  }
}
