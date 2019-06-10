
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'chewieListItem.dart';
import 'package:video_player/video_player.dart';
import 'uploadVideo.dart';



class Questions extends StatefulWidget{
  @override
  QuestionsState createState() {
    return QuestionsState();
  }
}

class QuestionsState extends State<Questions>{

  Directory appDirectory,videoDirectory;
  String videoDirectoryPath;
  List<String> list;

  void setter () async {

       appDirectory = await getExternalStorageDirectory();
       videoDirectoryPath = '${appDirectory.path}/Drupal_Videos';
       await Directory(videoDirectoryPath).create(recursive: true);
       videoDirectory = Directory.fromUri(Uri.file(videoDirectoryPath));
       List<String> l = List<String>();
       List contents = videoDirectory.listSync();
       for(var file in contents){
         String temp = file.toString().substring(file.toString().lastIndexOf('/'),file.toString().length-1);
         if(temp.endsWith("NotUploaded.mp4"))
              l.add(temp);
       }

       setState(() {
         list = l;
       });

  }

  @override
  void initState(){
    super.initState();
    setter();
  }

  String data = "fetching";


//  List<Widget> getVideos(){
//
//    List<Widget> listArray = List<Widget>();
//    if(list!=null) {
//      for (var i = 0; i < list.length; i++) {
//        String path = videoDirectoryPath + list[i];
//        myfile = new File(path);
//        listArray.add(Column(
//          children: <Widget>[
//            ChewieListItem(
//            videoPlayerController: VideoPlayerController.file(myfile),),
//          ],
//        ));
//      }
//    }
//    return listArray;
//  }

  void uploadVideoNow(String s){

  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Video Question App"),
        ),
        body: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context,index){
             return  ChewieListItem(
              file: new File(videoDirectoryPath + list[index]));
            }
        )

    );
  }
}