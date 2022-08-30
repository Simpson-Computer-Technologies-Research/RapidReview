import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:rapid_review/pages/home_page.dart';
import 'package:rapid_review/widgets/popups.dart';
import 'package:rapid_review/widgets/cards.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rapid_review/data/_theme.dart';
import 'package:rapid_review/data/_cache.dart';
import 'package:rapid_review/data/_http.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key, required this.user}) : super(key: key);
  static var setState;
  final String user;

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  @override
  void initState() {
    super.initState();
    RequestPage.setState = setState;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  // Accept request function
  Future<void> acceptPendingRequest() async {
    Navigator.pop(context);
    Map user = Cache.fetch("pending-requests")[widget.user];
    bool result = await DiscordApi.send(
        option: "add",
        guildId: user["data"]["guild_id"],
        userId: user["data"]["user_id"],
        roleId: user["data"]["role_id"]);

    if (result) {
      Recents.addAction("Accepted ${widget.user}'s request",
          Cache.fetch("pending-requests")[widget.user]);
      await Future.delayed(Duration(milliseconds: 200));
      await Requests.delete(
          Requests.users()[Requests.users().indexOf(widget.user)]);
    }
  }

  // Decline request function
  Future<void> declinePendingRequest() async {
    Navigator.pop(context);
    Recents.addAction("Declined ${widget.user}'s request",
        Cache.fetch("pending-requests")[widget.user]);
    await Future.delayed(Duration(milliseconds: 200));
    await Requests.delete(
        Requests.users()[Requests.users().indexOf(widget.user)]);
  }

  // Block users requests function
  Future<void> blockUser() async {
    Navigator.pop(context);
    if (await Blocked.blockUser(widget.user)) {
      Recents.addAction("Blocked ${widget.user}'s request's");
      await Future.delayed(Duration(milliseconds: 200));
      await Requests.delete(
          Requests.users()[Requests.users().indexOf(widget.user)]);
    }
  }

  // Questions and answers list view
  Widget questionsAndAnswers() {
    List questions = [];
    List answers = [];
    List images = [];

    // Add the questions, answers and images to the corresponding lists
    Cache.fetch("pending-requests")[widget.user]["values"].forEach((k, v) => {
          if (!v.contains("http"))
            {questions.add(k), answers.add(v)}
          else
            {
              for (String i in v.split(" * ")) {images.add(i)}
            }
        });
    return Column(children: <Widget>[
      SizedBox(height: 30.h),
      questions.isNotEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(children: <Widget>[
                Text("Responses",
                    style: TextStyle(
                        color: AppTheme.headerColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.w))
              ]))
          : Container(),
      questions.isNotEmpty
          ? Container(
              height: 200.w,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: questions.length,
                  itemBuilder: (context, index) => Row(children: <Widget>[
                        questions.isNotEmpty && questions.length > 1
                            ? SizedBox(width: 28.w)
                            : Container(),
                        randomCard(
                            title: Linkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                }
                              },
                              text: questions[index],
                              style: TextStyle(
                                  fontSize: 22.w,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor),
                              linkStyle: TextStyle(color: Colors.blueAccent),
                            ),
                            subtitle: Linkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                }
                              },
                              text: answers[index],
                              style: TextStyle(
                                  fontSize: 16.w,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textColor),
                              linkStyle: TextStyle(color: Colors.blueAccent),
                            )),
                        questions.length > 1
                            ? SizedBox(width: 3.w)
                            : SizedBox(width: 16.w),
                      ])))
          : Container(),
      images.isNotEmpty
          ? Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Content",
                            style: TextStyle(
                                color: AppTheme.headerColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14.w))
                      ])),
              SizedBox(height: 8.h),
              Container(
                  height: 200.h,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) => Row(children: <Widget>[
                            images.length > 1
                                ? SizedBox(width: 27.w)
                                : Container(),
                            !images[index].contains(".mp4")
                                ? GestureDetector(
                                    onTap: () async => Get.to(
                                        () => ImageViewer(image: images[index]),
                                        transition: Transition.downToUp),
                                    child: Container(
                                        height: 176.w,
                                        width: 305.w,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(26),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image:
                                                  NetworkImage(images[index]),
                                            ))))
                                : VideoViewer(video: images[index]),
                            images.length > 0
                                ? SizedBox(width: 6.w)
                                : SizedBox(width: 45.w),
                          ])))
            ])
          : Container()
    ]);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        platform: Theme.of(context).platform,
      ),
      home: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
              child: Column(children: <Widget>[
            Expanded(
                child: Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 20.w, top: 20.h, bottom: 20.h),
                  child: GestureDetector(
                      onTap: () {
                        Get.to(() => HomePage(firstLaunch: false),
                            transition: Transition.leftToRightWithFade);
                      },
                      child: Row(children: <Widget>[
                        Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textColor, size: 25),
                        Text("  Back",
                            style: TextStyle(
                                color: AppTheme.textColor, fontSize: 17.h))
                      ]))),
              SizedBox(height: 10.h),
              Row(children: <Widget>[
                SizedBox(width: 20.h),
                CircleAvatar(
                    radius: 20,
                    child: ClipRRect(
                        child: Image.network(
                            Cache.fetch("pending-requests")[widget.user]["data"]
                                ["avatar_url"],
                            errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) =>
                                Image.asset("assets/images/discord_logo.png")),
                        borderRadius: BorderRadius.circular(50))),
                Padding(
                    padding: EdgeInsets.only(left: 18.w),
                    child: Material(
                        color: Colors.transparent,
                        child: Text(widget.user,
                            style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 34.w,
                                fontWeight: FontWeight.bold))))
              ]),
              SizedBox(height: 15.h),
              Row(children: <Widget>[
                Flexible(
                    child: Padding(
                        padding: EdgeInsets.only(left: 78.w),
                        child: Text(
                            Cache.fetch("pending-requests")[widget.user]["data"]
                                ["guild_name"],
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: AppTheme.textColor.withOpacity(0.7),
                                fontWeight: FontWeight.w400,
                                fontSize: 16.w)))),
                Flexible(
                    child: Padding(
                        padding: EdgeInsets.only(left: 28.w),
                        child: Text(
                            "@" +
                                Cache.fetch("pending-requests")[widget.user]
                                    ["data"]["role_name"],
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(1),
                                fontWeight: FontWeight.w400,
                                fontSize: 16.w))))
              ]),
              questionsAndAnswers()
            ])),
            Padding(
                padding: EdgeInsets.only(
                    top: 20.h, bottom: 20.h, left: 20.w, right: 20.w),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () async {
                            Popup(blockUser, context)
                                .show("Block " + widget.user + "'s requests");
                          },
                          child: Container(
                            width: 90.w,
                            height: 45.h,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 24, 24, 24),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.w))),
                            alignment: Alignment.center,
                            child: Text("Block",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 109, 109, 109),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400)),
                          )),
                      GestureDetector(
                          onTap: () async {
                            Map data =
                                Cache.fetch("pending-requests")[widget.user];
                            Popup(acceptPendingRequest, context).show("Accept " +
                                widget.user +
                                "'s request\n\nAccepting will do the following:\n - Add role '${data["data"]["role_name"]}'\n");
                          },
                          child: Container(
                            width: 100.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.w))),
                            alignment: Alignment.center,
                            child: Text("Accept",
                                style: TextStyle(
                                    color: Color(0xff121421),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500)),
                          )),
                      GestureDetector(
                          onTap: () async {
                            Popup(declinePendingRequest, context)
                                .show("Decline " + widget.user + "'s request");
                          },
                          child: Container(
                            width: 90.w,
                            height: 45.h,
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.w))),
                            alignment: Alignment.center,
                            child: Text("Decline",
                                style: TextStyle(
                                    color: Color(0xff121421),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400)),
                          ))
                    ]))
          ]))));
}

// Watch a video
class VideoViewer extends StatefulWidget {
  const VideoViewer({Key? key, required this.video}) : super(key: key);
  final String video;

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    initializePlayer();
    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController!.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoController = VideoPlayerController.network(widget.video);
    await Future.wait([_videoController.initialize()]);
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
          width: 310.w,
          child: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[CircularProgressIndicator()])));
}

// View an image in fullscreen
class ImageViewer extends StatefulWidget {
  const ImageViewer({Key? key, required this.image}) : super(key: key);
  final String image;

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
          child: PhotoView(
        imageProvider: NetworkImage(widget.image),
      )),
      floatingActionButton: FloatingActionButton(
          foregroundColor: AppTheme.backgroundColor,
          backgroundColor: AppTheme.textColor,
          onPressed: () async {
            Navigator.pop(context);
          },
          tooltip: "Back",
          child: RotatedBox(
              quarterTurns: 3, child: Icon(Icons.arrow_back_ios_new_rounded))));
}
