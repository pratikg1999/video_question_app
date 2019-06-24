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

class Answers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AnswersState();
  }
}

class AnswersState extends State<StatefulWidget> {
  List list;
  String _name = USER_NAME;
  String _email = EMAIL;

  Future<void> setter() async {
    var token = await getCurrentTokenId();
    print(token);

    var response = await http.get(
        Uri.encodeFull(
            "http://$serverIP:$serverPort/getAnswersList?tokenId=$token"),
        headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      final map = jsonDecode(response.body);
      print(map);
      setState(() {
        list = map;
        print(list.toString());
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
