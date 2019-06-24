import 'package:flutter/material.dart';
import 'package:teacher/SignUpPage.dart';
import 'package:teacher/LoginPage.dart';
import 'package:teacher/answers.dart';
import 'edit_profile_page.dart';
import 'questionsAskedToMe.dart';
import 'ask.dart';
import 'package:teacher/interestsList.dart';
import 'answerToMyQuestion.dart';
import 'NotUploadedQuestions.dart';
import 'UploadedQuestions.dart';
import 'viewProfile.dart';
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
        '/checkBox' : (context) => Interests(),
        '/profile': (context) => ProfilePage(),
        '/questionsAsked': (context) => QuestionsAsked(),
        '/answersPage' : (context) => AnswersOfMyQuestion(),
        '/view' : (context) => ViewPage(),
      },
      home: LoginPage(title: 'Video Question App'),

    );
  }
}
