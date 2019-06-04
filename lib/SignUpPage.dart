import 'package:flutter/material.dart';
import 'package:teacher/ask.dart';
import 'package:http_parser/http_parser.dart' as http;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:teacher/shared_preferences_helpers.dart';
import 'dart:io';
import 'dart:async';
import 'constants.dart';

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
                          decoration: InputDecoration(
                              labelText: 'Name:'
                          ),
                          validator: (input) {
                            if (input.length < 3) {
                              return 'Name must contain atleast three letters';
                            }
                            else {
                              return null;
                            }
                          },
                          onSaved: (input) => _name = input,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Phone:'
                          ),
                          validator: (input) {
                            if (input.length < 10) {
                              return 'Phone number is invalid';
                            }
                            else {
                              return null;
                            }
                          },
                          onSaved: (input) => _phone = input,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Age:'
                          ),

                          onSaved: (input) => _age = int.parse(input),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'E-mail:'
                          ),
                          //validator: (input) => (!input.contains('@')) ? 'Not a vaild email' : null,
                          validator: (input) {
                            _emailValid = RegExp(
                                r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(input);
                            if (_emailValid == false) {
                              return 'Not a vaild email';
                            }
                            else {
                              return null;
                            }
                          },
                          onSaved: (input) => _email = input,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Password:'
                          ),
                          validator: (input) =>
                          input.length < 8
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
                  )
              ),
            )
        )
    );
  }

  void addStudent() async {

    if(formkey.currentState.validate()) {
      formkey.currentState.save();

    var uri = new Uri.http("${serverIP}:${serverPort}", "/signup");

    var request = new http.MultipartRequest("POST", uri);


    request.fields['name'] = _name;
    request.fields['phone'] = _phone;
    request.fields['age'] =_age.toString();
    request.fields['email'] = _email;
    request.fields['password']=_password;

    request.send().then((response) async{

      var t = await response.stream.bytesToString();
      var token = jsonDecode(t);


      if(response.statusCode == 200) {
        print("Registered");
        saveCurrentLogin(token["Token Id"]);
      };

    }).catchError(( e){
      print(e);
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Ask()),
    );

    }else{

      print("INVALID");

    }
  }

}
