import "package:flutter/material.dart";
import 'package:teacher/constants.dart';
import 'package:teacher/drawer.dart';
import 'package:teacher/shared_preferences_helpers.dart';

class ProfilePage extends StatefulWidget {
  ProfilePageState createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(email: EMAIL, userName: USER_NAME),
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: ProfilePageBody());
  }

  Widget ProfilePageBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[header(),],
      ),
    );
  }

  Widget header() {
    return Stack(
      children: <Widget>[
        bottomMostWidget(),
        Positioned(
          
          child: Center(child: circularImage()),
        )
      ],
    );
  }

  Widget circularImage() {
    return Card(
      elevation: 8.0,
      child: Container(
          width: 100.0,
          height: 100.0,
          decoration: new BoxDecoration(
            // border:   Border.all(color: Colors.white),
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new AssetImage("assets/images/profile_pic.jpg")))),
    );
  }

  Widget bottomMostWidget() {
    return Column(
      children: <Widget>[
        Image.asset("assets/images/login_background.jpg"),
        Padding(
          padding: EdgeInsets.only(top: 2.0),
        ),
        Container(
          child: Text("Pratik Gupta"),
        ),
      ],
    );
  }
}
