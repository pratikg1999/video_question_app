import 'package:flutter/material.dart';
import 'package:teacher/video.dart';

class Ask extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new AskState();
  }
}

class AskState extends State<Ask> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Raised Button"),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new RaisedButton(
                    padding: const EdgeInsets.all(8.0),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VideoRecorderExample()),
                      );
                    },
                    child: new Text("Ask Question"),
                  ),

                ],
              )
            ],
          ),
        ));
  }
}