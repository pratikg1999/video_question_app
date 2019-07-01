import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';

/// Interests page to select the interest fields of a user.
/// 
/// The user will be displayed a list of interesets.
/// He can check one or more item that interests him.
/// After saving a new Sign-up request is sent to the Server with all the details of the user and new account is created.
class Interests extends StatefulWidget {
  final String name,email,phone,password;
  final int age;

  Interests({
    this.age,
    this.name,
    this.password,
    this.email,
    this.phone
});

  @override
  InterestsState createState() => new InterestsState();
}


/// The UI for the Interests Page.
class InterestsState extends State<Interests> {
  Map<String, bool> values = {
    'Society & Culture': false,
    'Science & Mathematics': false,
    'Health' : false,
    'Education & Reference' : false,
    'Computers & Internet':false,
    'Sports':false,
    'Business & Finance':false,
    'Hobbies':false,
    'Families & Relationships':false,
    'Politics & Government':false,
  };

  /// Key for the [Scaffold] of this.
  final GlobalKey<ScaffoldState> _signupScaffoldKey = new GlobalKey();

  /// The list of choices that the user fills.
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


  /// Saves the interests entered by user in the [list] and sends sign-up request to the server with all his details.
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
    print(uri.toString());
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
    print(request.toString());
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
