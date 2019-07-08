import 'package:flutter/material.dart';
import 'package:teacher/shared_preferences_helpers.dart';
import 'package:teacher/video.dart';
import 'package:teacher/drawer.dart';
import 'constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'viewProfile.dart';

/// Builds the Ask page.
class Ask extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new AskState();
  }
}


/// Builds the state associated with the Ask page.
class AskState extends State<Ask> {

  ///[_name] used to set the name in the drawer.
  String _name;

  ///[_email] used to set the email in the drawer.
  String _email;

  String load;

  /// Retrieves the name and email of current user from shared preferences.
  void getNameAndEmail() async {
    _email = EMAIL;
    _name = await getFromSP(USER_NAME_SP);
    load = await getFromSP(LOADING_KEY_SP);
    setState(() {

    });
  }


  @override
  void initState() {
    getNameAndEmail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget temp;
    print("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
    print(load);
    if(load == "true"){
      temp = new Row(
        children: <Widget>[
          new Text("Video Question App    "),
          SpinKitRing(color: Colors.white, lineWidth: 2.0,)
        ],
      );
    }
    else{
      temp = new Text("Video Question App ");
    }


    return new Scaffold(
        appBar: new AppBar(
          title: temp,
        ),
        drawer : NavDrawer(),
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
                        MaterialPageRoute(builder: (context) => VideoRecorderApp()),
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