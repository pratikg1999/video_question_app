import 'package:flutter/material.dart';
import 'package:teacher/SignUpPage.dart';
import 'package:teacher/LoginPage.dart';
import 'package:teacher/answers.dart';
import 'package:teacher/questions.dart';

import 'ask.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Question App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String,WidgetBuilder>{
        '/SignUp' : (context) => new SignUp(),
        '/answers' : (context) => new Answers(),
        '/questions' : (context) => new Questions(),
        '/login': (context) => LoginPage(),
        '/ask': (context) => Ask(),
      },
      home: LoginPage(title: 'Video Question App'),

    );
  }
}


