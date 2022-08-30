import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:rapid_review/pages/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rapid_review/widgets/copy.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rapid_review/data/_theme.dart';
import 'package:rapid_review/data/_cache.dart';
import 'package:rapid_review/data/_user.dart';
import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);
  static var setState;

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  List questions = [];

  @override
  void initState() {
    super.initState();
    FormPage.setState = setState;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Form page (home page)
  Widget creatingFormPage() =>
      ListView(physics: BouncingScrollPhysics(), children: <Widget>[
        SizedBox(height: 16.h),
        Padding(
            padding: EdgeInsets.only(
                left: 28.w, right: 18.w, top: 16.h, bottom: 16.h),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                      child: Text(Forms.currentCode,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 34.w,
                              fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 50.w, right: 8, top: 8, bottom: 8),
                      child: CopyButton(
                          size: 35.w,
                          to_copy:
                              CurrentUser.get()! + "-" + Forms.currentCode))
                ])),
        SizedBox(height: 10.h),
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: questions.length,
            itemBuilder: (context, index) => Column(children: <Widget>[
                  Container(
                      margin:
                          EdgeInsets.only(bottom: 5.h, right: 40.w, left: 40.w),
                      padding: EdgeInsets.only(
                          top: 10.h, bottom: 30.h, right: 40.w, left: 40.w),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: AppTheme.textColor,
                        width: 2,
                      ))),
                      child: Column(children: <Widget>[
                        Row(children: <Widget>[
                          Text("Question #" + (index + 1).toString(),
                              style: TextStyle(
                                  fontSize: 19.w,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor)),
                          IconButton(
                              splashRadius: 0.01,
                              color: Colors.redAccent,
                              icon: Icon(Icons.delete_rounded,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                setState(() {
                                  Forms.removeQuestion(
                                      code: Forms.currentCode,
                                      question: questions[index]);
                                });
                                await Database.update(
                                    collection: "form-codes", field: "codes");
                              })
                        ]),
                        GestureDetector(
                            onTap: () async {
                              setState(() {
                                Widgets.questionDialog(
                                    context, "Edit", index, questions);
                              });
                            },
                            child: Row(children: <Widget>[
                              Flexible(
                                  child: Linkify(
                                onOpen: (link) async {
                                  if (await canLaunch(link.url)) {
                                    await launch(link.url);
                                  }
                                },
                                text: questions[index],
                                style: TextStyle(
                                    fontSize: 16.w,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textColor),
                                linkStyle: TextStyle(color: Colors.blueAccent),
                              ))
                            ]))
                      ]))
                ])),
        Cache.fetch("form-codes")[Forms.currentCode].length <
                CurrentUser.maxQuestions
            ? Padding(
                padding: EdgeInsets.only(
                    top: 20.h, left: 90.w, right: 90.w, bottom: 60.h),
                child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        Widgets.questionDialog(context, "New");
                      });
                    },
                    child: Container(
                        padding: EdgeInsets.only(
                            top: 12.h, left: 12.w, bottom: 12.h, right: 12.w),
                        child: Text("Add Question",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.backgroundColor)),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5), // radius of 10
                            color: AppTheme.textColor))))
            : Container()
      ]);

  // Building the widget (do not touch this)
  @override
  Widget build(BuildContext context) {
    if (Forms.currentCode != "")
      questions = Cache.fetch("form-codes")[Forms.currentCode];
    return Scaffold(
        body: Forms.currentCode != ""
            ? creatingFormPage()
            : Center(
                child: Text("Nothing's here...",
                    style: TextStyle(color: AppTheme.textColor, fontSize: 25))),
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.backgroundColor,
        floatingActionButton: FloatingActionButton(
          foregroundColor: AppTheme.backgroundColor,
          backgroundColor: AppTheme.textColor,
          onPressed: () async {
            HomePage.panelController.close();
          },
          tooltip: "Home",
          child: const Icon(Icons.home),
        ));
  }
}

class Widgets {
  static void showToast(String text) => Fluttertoast.showToast(
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.redAccent,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
      msg: text);

  static bool checkText(String text, String option) {
    if (option == "New" &&
        Cache.fetch("form-codes")[Forms.currentCode].contains(text)) {
      showToast("Question already exists");
      return false;
    }
    if (text.length > 200) {
      showToast("Maximum of 200 characters");
      return false;
    }
    if (text.length < 5) {
      showToast("Minimum of 5 characters");
      return false;
    }
    return true;
  }

  // Dialog popup when an user wants to add another question
  static Future<void> questionDialog(BuildContext context, String option,
      [int? index, List? questions]) async {
    TextEditingController _controller = TextEditingController();
    if (option == "Edit") _controller.text = questions![index!];

    showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 250),
        context: context,
        pageBuilder: (_, __, ___) => Center(
            child: Card(
                semanticContainer: false,
                color: AppTheme.backgroundColor,
                margin: EdgeInsets.only(bottom: 0, left: 15, right: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onSubmitted: (text) async {
                      // Create a new question
                      if (option == "New") {
                        if (checkText(text, "New")) {
                          Navigator.pop(context, true);
                          FormPage.setState(() {
                            Forms.addQuestion(
                                code: Forms.currentCode, question: text);
                          });
                          await Database.update(
                              collection: "form-codes", field: "codes");
                        }
                      }
                      // Edit a question
                      if (option == "Edit") {
                        if (checkText(text, "Edit")) {
                          Navigator.pop(context, true);
                          FormPage.setState(() {
                            Forms.editQuestion(
                                code: Forms.currentCode,
                                index: index!,
                                question: text);
                          });
                          await Database.update(
                              collection: "form-codes", field: "codes");
                        }
                      }
                    },
                    style: TextStyle(
                        color: AppTheme.textColor, fontStyle: FontStyle.italic),
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: AppTheme.textColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: AppTheme.textColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: option,
                        labelStyle: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 18.5.w,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal))))));
  }
}
