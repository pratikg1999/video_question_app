import 'package:flutter/material.dart';

class Questions extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return QuestionsState();
  }
}

class QuestionsState extends State<StatefulWidget>{
  Widget build(BuildContext context){
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Video Question App"),
        ),
        body: new Container(
            child: new Center(
              child: new Text('This is the questions page'),
            )
        )
    );
  }
}
