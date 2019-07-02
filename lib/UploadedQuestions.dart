import 'package:flutter/material.dart';
import 'package:teacher/shared_preferences_helpers.dart';
import 'package:teacher/vid_player.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'chewieListItem.dart';
import 'storeJson.dart';
import 'drawer.dart';

/// The page where the user can see all his uploaded questions.
class UploadedQuestions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UploadedQuestionsState();
  }
}

/// Builds the state associated with [UploadedQuestions]
class UploadedQuestionsState extends State<StatefulWidget> {
  /// The location of the app in the mobile.
  Directory appDirectory;

  ///The tokenId of the user.
  String token;

  /// The location of the place where videos are stored in the mobile.
  Directory videoDirectory;

  /// The path of the directory where the videos are stored.
  String videoDirectoryPath;

  /// The list of names of the uploaded questions.
  List<String> list = [];

  /// The email of the current logged in user.
  String email;

  ///
  List<String> listFromServerState = [];

  List<Widget> vidPlayers = [];

  void initState() {
    super.initState();
    setter();
  }

  /// Sets the initial values for the state variables.
  ///
  /// * [getFromSP()] returns the email of the current user.
  /// * [getExternalStorageDirectory()] returns the directory of the application.
  /// * Timer triggers the action after certain period of time.
  void setter() async {
    token = await getFromSP(TOKEN_KEY_SP);
    email = await getFromSP(EMAIL_KEY_SP);
    appDirectory = await getExternalStorageDirectory();
    videoDirectoryPath = '${appDirectory.path}/Drupal_Videos';
    await Directory(videoDirectoryPath).create(recursive: true);
    videoDirectory = Directory.fromUri(Uri.file(videoDirectoryPath));
    List<String> l = List<String>();
    List listFromServer = List();
    l = await getUploaded(email);

    var response = await http.get(
        Uri.encodeFull(
            "http://$serverIP:$serverPort/getUploadedQuestions?tokenId=$token"),
        headers: {"Accept": "application/json"});

    final map = jsonDecode(response.body);
    listFromServer = map;
    print(listFromServer.toString());



    Timer(Duration(seconds: 1), () {
      setState(() {
        list = l;
        listFromServerState = listFromServer;
        // vidPlayers = getVideos();
      });
    });
  }

  ///Returns the list of [ChewieListItem] widget.
  List<Widget> getVideos() {
    List<Widget> listArray = List<Widget>();
    if (list != null) {
      for (var i = 0; i < list.length; i++) {
        String path = videoDirectoryPath + "/" + list[i];
//         listArray.add(new ChewieListItem(
//             file: new File(path)));
        listArray.add(VidPlayer(
          vidUri: path,
          vidSource: VidPlayer.FILE_SOURCE,
        ));
      }
    }
    return listArray;
  }

  /// To remove unneeded resources associated with each of the chewieListItem.
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: NavDrawer(),
      appBar: new AppBar(
        title: new Text("Video Question App"),
      ),
      body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext itemContext, int index) {
            return VidPlayer(
              vidUri: videoDirectoryPath + "/" + list[index],
              vidSource: VidPlayer.FILE_SOURCE,
            );
          }
          // children: getVideos(),
          ),
    );
  }
}
