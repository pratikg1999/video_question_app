import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';


class CheckBox extends StatefulWidget {
  String name,email,phone,password;
  int age;

  CheckBox({
    this.age,
    this.name,
    this.password,
    this.email,
    this.phone
});

  @override
  CheckBoxState createState() => new CheckBoxState();
}

class CheckBoxState extends State<CheckBox> {
  Map<String, bool> values = {
    'Politics': false,
    'Sports': false,
    'Machines' : false,
    'Music' : false,
    'Technology':false,
    'Career':false,
    'Job Interview':false,
    'Current Events':false,
    'Reasoning':false,
    'Workout':false,
    'Personality Developmen':false,
    'Communication Skills':false,
    'Fashion':false,
    'Life':false,
    'Education':false,
    'Travelling':false,
    'Relationships':false,
    'Medical Science':false,
    'Commerce':false,
    'Engineering':false,
  };

  final GlobalKey<ScaffoldState> _signupScaffoldKey = new GlobalKey();

  List<String> list = new List<String>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _signupScaffoldKey,
      appBar: new AppBar(
        title: new Text('Select topics'),
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
      ), /*,
         new RaisedButton(
           child: Text('Done'),
             onPressed: (){
               Navigator.of(context)
                   .pushNamedAndRemoveUntil('/ask', (Route<dynamic> route) => false);
             }
         )*/
    );
  }

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

  void send() async {
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
                        "Creating new user",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]));
        });
    var uri = new Uri.http("$serverIP:$serverPort", "/signup");

    var request = new http.MultipartRequest("POST", uri);

    Map<String, double> currentLocation = new Map();
    Location location = new Location();
    currentLocation = await location.getLocation();

    request.fields['name'] = widget.name;
    request.fields['phone'] = widget.phone;
    request.fields['age'] = widget.age.toString();
    request.fields['email'] = widget.email;
    request.fields['password'] = widget.password;
    request.fields['latitude'] = currentLocation["latitude"].toString();
    request.fields['longitude'] = currentLocation["longitude"].toString();
    int index = 0;
    for (var l in list) {
      request.fields['interests[' + index.toString() + ']'] = l;
      index++;
    }

    print(request.fields.toString());

    var response = await request.send();

    if (response.statusCode == 200) {
      print("Registered");
      Navigator.pop(context);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      Fluttertoast.showToast(
        msg: 'Verification link has been sent',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Navigator.pop(context);
      print("hhhhhhhhhhhhhhhhhhhhhhhh");

      var error = await response.stream.bytesToString();
      print(error);
      var errorJson = jsonDecode(error.toString());
      switch (errorJson["message"]) {
        case ERROR_USER_ALREADY_EXISTS:
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Signup failed"),
                    content: Text("User with this email already exists"));
              });
          break;
        default:
          _signupScaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Some error occured..try again")));
      }
    }
  }
}
