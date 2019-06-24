import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'drawer.dart';
import 'constants.dart';
import 'dart:core';
import 'chewieListNetwork.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shared_preferences_helpers.dart';
import 'package:teacher/shared_preferences_helpers.dart';

/// The page where the user can see all the answers that he answered.
class Answers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AnswersState();
  }
}

/// Builds the state associated with [Answers]
class AnswersState extends State<StatefulWidget> {

  /// The list of names of the answered videos.
  List list;

  /// Sets the initial values for the state variables.
  ///
  /// * token is the unique session id associated with every logged in user.
  /// * response is the variable used to store the response of the http request.
  Future<void> setter() async {
    var token = await getCurrentTokenId();

    var response = await http.get(
        Uri.encodeFull(
            "http://$serverIP:$serverPort/getAnswersList?tokenId=$token"),
        headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      final map = jsonDecode(response.body);
      setState(() {
        list = map;
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
    setter();
  }


  ///Returns the list of [ChewieListItemNet] widget.
  List<Widget> getVideos() {
    List<Widget> listArray = List<Widget>();
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        listArray.add(new ChewieListItemNet(
          url: "http://$serverIP:$serverPort/downloadAnswer/" +
              list[i]
                  .toString()
                  .substring(list[i].toString().lastIndexOf("/") + 1),
          key: UniqueKey(),
        ));
      }
    } else {
      listArray.add(Center(child: Text("No answers given")));
    }
    return listArray;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: NavDrawer(),
      appBar: new AppBar(
        title: new Text("Video Question App"),
      ),
      body: Column(
        children: getVideos(),
      ),
    );
  }
}
