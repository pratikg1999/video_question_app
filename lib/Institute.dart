import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class Institute extends StatefulWidget{
  @override
  State<Institute> createState() {
    return InstituteState();
  }
}

class InstituteState extends State<Institute>{

  String _name;
  String _address;
  String _phone;
  String _password;
  final _passwordConroller = TextEditingController();
  bool _emailValid;
  String _email;
  final formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _signupScaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _signupScaffoldKey,
        appBar: AppBar(
          title: new Text('Sign Up'),
        ),
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
                                decoration: InputDecoration(labelText: 'Name Of Institute:'),
                                validator: (input) {

                                },
                                onSaved: (input) => _name = input,
                              ),
                              TextFormField(
                                minLines: 1,
                                maxLines: 10,
                                decoration: InputDecoration(
                                  labelText: 'Address',),
                                validator: (input) {
                                },
                                onSaved: (input) => _address = input,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'E-mail:', hintText: "you@example.com"),
                                keyboardType: TextInputType.emailAddress,
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
                                decoration: InputDecoration(labelText: 'Phone:',
                                    hintText: "12xxxx78"
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (input) => _phone = input,
                              ),
                              TextFormField(
                                controller: _passwordConroller,
                                decoration: InputDecoration(
                                    labelText: 'Password:', hintText: "password"),
                                validator: (input) => input.length < 8
                                    ? 'Password must be atleast 8 char long'
                                    : null,
                                onSaved: (input) => _password = input,
                                obscureText: true,
                              ),
                              Builder(builder: (BuildContext context) {
                                return TextFormField(
                                  // controller: _verifyPasswordController,
                                  decoration:
                                  InputDecoration(
                                    labelText: "Verify Password",
                                    // errorText: _verifyPasswordController.text == _passwordConroller.text ? null: "Passwords don't match",
                                  ),
                                  validator: (input) => input == _passwordConroller.text
                                      ? null
                                      : "Passwords don't match",
                                  obscureText: true,
                                );
                              }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      onPressed: () async {
                                        await addInstitute();

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

 addInstitute() async{
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
    formkey.currentState.save();
    var uri = new Uri.http("$serverIP:$serverPort", "/institute/create");
    var request = new http.MultipartRequest("POST", uri);
    request.fields["name"] = _name;
    request.fields["phone"] = _phone;
    request.fields["email"] = _email;
    request.fields["address"] = _address;
    request.fields["password"] = _password;

    var response = await request.send();
    print(response.toString());
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