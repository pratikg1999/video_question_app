import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/shared_preferences_helpers.dart';
import 'constants.dart';
import "dart:convert";
class Questions extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return QuestionsState();
  }
}

class QuestionsState extends State<StatefulWidget>{

  String data = "fetching";


  void init() async {
    var uri = new Uri.http("${serverIP}:${serverPort}", "/videos");
    String tokenId = await getCurrentTokenId();
    var request = http.MultipartRequest("GET", uri);
    request.fields["tokenId"] = tokenId;
    request.send().then((response) async {
      data = await response.stream.bytesToString();
      var videos = jsonDecode(data);
//      print(ok[0]["path"]);
//      print(ok);
//      for(var v in videos){
//        request = http.MultipartRequest(method, url)
//      }
      setState((){});
    });
  }

  @override
  void initState() {
    init();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Video Question App"),
        ),
        body: new Container(
            child: new Center(
              child: new Text(data),
            )
        )
    );
  }
}
