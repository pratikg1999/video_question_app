import 'package:flutter/material.dart';
import 'package:teacher/SignUpPage.dart';
import 'package:teacher/LoginPage.dart';
import 'package:teacher/answers.dart';
import 'package:teacher/questions.dart';
import 'questionsAskedToMe.dart';
import 'ask.dart';
import 'uploadedquestions.dart';
import 'checkBoxList.dart';
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
        '/SignUp' : (context) => SignUp(),
        '/answers' : (context) => Answers(),
        '/questions' : (context) =>Questions(),
        '/login': (context) => LoginPage(),
        '/ask': (context) => Ask(),
        '/uploadedvideo' : (context) => UploadedQuestions(),
        '/checkBox' : (context) => CheckBox(),
        '/questionsAsked': (context) => QuestionsAsked(),
      },
      home: LoginPage(title: 'Video Question App'),

    );
  }
}


