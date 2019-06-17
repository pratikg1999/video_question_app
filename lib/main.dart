import 'package:flutter/material.dart';
import 'package:video_question_app/SignUpPage.dart';
import 'package:video_question_app/LoginPage.dart';
import 'package:video_question_app/answers.dart';
import 'package:video_question_app/profile_page.dart';
import 'package:video_question_app/NotUploadedQuestions.dart';
import 'questionsAskedToMe.dart';
import 'ask.dart';
import 'UploadedQuestions.dart';
import 'checkBoxList.dart';
import 'storeJson.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //deleteFile("henilj1999@gmail.com");
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
        '/profile': (context) => ProfilePage(),
        '/questionsAsked': (context) => QuestionsAsked(),
      },
      home: LoginPage(title: 'Video Question App'),

    );
  }
}
