
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'chewieListItem.dart';
import 'package:video_player/video_player.dart';
import 'constants.dart';
import 'drawer.dart';
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
  List<String> list = [];

  Future<List<String>> setter () async {

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


      return l;
  }

  @override
  void initState(){
    super.initState();
    setter().then((x){
      setState(() {
        list = x;
      });
    });
  }

  String data = "fetching";

  void uploadVideoNow(String s)async {
    String temp = videoDirectoryPath + s.substring(0,14) + ".mp4";
    File(videoDirectoryPath + s).renameSync(temp);
    for( var l in list)
      print(l);

    uploadFile(temp);

    //print(index);
   setter().then((x){
     setState(() {
       list = x;
     });
   });


//    for( var l in list)
//      print(l);
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      drawer: NavDrawer(email: EMAIL,userName: USER_NAME,),
        appBar: new AppBar(
          title: new Text("Video Question App"),
        ),
        body: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context,index){
//              print("HHHHHHHHHHHHHHH");
//              print(list.toString());
//              print(index);
              print(videoDirectoryPath + list[index]);

             return Column(
               children: <Widget>[

             new ChewieListItem(
             file: new File(videoDirectoryPath + list[index]),
               key: UniqueKey(),
             ),
             Row(
                 children: <Widget>[
                   Padding(
                 padding:EdgeInsets.all(10.0),
                     child:RaisedButton(
              child: Text('Upload'),
              onPressed: (){
              uploadVideoNow(list[index]);
              },
              ),
                 ),
                   Padding(
                     padding: EdgeInsets.all(10.0),
                     child: RaisedButton(
                       child: Text('Delete'),
                       onPressed: (){
                         File file = new File(list[index]);
                         file.delete();
                       },
                     )
                   ),
                 ],
               ),

               ],
             );
            }

        )

    );
  }
}