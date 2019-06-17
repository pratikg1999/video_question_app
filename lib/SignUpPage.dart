import 'package:flutter/material.dart';
import 'checkBoxList.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SignUpState();
  }
}

class SignUpState extends State<SignUp> {
  final GlobalKey<ScaffoldState> _signupScaffoldKey = new GlobalKey();
  // final bloc = Bloc();
  final formkey = GlobalKey<FormState>();
  String _email, _password, _name;
  final _passwordConroller = TextEditingController();
  // final _verifyPasswordController = TextEditingController();
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
                                decoration: InputDecoration(
                                    labelText: 'Phone:', hintText: "12xxxx78"),
                                keyboardType: TextInputType.number,
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
                                keyboardType: TextInputType.number,
                                onSaved: (input) => _age = int.parse(input),
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
      formkey.currentState.save();

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