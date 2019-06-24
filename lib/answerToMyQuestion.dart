import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'viewProfile.dart';
import 'package:video_player/video_player.dart';
import 'drawer.dart';
import 'constants.dart';
import 'dart:core';
import 'chewieListNetwork.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shared_preferences_helpers.dart';


/// Page that shows answers to questions of currently logged-in user
class AnswersOfMyQuestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AnswersOfMyQuestionState();
  }
}

/// UI for the Answers to my questions
class AnswersOfMyQuestionState extends State<StatefulWidget> {
  /// The list of the answers to questions.
  /// 
  /// The format of questions is-
  /// ```[[q1_path, answers-to-q1-paths...][q2_path, answers-to-q2-paths...]]```
  List list;

  /// List of details of the person with corresponding answers in [list] 
  /// 
  /// The format of [names] is-
  /// ```[[{}, details...][q2_path, details...]]```
  /// 
  /// The details of each person is a [Map] with fields- **Name, email, profile-pic, age, phone, **.
  List<List<Map<String, dynamic>>> names = [];


  /// Fetches the [list] of answers and corresponding [details] from the server
  /// 
  /// This function is called automatically by [initState()] 
  Future<void> _setter() async {
    var token = await getCurrentTokenId();
    print(token);

    var response = await http.get(
        Uri.encodeFull(
            "http://$serverIP:$serverPort/getAnswersToMyQuestions?tokenId=$token"),
        headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      List map = jsonDecode(response.body);
      print(map);
      for (var i = 0; i < map.length; i++) {
        List<Map<String, dynamic>> curQueData = [];
        curQueData.add({});
        for (var j = 1; j < map[i].length; j++) {
          var response = await http.get(
              "http://$serverIP:$serverPort/getUserFromAnswer?ansName=" +
                  map[i][j]
                      .toString()
                      .substring(map[i][j].toString().lastIndexOf("/") + 1));
          var resJson = jsonDecode(response.body);
          curQueData.add(resJson);
        }
        names.add(curQueData);
      }
      // print(map);
      print(names);
      setState(() {
        list = map;
        // print(list.toString());
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Unable to fetch your answers',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _setter();
  }


  /// Shows the question with [quesPath] to the user in a dialog box
  /// 
  /// It fetches the [quesPath] from the server, creates a [VideoPlayer] and shows it in a dialog
  showQuestion(String quesPath) async {
    String fileName = quesPath.substring(quesPath.lastIndexOf("/") + 1);
    print("http://$serverIP:$serverPort/downloadFile/$fileName");
    VideoPlayerController quesController = VideoPlayerController.network(
        "http://$serverIP:$serverPort/downloadFile/$fileName");
    Future<void> quesInit = quesController.initialize();
    print("initialised");
    // TODO future builder video player is not working in dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: quesInit,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the VideoPlayer.
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(quesController),
                  );
                } else {
                  print("connection state is not connected");
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        });
  }

  /// Generates the layout for the video/answers [list]
  /// 
  /// Corresponding to each question a card is generated with following struture
  /// ```html
  /// <html>
  /// <table>
  /// <tr><th>question<th><tr>
  /// <tr><td>Person name</td></tr>
  /// <tr><td>Answer 1</td></tr>
  /// <tr><td></td></tr>
  /// <tr><td>Person name 2</td></tr>
  /// <tr><td>Answer 2</td></tr>
  /// <tr><td></td></tr>
  /// <tr><th>question<th><tr>
  /// <tr><td>Person name</td></tr>
  /// <tr><td>Answer 1</td></tr>
  /// <tr><td></td></tr>
  /// <tr><td>Person name 2</td></tr>
  /// <tr><td>Answer 2</td></tr>
  /// <tr><td></td></tr>
  /// <tabe>
  /// </html>
  /// ```
  List<Widget> getVideos() {
    List<Widget> listArray = List<Widget>();
    if (list != null) {
      if (list.length != 0) {
        for (int i = 0; i < list.length; i++) {
          // if (list[i].length == 1) {
          //   listArray.add(Padding(
          //       padding: EdgeInsets.all(15.0),
          //       child: Card(
          //           child: Text(
          //               "q $i No Answer Available for this question yet"))));
          // } else {
          List<Widget> answers = [];
          answers.add(ChewieListItemNet(
              url:
                  "http://$serverIP:$serverPort/downloadFile/${list[i][0].toString().substring(list[i][0].toString().lastIndexOf("/") + 1)}",
              key: UniqueKey()));
          for (int j = 1; j < list[i].length; j++) {
            print("$i $j");
            Widget nameWidget = GestureDetector(
              child: Text((names[i])[j]["Name"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewPage(email: names[i][j]["Email"])),
                );
              },
            );
            VideoPlayerController _controller = VideoPlayerController.network(
                "http://$serverIP:$serverPort/downloadAnswer/" +
                    list[i][j]
                        .substring(list[i][j].toString().lastIndexOf("/") + 1));
            Future<void> _initializeVideoPlayerFuture =
                _controller.initialize().then((value) {
              _controller.play();
            });

            Widget vidPlayer = FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the VideoPlayer.
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  );
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
            // Widget vPlayer = new ChewieListItemNet(
            //   url: "http://$serverIP:$serverPort/downloadAnswer/" +
            //       list[i][j]
            //           .toString()
            //           .substring(list[i][j].toString().lastIndexOf("/") + 1),
            //   key: UniqueKey(),
            // );
            answers.add(Column(
              children: <Widget>[nameWidget, vidPlayer],
            ));
          }
          Widget toAdd = Padding(
              padding: EdgeInsets.all(15.0),
              child: Card(
                //color: Color.fromARGB(255, 76, 175, 80),
                elevation: 5.0,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      child: Text(
                        "Question $i",
                        style: TextStyle(
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () async {
                        await showQuestion(list[i][0]);
                      },
                    ),
                    Column(
                      children: answers,
                    ),
                  ],
                ),
              ));
          listArray.add(toAdd);
        }
      } else {
        listArray.add(
            Center(child: Text("Sorry, No answers to your questions yet!")));
      }
    } else {
      listArray
          .add(Center(child: Text("Sorry, No answers to your questions yet!")));
    }
    return listArray;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: NavDrawer(),
        appBar: new AppBar(
          title: new Text("Video Question App"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: getVideos(),
          ),
        ));
  }
}
