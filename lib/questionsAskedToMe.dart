import 'package:flutter/material.dart';
import 'package:teacher/vid_player.dart';
import 'answer_video.dart';
import 'dart:core';
import 'chewieListNetwork.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shared_preferences_helpers.dart';
import 'constants.dart';
import 'drawer.dart';


/// Displays questions available for the user to answer depending on the user's interests.
class QuestionsAsked extends StatefulWidget {
  @override
  QuestionsAskedState createState() {
    return QuestionsAskedState();
  }
}


/// Establishes state with QuestionsAsked page.
class QuestionsAskedState extends State<QuestionsAsked> {

  /// Stores list of questions related to the user logged in from server.
  List list;

  /// Stores name of user logged in.
  String _name = USER_NAME;

  ///Stores email of user logged in.
  String _email = EMAIL;

  /// Gets a list of all questions from the server for the current user.
  Future<void> setter() async {
    var token = await getCurrentTokenId();
    print(token);
    print("http://$serverIP:$serverPort/getQuestions?tokenId=$token");
    var response = await http.get(
        Uri.encodeFull(
            "http://$serverIP:$serverPort/getQuestions?tokenId=$token"),
        headers: {"Accept": "application/json"});

    final map = jsonDecode(response.body);
    setState(() {
      list = map;
      print(list.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    setter();
  }


  /// Uses the [list] to display the question videos as a ListView.
  List<Widget> getVideos() {
    List<Widget> listArray = List<Widget>();
    if (list != null) {
      for (var index = 0; index < list.length; index++) {
        listArray.add(new Column(
          children: <Widget>[
            // new ChewieListItemNet(
            //   url: "http://$serverIP:$serverPort/downloadFile/" +
            //       list[index]
            //           .toString()
            //           .substring(list[index].toString().lastIndexOf("/") + 1),
            //   key: UniqueKey(),
            // ),
            VidPlayer(vidUri: "http://$serverIP:$serverPort/downloadFile/" +
                  list[index]
                      .toString()
                      .substring(list[index].toString().lastIndexOf("/") + 1), vidSource: VidPlayer.NET_SOURCE,),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    child: Text('Answer'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AnswerVideoRecorder(
                                list[index].toString().substring(
                                    list[index].toString().lastIndexOf("/") +
                                        1))),
                      );
                    },
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      child: Text('Delete'),
                      onPressed: () {},
                    )),
              ],
            ),
          ],
        ));
      }
    } else {
      listArray.add(Text("No Videos"));
    }
    return listArray;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Questions for me"),
        ),
        drawer: NavDrawer(),
        body: Container(
          child: ListView(
            children: getVideos(),
          ),
        ));
  }
}
