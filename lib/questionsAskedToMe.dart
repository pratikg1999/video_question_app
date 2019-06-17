
import 'package:flutter/material.dart';
import 'dart:core';
import 'chewieListNetwork.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shared_preferences_helpers.dart';

class QuestionsAsked extends StatefulWidget{
  @override
  QuestionsAskedState createState() {
    return QuestionsAskedState();
  }
}

class QuestionsAskedState extends State<QuestionsAsked>{

  List list;

  Future<void> setter () async {

    var token = await getCurrentTokenId();
    print(token);

    var response = await http.get(
        Uri.encodeFull("http://192.168.43.27:8080/getQuestions?tokenId=$token"),
        headers:{
          "Accept": "application/json"
        }
    );

    final map = jsonDecode(response.body);
    setState(() {
      list = map;
      print(list.toString());
    });
  }

  @override
  void initState(){
    super.initState();
    setter();
  }


  List<Widget> getVideos(){

    List<Widget> listArray = List<Widget>();
    if(list!=null) {
      for (var index = 0; index < list.length; index++) {
        listArray.add(new Column(
          children: <Widget>[

            new ChewieListItemNet(
              url: "http://192.168.43.27:8080/downloadFile/"+list[index].toString().substring(list[index].toString().lastIndexOf("\\")+1),
              key: UniqueKey(),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    child: Text('Upload'),
                    onPressed: () {

                    },
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      child: Text('Delete'),
                      onPressed: () {

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
  Widget build(BuildContext context){
    return new Scaffold(
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