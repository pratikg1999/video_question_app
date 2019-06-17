import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_question_app/shared_preferences_helper.dart';
import 'constants.dart';
import "dart:convert";
import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'chewieListItem.dart';
import 'package:video_player/video_player.dart';
import 'storeJson.dart';

import 'drawer.dart';
class UploadedQuestions extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return UploadedQuestionsState();
  }
}

class UploadedQuestionsState extends State<StatefulWidget>{

  Directory appDirectory,videoDirectory;
  String videoDirectoryPath;
  List<String> list;
  File myfile;
    String email;


    void initState(){
      super.initState();
      setter();
    }

  void setter () async {
    email = await getFromSP(EMAIL_KEY_SP);
    appDirectory = await getExternalStorageDirectory();
    videoDirectoryPath = '${appDirectory.path}/Drupal_Videos';
    await Directory(videoDirectoryPath).create(recursive: true);
    videoDirectory = Directory.fromUri(Uri.file(videoDirectoryPath));
    List<String> l = List<String>();

    l = await getUploaded(email);

    Timer(Duration(seconds: 1),(){
      setState(() {
        list = l;
      });
    });
  }

  List<Widget> getVideos(){

    List<Widget> listArray = List<Widget>();
    if(list!=null) {
      for (var i = 0; i < list.length; i++) {
        String path = videoDirectoryPath + "/"+list[i];
        myfile = new File(path);
        listArray.add(new ChewieListItem(
            file: myfile));
      }
    }
    return listArray;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){

//    setter();
    return new Scaffold(

        drawer: NavDrawer(userName: USER_NAME, email: EMAIL,),

        appBar: new AppBar(
             title: new Text("Video Question App"),
    ),
         body: Container(
            child: ListView(
                children: getVideos(),
    ),
    )
    );
    }
}