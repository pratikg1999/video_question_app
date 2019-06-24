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

/// The page where the user can see all his not uploaded questions.
class Questions extends StatefulWidget{
  @override
  QuestionsState createState() {
    return QuestionsState();
  }
}

/// Builds the state associated with [Questions]
class QuestionsState extends State<Questions>{

  /// The location of the app in the mobile.
  Directory appDirectory;
  /// The location of the place where videos are stored in the mobile.
  Directory videoDirectory;
  /// The path of the directory where the videos are stored.
  String videoDirectoryPath;
  /// The list of names of the not uploaded questions.
  List<String> list = [];
  /// The email of the current logged in user.
  String email;

  /// Sets the initial values for the state variables.
  ///
  /// * [getFromSP()] returns the email of the current user.
  /// * [getExternalStorageDirectory()] returns the directory of the application.
  /// * Timer triggers the action after certain period of time.
  void setter () async {
    email = await getFromSP(EMAIL_KEY_SP);
    appDirectory = await getExternalStorageDirectory();
    videoDirectoryPath = '${appDirectory.path}/Drupal_Videos';
    await Directory(videoDirectoryPath).create(recursive: true);
    videoDirectory = Directory.fromUri(Uri.file(videoDirectoryPath));
    List<String> l = List<String>();
    l = await getNotUploaded(email);
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


  /// To upload the not uploaded question.
  ///
  /// [renameSync()] method is used to rename the file.
  /// [uploadFile()] method actually uploads the question to the server.
  /// [updateFile()] method updates the content of the associated JSON file.
  void uploadVideoNow(String s)async {
    String temp = videoDirectoryPath+ "/" + s.substring(0,13) + ".mp4";
    File(videoDirectoryPath +"/"+ s).renameSync(temp);
    uploadFile(temp);
    updateFile(email, s.substring(0,13));
    setter();
  }

  ///Returns the list of [ChewieListItem] widget.
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

  /// To remove unneeded resources associated with each of the chewieListItem.
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
        drawer: NavDrawer(),
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