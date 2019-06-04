import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:teacher/SignUpPage.dart';
import 'package:teacher/shared_preferences_helpers.dart';
import 'package:teacher/ask.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

Future<int> logOut() async {
  String tokenId = await getCurrentTokenId();
  String email = await getFromSP(EMAIL_KEY_SP);
  var logoutUri = Uri.http("${serverIP}:${serverPort}", "/logout");
  http.MultipartRequest request = http.MultipartRequest("POST", logoutUri);
  request.fields["tokenId"] = tokenId;
  request.fields["email"] = email;
  var response = await request.send();
  if (response.statusCode == 200) {
    print("successfully logged out");
    removeKeyFromSP(EMAIL_KEY_SP);
    removeKeyFromSP(TOKEN_KEY_SP);
    print("keys removed");
  }
  else{
    print("in logOut: unsucessfull logout");
  }
  return response.statusCode;
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() async {
    if(await isKeyPresentInSP(TOKEN_KEY_SP) && await isKeyPresentInSP(EMAIL_KEY_SP)){
      print("already signed in");
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/ask', (Route<dynamic> route) => false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();
    String _email, _password;

    _submit() async{
      if (formkey.currentState.validate()) {
        formkey.currentState.save();

        var uri = new Uri.http("${serverIP}:${serverPort}", "/login");

        var request = new http.MultipartRequest("POST", uri);

        request.fields['email'] = _email;
        request.fields['password'] = _password;
        print(request);
        print(_email);
        print(_password);
        var response = await request.send();
          var t = await response.stream.bytesToString();
          var token = jsonDecode(t.toString());
          if (response.statusCode == 200) {
            print("User Logged In");
            saveCurrentLogin(token['Token Id']);
            saveInSP(EMAIL_KEY_SP, _email);
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/ask', (Route<dynamic> route) => false);
          }

//        Navigator.of(context).pop();
//        Navigator.of(context).pop();
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => Ask()),
//        );
      } else {
        print("INVALID");
      }
    }

    var loginBtn = new RaisedButton(
      onPressed: () {
        _submit();
      },
      child: new Text("LOGIN"),
      color: Colors.primaries[3],
    );
    var registerBtn = new FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUp()),
          );
        },
        child: new Text("Create a new account"));
    var loginForm = new Column(
      children: <Widget>[
        new Form(
          key: formkey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextFormField(
                  onSaved: (val) => _email = val,
                  validator: (val) {},
                  decoration: new InputDecoration(labelText: "Email"),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextFormField(
                  onSaved: (val) => _password = val,
                  decoration: new InputDecoration(labelText: "Password"),
                ),
              ),
              loginBtn,
              registerBtn,
            ],
          ),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Video Question App"),
      ),
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("assets/images/login_background.jpg"),
              fit: BoxFit.cover),
        ),
        child: new Center(
          child: new ClipRect(
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                child: loginForm,
                height: 300.0,
                width: 300.0,
                decoration: new BoxDecoration(
                    color: Colors.grey.shade200.withOpacity(0.5)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
