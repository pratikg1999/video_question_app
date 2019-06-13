import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teacher/ask.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'package:location/location.dart';
import 'constants.dart';
import 'checkBoxList.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SignUpState();
  }
}

class SignUpState extends State<SignUp> {
  final GlobalKey<ScaffoldState> _signupScaffoldKey = new GlobalKey();

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
        key: _signupScaffoldKey,
        body: Builder(
            // Create an inner BuildContext so that the onPressed methods
            // can refer to the Scaffold with Scaffold.of().
            builder: (BuildContext context) {
          return Card(
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
                              onPressed: () async {
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
          ));
        }));
  }

  void addStudent() async {
    if (formkey.currentState.validate()) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(
              child: AlertDialog(
                //decoration: BoxDecoration(color: Color.fromRGBO(30, 30, 30, 1)),
                content: Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Creating new user",
                          style: TextStyle(
                            height: 1.0,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
      formkey.currentState.save();


//      var resData = await response.stream.bytesToString();
//      var resDataJson = jsonDecode(resData);


//        saveCurrentLogin(resDataJson["Token Id"]);
//        saveInSP(EMAIL_KEY_SP, _email);
//        saveInSP(USER_NAME_SP, resDataJson["Name"]);
        Navigator.push(context, MaterialPageRoute(builder: (context){
            return CheckBox(
                name: _name,
                phone: _phone,
                age:_age,
                email:_email,
                password:_password

            );
        }));


    } else {
      _signupScaffoldKey.currentState.showSnackBar(
          new SnackBar(content: Text("Unable to create user..try again")));
      print("INVALID");
    }
  }
}
