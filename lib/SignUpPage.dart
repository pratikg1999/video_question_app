import 'package:flutter/material.dart';
import 'package:teacher/ask.dart';
/*import 'package:http_parser/http_parser.dart' as http;
import 'package:http/http.dart' as http;
import "dart:io";

const String serverIP = "localhost";
const String serverPort = "8080";*/

class SignUp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new SignUpState();
  }
}

class SignUpState extends State<SignUp> {
  final formkey = GlobalKey<FormState>();
  String _email,_password,_name;
  int _age;
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
                  child:Form(
                    key: formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Name:'
                          ),
                          validator: (input)
                          {
                            if(input.length < 3)
                            {
                              return 'Name must contain atleast three letters';
                            }
                            else
                            {
                              return null;
                            }
                          },
                          onSaved: (input) => _name=input,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Age:'
                          ),

                          onSaved: (input) => _age=int.parse(input),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'E-mail:'
                          ),
                          //validator: (input) => (!input.contains('@')) ? 'Not a vaild email' : null,
                          validator: (input)
                          {
                            _emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(input);
                            if(_emailValid==false)
                            {
                              return 'Not a vaild email';
                            }
                            else
                            {
                              return null;
                            }
                          },
                          onSaved: (input) => _email=input,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Password:'
                          ),
                          validator: (input) => input.length < 8 ? 'Password must be atleast 8 char long' : null,
                          onSaved: (input) => _password=input,
                          obscureText: true,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton(
                                onPressed: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Ask()),
                                  );
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


  /*sendData() async {
    var url = "${serverIP}:${serverPort}/create";
    var uri = new Uri.http('${serverIP}:${serverPort}', '/create');

    var request = new http.MultipartRequest("POST", uri);
    print("successfuly parse the url $url");
    request.fields['name'] = _name;
    request.fields['age'] = (_age).toString();
    request.fields['email'] = _email;
    request.fields['password'] = _password;

    request.send().then((response) {
      print(response.statusCode);
      print(response.toString());
      if (response.statusCode == 200) print("InfoSent!");
    });
  }
  void _submit(){
    if(formkey.currentState.validate()){
      formkey.currentState.save();
      sendData();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }*/
  }


