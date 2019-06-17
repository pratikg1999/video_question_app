import 'package:flutter/material.dart';
import 'dart:core';

class ProfilePage extends StatefulWidget{
  @override
  ProfilePageState createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage>{

  @override
  Widget build(BuildContext context){
    return new MaterialApp(
        title: "Profile Page",
        debugShowCheckedModeBanner: false,
        home: UserProfilePage(),
    );
  }
}

class UserProfilePage extends StatelessWidget{

  final String _fullName="Shweta Deosarkar";
  final String _status="Student";
  final String _bio="\"swedrftgyhujiklvcfd\"";
  final String _quesAnswered="12";
  final String _quesAsked="10";

  Widget _buildCoverImage(Size screenSize){
    return Container(
      height: screenSize.height/2.6,
      decoration: BoxDecoration(
          image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage(){
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
            image: DecorationImage(
            image: AssetImage('assets/images/foreground.jpg'),
              fit: BoxFit.cover,
            ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 20.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFullName(){
    TextStyle _nameTextStyle =TextStyle(
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );
    return Text(
      _fullName,
      style: _nameTextStyle,
    );
  }

  Widget _buildStatus(BuildContext context)
  {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 6.0
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius:BorderRadius.circular(4.0),
      ),
      child: Text(
        _status,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label,String count)
  {
    TextStyle _statLabelTextStyle= TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w200,
      fontSize: 16.0,
    );
    TextStyle _statCountStyle =TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment : MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                count,
                style: _statCountStyle,
              ),
              Text(label,
                style: _statLabelTextStyle,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatContainer(){

    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment : MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Questions Asked", _quesAsked),
          _buildStatItem("Questions Answered", _quesAnswered),
        ],
      ),
    );
  }

  Widget _buildBio(BuildContext context){
    TextStyle _bioTextStyle=TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
    );
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        _bio,
        textAlign: TextAlign.center,
        style: _bioTextStyle,
      ),
    );
  }

  Widget _buildSeparator(Size screenSize)
  {
    return Container(
      width: screenSize.width/1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  Widget _buildGetInTouch(BuildContext context){
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        "Get in touch with ${_fullName.split(" ")[0]}",
        style: TextStyle(
          fontSize: 16.0
        ),
      ),
    );
  }

  Widget _buildButtons(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: ()=>print("Asked"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Color(0xFF404A5C),
                ),
                child : Center(
                  child: Text(
                    "ASK",
                    style: TextStyle(
                      color : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            ),
          SizedBox(width: 10.0),
          Expanded(
              child: InkWell(
                onTap: ()=>print("Message"),
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Message",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildCoverImage(screenSize),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: screenSize.height/6.4,
                  ),
                  _buildProfileImage(),
                  _buildFullName(),
                  _buildStatus(context),
                  _buildStatContainer(),
                  _buildBio(context),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10.0),
                  _buildGetInTouch(context),
                  SizedBox(height: 8.0),
                  _buildButtons(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
