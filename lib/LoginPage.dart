
import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path/path.dart' hide context;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:teacher/SignUpPage.dart';
import 'shared_preferences_helpers.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Institute.dart';

/// Logs out the currently logged in user.
/// 
/// Sends a request to the API(server) to logout and 
/// returns the response code received from the server
Future<int> logOut() async {
  String tokenId = await getCurrentTokenId();
  print("token is $tokenId");
  String email = await getFromSP(EMAIL_KEY_SP);
  print("email is $email");
  var logoutUri = Uri.http("$serverIP:$serverPort", "/logOut");
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


/// The login page 
/// 
/// This is the default page of the app.
class LoginPage extends StatefulWidget {
  /// Creates a login page with the User's [title]
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}


/// The UI of the login page
class _LoginPageState extends State<LoginPage> {
  var _documentDir;

  /// Global key for the scaffold in this page
  final GlobalKey<ScaffoldState> _loginScaffoldKey = new GlobalKey();

  /// State variable telling the validity of the password entered.
  /// 
  /// User can only loggin if this property is true.
  bool isPasswordValid = true;

  /// State variable telling the validity of the password entered.
  /// 
  /// User can only loggin if this property is true.
  bool isEmailValid = true;
  static String _email = "", _password = "";

  /// [TextEditingController] for email field
  final _emailController = TextEditingController(text: _email);

  /// [TextEditingController] for password field  
  final _passwordController = TextEditingController(text: _password);


  /// Creates a snackbar that shows [errText] to the user.
  /// 
  /// Used to generate snackbar when the user's email is not verified.
  /// The [errText] is the message displayed in the snackbar
  /// The returned snackbar also contains a button to resend verification mail.
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
                _loginScaffoldKey.currentState.hideCurrentSnackBar();
                var uri = new Uri.http(
                    "$serverIP:$serverPort", "/sendVerificationMail");
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


  /// Checks whether a user is already signed in the app
  /// 
  /// Automatically gets called when the app starts.
  /// If the user is logged in, it takes the user to the [Ask] page.
  void checkSignInStatus() async {
    print(await isKeyPresentInSP(TOKEN_KEY_SP));
    print(await isKeyPresentInSP(EMAIL_KEY_SP));
    print(await getFromSP(TOKEN_KEY_SP));
    if (await isKeyPresentInSP(TOKEN_KEY_SP) &&
        await isKeyPresentInSP(EMAIL_KEY_SP)) {
      USER_NAME = await getFromSP(USER_NAME_SP);
      EMAIL = await getFromSP(EMAIL_KEY_SP);
      print("already signed in");
      Navigator.of(this.context) // TODO remove as BuildContext if error
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


  /// Downloads the [imageName] from the server which is a profile picture.
  Future downloadImage(imageName) async {
    print("downloading pic");
    var response = await http
        .get(Uri.http("$serverIP:$serverPort", "/getProfilePic/$imageName"));
    print(response.statusCode);
    _documentDir = await getApplicationDocumentsDirectory();
    File file = new File(join(_documentDir.path, 'profile_pic.png'));
    file.writeAsBytesSync(response.bodyBytes);
    print("pic downloaded");
  }

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();

//    final _passwordController = TextEditingController();

    /// Submits this form to the user and logs in the user if all details are valid and email is verified
    /// 
    /// Takes user to the [Ask] screen if successfully logged in.
    /// All fields need to filled to continue logging in.
    /// Shows **Email not verified** snackbar if the user's email is not verified.
    _submit() async {



      if (formkey.currentState.validate()) {
        formkey.currentState.save();

        var uri = new Uri.http("$serverIP:$serverPort", "/login");

        var request = new http.MultipartRequest("POST", uri);

        request.fields['email'] = _email;
        request.fields['password'] = _password;
        print(request);
        print(_email);
        print(_password);
        // print("headers: ${request.headers}");
        var response = await request.send();
        if (response.statusCode == 200) {
          var resData = await response.stream.bytesToString();
          var resDataJson = jsonDecode(resData.toString());
          print("USER INFORMATION");
          print(resDataJson);
          print(resDataJson["Interests"].toString());
          print("User Logged In");
          saveCurrentLogin(resDataJson['Token Id']);
          saveInSP(EMAIL_KEY_SP, _email);
          saveInSP(USER_NAME_SP, resDataJson["Name"]);
          await saveInSP(AGE_KEY_SP, resDataJson["Age"]);
          print(await getFromSP(AGE_KEY_SP));
          saveInSP(PHONE_KEY_SP, resDataJson["Phone"]);
          saveInSP(INTERESTS_KEY_SP, resDataJson["Interests"].toString());
          USER_NAME = resDataJson["Name"];
          EMAIL = _email;
          if (resDataJson["ProfilePic"].toString() != "null") {
            print(resDataJson["ProfilePic"]);
            String profPic = resDataJson["ProfilePic"].toString();
            await downloadImage(
                profPic.substring(profPic.lastIndexOf("/") + 1));
          } else {
            _documentDir = await getApplicationDocumentsDirectory();
            File file = new File(join(_documentDir.path, 'profile_pic.png'));
            if(file.existsSync()){
              file.deleteSync();
            }

          }
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
                        AlertDialog(
                          content:
                              Text("User is already signed in other device"),
                        ),
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

      var URI = new Uri.http("$serverIP:$serverPort", "/getType");
      var Request = new http.MultipartRequest("GET", URI);
      Request.fields["email"] = _email;
      print("REQUEST");
      print(Request.toString());
      var Response = await Request.send();
      print(Response.toString());
      if(Response.statusCode==200){
        String resData = await Response.stream.bytesToString();
        if(resData == "User")
        {
          isUser=true;
        }else{
          isUser=false;
        }
        print("TYPE------------");
        print(resData);
      }else{
        print("ËRROR");
      }




    }

    /// The submit button for the login form
    /// 
    /// Calls the [_submit()] function on tap.
    var loginBtn = new RaisedButton(
      onPressed: () {
        FocusScope.of(context)
            .requestFocus(new FocusNode()); //to hide the on screen keyboard
        _submit();
      },
      child: new Text("LOGIN"),
      color: Colors.primaries[3],
    );

    /// Button to navigate to [SignUpPage]
    /// 
    /// To be clicked if new user registration is required
    var registerBtn = new FlatButton(
        onPressed: () async {
          await _showUserTypeDialog();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => SignUp()),
          // );
        },
        child: new Text("Create a new account"));

    /// The login form with the email and password field, and login button
    var loginForm = new Column(
      children: <Widget>[
        new Form(
          key: formkey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextFormField(
                  keyboardType: TextInputType.emailAddress,
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
      body: Container(
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

  /// Shows the dialog to select the type of account to create.
  /// 
  /// The account types can be **User** or **Institute**.
  Future<void> _showUserTypeDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return
          Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AlertDialog(
                    title: new Text("Select an option"),
                    content: new Text("Are you a personal user or an institute?"),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("Personal User"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                      ),
                      new FlatButton(
                        child: new Text("Institute"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Institute()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              )
          );
      },
    );
  }
}
