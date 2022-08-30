import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rapid_review/pages/request_page.dart';
import 'package:rapid_review/widgets/cards.dart';
import 'package:rapid_review/data/_theme.dart';
import 'package:rapid_review/data/_cache.dart';
import 'package:rapid_review/data/_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsStream extends StatefulWidget {
  const RequestsStream({Key? key}) : super(key: key);

  @override
  _RequestsStreamState createState() => _RequestsStreamState();
}

class _RequestsStreamState extends State<RequestsStream> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("pending-requests")
          .doc(CurrentUser.get())
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.data() != null) {
            dynamic data = snapshot.data!.data()!["requests"];
            List users = data!.keys.toList();
            Requests.update(data);

            if (users.isNotEmpty)
              return SizedBox(
                  height: 176.w,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: Requests.users().length,
                      itemBuilder: (context, index) => Row(children: <Widget>[
                            SizedBox(width: 18.w),
                            randomCard(
                                title: Text(
                                  users[index],
                                  style: TextStyle(
                                      fontSize: 22.w,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textColor),
                                ),
                                subtitle: Text(
                                    data[users[index]]["data"]["guild_name"],
                                    style: TextStyle(
                                        fontSize: 16.w,
                                        fontWeight: FontWeight.w400,
                                        color: AppTheme.textColor)),
                                avatar: data[users[index]]["data"]
                                    ["avatar_url"],
                                onTap: () async => Get.to(
                                    () => RequestPage(user: users[index]),
                                    transition: Transition.downToUp)),
                            SizedBox(width: 16.w),
                          ])));
          }
        }
        return Row(children: <Widget>[
          SizedBox(width: 18.w),
          StyledCard(
              title: Text(
                "Nothing to see here",
                style: TextStyle(
                    fontSize: 22.w,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor),
              ),
              subtitle: Text("Pending requests is empty",
                  style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textColor)))
        ]);
      });
}
