import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_review/pages/home_page.dart';
import 'package:flutter/material.dart';

class Popup {
  late final Function function;
  late final BuildContext context;
  Popup(this.function, this.context);

  // Show the general dialog popup
  void show(String contentText, [funcParams]) => showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 150),
      context: context,
      pageBuilder: (_, __, ___) => AlertDialog(
              title: const Text("Are you sure?",
                  style: TextStyle(color: Color(0xffffffff))),
              content: Text(contentText,
                  style:
                      const TextStyle(fontSize: 15, color: Colors.redAccent)),
              backgroundColor: const Color(0xff121421),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actions: <Widget>[
                GestureDetector(
                    onTap: () async => Navigator.pop(context),
                    child: Container(
                        child: const Text("Cancel",
                            style: TextStyle(color: Color(0xffffffff))),
                        padding: EdgeInsets.only(
                            top: 11.h, bottom: 11.h, left: 17.w, right: 17.w),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5), // radius of 10
                            color: Colors.redAccent // green as background color
                            ))),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(left: 5.w, right: 5.w),
                    padding: EdgeInsets.only(
                        top: 11.h, bottom: 11.h, left: 17.w, right: 17.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), // radius of 10
                        color: Color(0xFF4961FF)),
                    child: const Text("Confirm",
                        style: TextStyle(color: Color(0xffffffff))),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    HomePage.setState(() {
                      if (funcParams != null) {
                        function(funcParams);
                      } else {
                        function();
                      }
                    });
                  },
                )
              ]));
}
