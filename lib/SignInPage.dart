import 'package:flutter/material.dart';
import 'package:teacher/ask.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formkey = GlobalKey<FormState>();
  String _email,_password;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: new Text('Sign In'),
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
                              labelText: 'E-mail:'
                          ),
                          //validator: (input) => (!input.contains('@')) ? 'Not a vaild email' : null,
                          //onSaved: (input) => _email=input,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Password:'
                          ),
                         // onSaved: (input) => _password=input,
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


}
