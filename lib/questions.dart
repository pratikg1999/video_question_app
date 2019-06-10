import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/shared_preferences_helpers.dart';
import 'constants.dart';
import "dart:convert";
import 'dart:io';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'chewieListItem.dart';
import 'package:video_player/video_player.dart';

class Questions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return QuestionsState();
  }
}

class QuestionsState extends State<StatefulWidget> {

  Directory appDirectory, videoDirectory;
  String videoDirectoryPath;
  List<String> list;
  File myfile;
  VideoPlayerController _controller;

  void setter() async {
    appDirectory = await getExternalStorageDirectory();
    videoDirectoryPath = '${appDirectory.path}/Drupal_Videos';
    await Directory(videoDirectoryPath).create(recursive: true);
    videoDirectory = Directory.fromUri(Uri.file(videoDirectoryPath));
    List<String> l = List<String>();
    List contents = videoDirectory.listSync();
    for (var file in contents) {
      String temp = file.toString().substring(
          file.toString().lastIndexOf('/'), file
          .toString()
          .length - 1);
      if (temp.endsWith("NotUploaded.mp4"))
        l.add(temp);
    }

    setState(() {
      list = l;
    });
  }

  String data = "fetching";


  List<Widget> getVideos() {
    List<Widget> listArray = List<Widget>();
    if (list.isNotEmpty) {
      for (var i = 0; i < list.length; i++) {
        String path = videoDirectoryPath + list[i];
        myfile = new File(path);
        listArray.add(new ChewieListItem(
            videoPlayerController: VideoPlayerController.file(myfile)));
      }
    }
    return listArray;
  }

  @override
  void initState() {
    _controller = VideoPlayerController.network("https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4") //VideoPlayerController.network("http://192.168.43.244:8080/downloadFile/2.%20XCode%20Setup.mp4")
      ..setVolume(1.0)
      ..initialize().then((value){
        _controller.play();
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setter();
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Video Question App"),
        ),
        body: Container(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(_controller), 
            ),
//          ListView(
//            children: getVideos(),
//          ),
        )
    );
  }
}