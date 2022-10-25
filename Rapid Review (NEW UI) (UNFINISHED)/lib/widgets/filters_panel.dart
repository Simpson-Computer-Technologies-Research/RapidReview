import 'package:flutter/material.dart';

class FiltersPanel extends StatefulWidget {
  const FiltersPanel({Key? key}) : super(key: key);

  @override
  _FiltersPanelState createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<FiltersPanel> {
  var sortRequestsBy, sortByRecentIcon, sortByNameIcon;
  Widget checkedIcon() => Container(
    height: 25,
    width: 25,
    child: const Icon(Icons.check, color: Colors.black),
    decoration: const BoxDecoration(
      color: Colors.blueAccent,
      shape: BoxShape.circle,
    )
  );
  Widget uncheckedIcon() => Container(
    height: 25,
    width: 25,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white, width: 1.2),
      color: Colors.transparent,
      shape: BoxShape.circle,
    )
  );

  @override
  void initState() {
    super.initState();
    sortRequestsBy = "";
    sortByRecentIcon = uncheckedIcon();
    sortByNameIcon = uncheckedIcon();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 20, left: 15),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text("Sort by",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "Aeonik-Bold"
            )
          )
        )
      ),
      GestureDetector(
        onTap: () async {
          if (sortRequestsBy != "name") {
            setState(() {
              sortRequestsBy = "name";
              sortByNameIcon = checkedIcon();
              sortByRecentIcon = uncheckedIcon();
            });
          } else {
            setState(() {
              sortRequestsBy = "";
              sortByNameIcon = uncheckedIcon();
            });
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 54, 54, 54),
                width: 1
              )
            )
          ),
          margin: const EdgeInsets.only(top: 10, left: 25, right: 30),
          padding: const EdgeInsets.only(top: 5, bottom: 15),
          child: Row(children: [
            const Text("Name A-Z",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Aeonik-Normal"
              )
            ),
            const Spacer(), sortByNameIcon
          ])
        )
      ),
      GestureDetector(
        onTap: () async {
          if (sortRequestsBy != "recent") {
            setState(() {
              sortRequestsBy = "recent";
              sortByNameIcon = uncheckedIcon();
              sortByRecentIcon = checkedIcon();
            });
          } else {
            setState(() {
              sortRequestsBy = "";
              sortByRecentIcon = uncheckedIcon();
            });
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1))
          ),
          margin: const EdgeInsets.only(top: 10, left: 25, right: 30),
          padding: const EdgeInsets.only(top: 5, bottom: 15),
          child: Row(children: [
            const Text("Most recent",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Aeonik-Normal"
              )
            ),
            const Spacer(), sortByRecentIcon
          ])
        )
      )
    ]
  );
}
