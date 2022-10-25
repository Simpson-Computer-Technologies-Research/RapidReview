// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:test/data/cache.dart';
import 'package:test/pages/requests_page.dart';
import 'package:test/widgets/bottom_nav_bar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:test/widgets/filters_panel.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

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

class _HomePageState extends State<HomePage> {
  var panelController, barText;

  @override
  void initState() {
    super.initState();
    barText = "Requests";
    panelController = PanelController();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const BottomNavBar(),
    backgroundColor: Colors.black,
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 80,
      backgroundColor: Colors.black,
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
              onTap: () async => panelController.isPanelOpen ? panelController.close(): panelController.open(),
              child: const ImageIcon(
                AssetImage("assets/images/filter.png"),
                size: 23,
                color: Colors.white
              )
            )
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Text(barText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Aeonik-Bold"
              )
            )
          ),
          const Spacer()
        ]
      )
    ),
    body: SlidingUpPanel(
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      onPanelSlide: (pos) async {
        if (pos < 0.95 && barText == "Filters") {
          setState(() { barText = "Requests"; });
        } else if (pos > 0.95 && barText == "Requests") {
          setState(() { barText = "Filters"; });
        }
      },
      color: Colors.black,
      minHeight: 0,
      maxHeight: MediaQuery.of(context).size.height - 200,
      controller: panelController,
      panel: const FiltersPanel(),
      body: ListView(physics: const BouncingScrollPhysics(), children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            width: 350,
            height: 35,
            child: TextField(
              onChanged: (text) async {

              },
              style: const TextStyle(
                fontFamily: "Aeonik-Normal",
                color: Color.fromARGB(210, 224, 224, 224)
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(top: 0.5),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Color.fromARGB(210, 224, 224, 224)
                ),
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Color.fromARGB(210, 224, 224, 224)
                ),
              )
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color.fromARGB(255, 20, 20, 20)
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: SizedBox(
            height: 75,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: profilePictures.length,
              itemBuilder: (BuildContext context, int index) {
                FadeInController controller = FadeInController();
                bool isVisible = false;
                return GestureDetector(
                  onTap: () async => !isVisible? {controller.fadeIn(), isVisible = true}: {controller.fadeOut(), isVisible = false},
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.redAccent,
                      child: CircleAvatar(
                      radius: 24,
                      backgroundImage: Cache.getImageFromMemory(profilePictures[index]))),
                    ),
                    FadeIn(
                      controller: controller,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Text("Declined",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: "Aeonik-Normal",
                            fontSize: 14
                          )
                        )
                      ),
                    )
                  ])
                );
        }))),
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: GridView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3 / 2),
            itemCount: profilePictures.length,
            itemBuilder: (BuildContext context, int index) =>
            FutureBuilder<Map>(
              future: Cache.getProfileImageBytes(profilePictures[index]),
              builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {

                if (snapshot.hasData || snapshot.hasError) {
                  return GestureDetector(
                    onTap: () async => Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => RequestsPage(index: index))),
                    child: Stack(children: [
                      Container(
                        width: 160,
                        height: 100,
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 8, 10, 10),
                            borderRadius: BorderRadius.all(Radius.circular(20)))
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: !snapshot.hasError ? Cache.rgbConvert(snapshot.data!["profile_image_colors"][profilePictures[index]]): Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20), 
                            topRight: Radius.circular(20)
                          )
                        ),
                        width: 160,
                        height: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 10),
                        child: CircleAvatar(radius: 26,
                            backgroundColor: const Color.fromARGB(255, 8, 10, 10),
                            child: CircleAvatar(radius: 21, backgroundImage: !snapshot.hasError
                                    ? snapshot.data!["profile_image_bytes"][profilePictures[index]]
                                    : const AssetImage("assets/images/no_profile.png"))
                        )
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 40, left: 70),
                        child: Text("Tristan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: "Aeonik-Bold"
                          )
                        )
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 76, left: 50),
                        child: Text("Today at 4:30 PM",
                          style: TextStyle(
                            color: Color.fromARGB(255, 150, 150, 150), 
                            fontSize: 12.5, 
                            fontFamily: "Aeonik-Normal"
                          )
                        )
                      )
                    ])
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white)
                  );
                }
        }))),
        const SizedBox(height: 250),
  ])));
}
