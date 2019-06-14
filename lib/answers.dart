import 'package:flutter/material.dart';
import 'drawer.dart';
import 'constants.dart';

class Answers extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AnswersState();
  }
}

class AnswersState extends State<StatefulWidget>{
  Widget build(BuildContext context){
    return new Scaffold(
      drawer: NavDrawer(email: EMAIL, userName: USER_NAME,),
        appBar: new AppBar(
            title: new Text("Video Question App"),
        ),
        body: new Container(
            child: new Center(
               child: new Text('This is the answers page'),
            )
        )
        
    );
  }
}