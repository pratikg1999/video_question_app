import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'drawer.dart';
import 'constants.dart';
=======
>>>>>>> 9559d369435e9deaf1b424cdbc936604a961f125

class Answers extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AnswersState();
  }
}

class AnswersState extends State<StatefulWidget>{
  Widget build(BuildContext context){
    return new Scaffold(
<<<<<<< HEAD
      drawer: NavDrawer(email: EMAIL, userName: USER_NAME,),
=======
>>>>>>> 9559d369435e9deaf1b424cdbc936604a961f125
        appBar: new AppBar(
            title: new Text("Video Question App"),
        ),
        body: new Container(
            child: new Center(
               child: new Text('This is the answers page'),
            )
        )
<<<<<<< HEAD
        
=======
>>>>>>> 9559d369435e9deaf1b424cdbc936604a961f125
    );
  }
}
