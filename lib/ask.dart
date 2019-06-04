import 'package:flutter/material.dart';
import 'package:teacher/video.dart';
import 'package:teacher/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/shared_preferences_helpers.dart';



class Ask extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new AskState();
  }
}

class AskState extends State<Ask> {
  String _name;
  String _email;
  void getNameAndEmail() async {
    _email = await getFromSP(EMAIL_KEY_SP);
    _name = await getFromSP(USER_NAME_SP);
    setState(() {

    });
  }


  @override
  void initState() {
    getNameAndEmail();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Video Question App"),
        ),
        drawer : NavDrawer(userName:_name,email:_email),
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