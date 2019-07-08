import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'package:teacher/shared_preferences_helpers.dart';

class editInterests extends StatefulWidget {

  @override
  editInterestsState createState() => new editInterestsState();
}

class editInterestsState extends State<editInterests> {

  ///Previous interests set by the user
  String interests;
  String email;

  List<String> l;

  Map<String, bool> values = {
    "Society & Culture": false,
    "Science & Mathematics": false,
    "Health" : false,
    "Education & Reference" : false,
    "Computers & Internet":false,
    "Sports":false,
    "Business & Finance":false,
    "Hobbies":false,
    "Families & Relationships":false,
    "Politics & Government":false,
  };

  void getInfo() async {
    interests=await getFromSP(INTERESTS_KEY_SP);
    email=await getFromSP(EMAIL_KEY_SP);
    l=interests.split(",");
    for(int i=0;i<l.length;i++)
      {
        l[i]=l[i].substring(1,l[i].length);
      }
    //l[0]=l[0].substring(1, l[0].length);
    l[l.length-1]=l[l.length-1].substring(0,l[l.length-1].length-1);
    for(int i=0;i<l.length;i++)
    {
      values[l[i]]=true;
    }
    setState(() {

    });
  }

  @override
  void initState() {
    getInfo();

    super.initState();
  }

  /// Key for the [Scaffold] of this.
  final GlobalKey<ScaffoldState> _interestScaffoldKey = new GlobalKey();

  /// The list of choices that the user fills.
  List<String> list = new List<String>();

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      key: _interestScaffoldKey,
      appBar: new AppBar(
        title: new Text('Your topics'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "Save topics to your preferences",
            onPressed: () {
              save();
            },
          )
        ],
      ),
      body: new ListView(
        children: values.keys.map((String key) {
          return new CheckboxListTile(
            title: new Text(key),
            value: values[key],
            onChanged: (bool value) {
              setState(() {
                values[key] = value;
              });
            },
          );
        }).toList(),
      ),
    );
  }


  /// Saves the interests entered by user in the [list] sends request to the server with all his interests details.
  ///
  /// Saves the list and call [send()] internally to send the request.
  void save() async {
    values.forEach((k, v) => print('$k: $v'));
    values.forEach((k, v) {
      if (v == true) {
        list.add(k);
      }
    });

    await send();

    // Navigator.pop(context);
  }

  /// Sends a sign-up request to the Server to create a new user account
  ///
  /// The request is a Multipart Http request the contains all his details in key-value pairs.
  /// If sign-up is successfull user is sent to [LoginPage].
  /// Sign-up fails if-
  /// * user with the email already exists or
  /// * Some network or server error occurs
  send() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                AlertDialog(
                  //decoration: BoxDecoration(color: Color.fromRGBO(30, 30, 30, 1)),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Editing your interests",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]));
        });
    var uri = new Uri.http("$serverIP:$serverPort", "/editInterests"); //---------needs to be created in sts
    print(uri.toString());
    var request = new http.MultipartRequest("POST", uri);

    request.fields['email'] = email;
    int index = 0;
    for (var l in list) {
      request.fields['interests[' + index.toString() + ']'] = l;
      index++;
    }

    print(request.toString());
    print(request.fields.toString());

    var response = await request.send();

    if (response.statusCode == 200) {
      saveInSP(INTERESTS_KEY_SP, list.toString());
      print("Edited interests");
      Navigator.pop(context);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      Fluttertoast.showToast(
        msg: 'Your interests are successfully updated',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Navigator.pop(context);
      print("hhhhhhhhhhhhhhhhhhhhhhhh");

      var error = await response.stream.bytesToString();
      print(error);
    }
  }
}