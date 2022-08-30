import 'package:flutter/material.dart';

class ProfilePanel extends StatefulWidget {
  const ProfilePanel({Key? key}) : super(key: key);

  @override
  _ProfilePanelState createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  var blockedUsersIcon, hideBlockedUsers, recentsIcon, hideRecents;
  Widget checkedIcon() => Container(
      height: 25,
      width: 25,
      child: const Icon(Icons.check, color: Colors.black),
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
      ));
  Widget uncheckedIcon() => Container(
      height: 25,
      width: 25,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.2),
        color: Colors.transparent,
        shape: BoxShape.circle,
      ));

  @override
  void initState() {
    super.initState();
    hideBlockedUsers = hideRecents = false;
    blockedUsersIcon = recentsIcon = uncheckedIcon();
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
                  child: Text("Hide",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "Aeonik-Bold")))),
          GestureDetector(
              onTap: () async {
                setState(() {
                  if (hideRecents) {
                    recentsIcon = uncheckedIcon();
                    hideRecents = false;
                  } else {
                    recentsIcon = checkedIcon();
                    hideRecents = true;
                  }
                });
              },
              child: Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 54, 54, 54),
                              width: 1))),
                  margin: const EdgeInsets.only(top: 10, left: 25, right: 30),
                  padding: const EdgeInsets.only(top: 5, bottom: 15),
                  child: Row(children: [
                    const Text("Blocked Users",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Aeonik-Normal")),
                    const Spacer(),
                    recentsIcon
                  ]))),
          GestureDetector(
              onTap: () async {
                setState(() {
                  if (hideBlockedUsers) {
                    blockedUsersIcon = uncheckedIcon();
                    hideBlockedUsers = false;
                  } else {
                    blockedUsersIcon = checkedIcon();
                    hideBlockedUsers = true;
                  }
                });
              },
              child: Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1))),
                  margin: const EdgeInsets.only(top: 10, left: 25, right: 30),
                  padding: const EdgeInsets.only(top: 5, bottom: 15),
                  child: Row(children: [
                    const Text("Recents",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Aeonik-Normal")),
                    const Spacer(),
                    blockedUsersIcon
                  ]))),
        ],
      );
}
