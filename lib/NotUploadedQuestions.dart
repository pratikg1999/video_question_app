import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'chewieListItem.dart';
import 'constants.dart';
import 'drawer.dart';
import 'uploadVideo.dart';
import 'storeJson.dart';
import 'dart:async';
import 'shared_preferences_helpers.dart';


class Questions extends StatefulWidget{
  @override
  QuestionsState createState() {
    return QuestionsState();
  }
}

class QuestionsState extends State<Questions>{

  Directory appDirectory,videoDirectory;
  String videoDirectoryPath;
  List<String> list = [];
  String email;

  void setter () async {
    email = await getFromSP(EMAIL_KEY_SP);
    appDirectory = await getExternalStorageDirectory();
    videoDirectoryPath = '${appDirectory.path}/Drupal_Videos';
    await Directory(videoDirectoryPath).create(recursive: true);
    videoDirectory = Directory.fromUri(Uri.file(videoDirectoryPath));
    List<String> l = List<String>();
    l = await getNotUploaded(email);
//    setState(() {
//      list = l;
//    });
    Timer(Duration(seconds: 1),(){
      setState(() {
        list = l;
      });
   });

  }

  void initState() {
    super.initState();
    setter();
  }
  String data = "fetching";

  void uploadVideoNow(String s)async {
    String temp = videoDirectoryPath+ "/" + s.substring(0,13) + ".mp4";
    File(videoDirectoryPath +"/"+ s).renameSync(temp);
//    for( var l in list)
//      print(l);
    print(temp);
    uploadFile(temp);
    updateFile(email, s.substring(0,13));
    setter();
  }

  List<Widget> getVideos(){

    List<Widget> listArray = List<Widget>();
    if(list!=null) {
      for (var index = 0; index < list.length; index++) {
        listArray.add(new Column(

          children: <Widget>[
            new ChewieListItem(
              file: new File(videoDirectoryPath + "/" + list[index]),
              key: UniqueKey()
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    child: Text('Upload'),
                    onPressed: () {
                      uploadVideoNow(list[index]);
                    },
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      child: Text('Delete'),
                      onPressed: () {
                        File file = new File(
                            videoDirectoryPath + "/" +list[index]);
                        file.delete();
                        removeFromFile(email, list[index]);
                        setState(() {
                          list.removeAt(index);
                        });
                      },
                    )
                ),
              ],
            ),
          ],
        ));
      }
    }
    else {
      listArray.add(Text("No Videos"));
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
        drawer: NavDrawer(email: EMAIL,userName: USER_NAME,),
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