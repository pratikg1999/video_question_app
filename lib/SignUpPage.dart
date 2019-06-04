import 'package:flutter/material.dart';
import 'package:teacher/ask.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:teacher/shared_preferences_helpers.dart';
import 'dart:io';
import 'dart:async';
import 'constants.dart';
import 'package:location/location.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SignUpState();
  }
}

class SignUpState extends State<SignUp> {
  final formkey = GlobalKey<FormState>();
  String _email, _password, _name;
  int _age;
  String _phone;
  bool _emailValid;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: new Text('Sign Up'),
        ),
        body: Card(
            child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name:'),
                      validator: (input) {
                        if (input.length < 3) {
                          return 'Name must contain atleast three letters';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (input) => _name = input,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Phone:'),
                      validator: (input) {
                        if (input.length < 10) {
                          return 'Phone number is invalid';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (input) => _phone = input,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Age:'),
                      onSaved: (input) => _age = int.parse(input),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'E-mail:'),
                      //validator: (input) => (!input.contains('@')) ? 'Not a vaild email' : null,
                      validator: (input) {
                        _emailValid =
                            RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(input);
                        if (_emailValid == false) {
                          return 'Not a vaild email';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (input) => _email = input,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password:'),
                      validator: (input) => input.length < 8
                          ? 'Password must be atleast 8 char long'
                          : null,
                      onSaved: (input) => _password = input,
                      obscureText: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            onPressed: () {
                              addStudent();
                            },
                            child: Text('Submit'),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )),
        )));
  }

  void addStudent() async {
    if (formkey.currentState.validate()) {
      formkey.currentState.save();

      var uri = new Uri.http("${serverIP}:${serverPort}", "/signup");

      var request = new http.MultipartRequest("POST", uri);

      Map<String, double> currentLocation = new Map();
      Location location = new Location();
      currentLocation = await location.getLocation();

      request.fields['name'] = _name;
      request.fields['phone'] = _phone;
      request.fields['age'] = _age.toString();
      request.fields['email'] = _email;
      request.fields['password'] = _password;
      request.fields['latitude'] = currentLocation["latitude"].toString();
      request.fields['longitude'] = currentLocation["longitude"].toString();

      print(request.fields.toString());

      var response = await request.send();

      var resData = await response.stream.bytesToString();
      var resDataJson = jsonDecode(resData);

      if (response.statusCode == 200) {
        print("Registered");
        saveCurrentLogin(resDataJson["Token Id"]);
        saveInSP(EMAIL_KEY_SP, _email);
        saveInSP(USER_NAME_SP, resDataJson["Name"]);
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/ask', (Route<dynamic> route) => false);
      }
    } else {
      print("INVALID");
    }
  }
}
