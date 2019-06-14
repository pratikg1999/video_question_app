import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:teacher/SignUpPage.dart';
import 'package:teacher/shared_preferences_helpers.dart';
import 'package:teacher/ask.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<int> logOut() async {
  String tokenId = await getCurrentTokenId();
  print("token is $tokenId");
  String email = await getFromSP(EMAIL_KEY_SP);
  print("email is $email");
  var logoutUri = Uri.http("${serverIP}:${serverPort}", "/logOut");
  http.MultipartRequest request = http.MultipartRequest("POST", logoutUri);
  request.fields["tokenId"] = tokenId;
  request.fields["email"] = email;
  var response = await request.send();
  if (response.statusCode == 200) {
    print("successfully logged out");
    removeKeyFromSP(EMAIL_KEY_SP);
    removeKeyFromSP(TOKEN_KEY_SP);
    print("keys removed");
  } else {
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
  final GlobalKey<ScaffoldState> _loginScaffoldKey = new GlobalKey();
  bool isPasswordValid = true;
  bool isEmailValid = true;
  static String _email = "", _password = "";
  final _emailController = TextEditingController(text: _email);
  final _passwordController = TextEditingController(text: _password);

  Widget snackbarEmailVerification(String errText) {
    return SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Text(errText),
          RaisedButton(
              child: Text("Resend verification code"),
              color: Colors.blue,
              onPressed: () async {
                var uri = new Uri.http(
                    "${serverIP}:${serverPort}", "/sendVerificationMail");
                var request = new http.MultipartRequest("POST", uri);
                request.fields['email'] = _email;
                var response = await request.send();
                if (response.statusCode == 200) {
                  Fluttertoast.showToast(
                    msg: 'Email successfully sent',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: 'Error sending mail',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              })
        ],
      ),
    );
  }

  void checkSignInStatus() async {
    print(await isKeyPresentInSP(TOKEN_KEY_SP));
    print(await isKeyPresentInSP(EMAIL_KEY_SP));
    print(await getFromSP(TOKEN_KEY_SP));
    if (await isKeyPresentInSP(TOKEN_KEY_SP) &&
        await isKeyPresentInSP(EMAIL_KEY_SP)) {
      USER_NAME = await getFromSP(USER_NAME_SP);
      EMAIL = await getFromSP(EMAIL_KEY_SP);
      print("already signed in");
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/ask', (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    isEmailValid = true;
    isPasswordValid = true;
    checkSignInStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();

//    final _passwordController = TextEditingController();

    _submit() async {
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
        if (response.statusCode == 200) {
          var resData = await response.stream.bytesToString();
          var resDataJson = jsonDecode(resData.toString());
          print("User Logged In");
          saveCurrentLogin(resDataJson['Token Id']);
          saveInSP(EMAIL_KEY_SP, _email);
          saveInSP(USER_NAME_SP, resDataJson["Name"]);
          USER_NAME = resDataJson["Name"];
          EMAIL = _email;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/ask', (Route<dynamic> route) => false);
        } else {
          var error = await response.stream.bytesToString();
          print(error);
          var errorJson = jsonDecode(error.toString());
          switch (errorJson["message"]) {
            case ERROR_ALREADY_SIGNED_IN:
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AlertDialog(content: Text("User is already signed in other device"),),
                      ],
                    ));
                  });
              break;
            case ERROR_EMAIL_NOT_PRESENT:
              setState(() {
                print("Email is not registered");
                isEmailValid = false;
              });
              break;
            case ERROR_INCORRECT_PASSWORD:
              setState(() {
                print("incorrect password");
                isPasswordValid = false;
              });

              break;
            case ERROR_EMAIL_NOT_VERIFIED:
              _loginScaffoldKey.currentState.showSnackBar(
                  snackbarEmailVerification("Email not verified"));
              break;
          }
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
        FocusScope.of(context)
            .requestFocus(new FocusNode()); //to hide the on screen keyboard
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
                  controller: _emailController,
                  onSaved: (val) => _email = val,
                  validator: (val) {
                    if (val.isEmpty) {
                      return "Email is necessary";
                    }
                  },
                  decoration: new InputDecoration(
                    labelText: "Email",
                    hintText: "you@example.com",
                    errorText: isEmailValid ? null : "Email not registered",
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextFormField(
                  controller: _passwordController,
                  onSaved: (val) => _password = val,
                  validator: (val) {
                    if (val.isEmpty) {
                      return "Please enter password";
                    }
                  },
                  obscureText: true,
//                  controller: _passwordController,
                  decoration: new InputDecoration(
                      labelText: "Password",
                      hintText: "password",
                      errorText: isPasswordValid ? null : "Incorrect password"),
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
      key: _loginScaffoldKey,
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
              child: SingleChildScrollView(
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
      ),
    );
  }
}
