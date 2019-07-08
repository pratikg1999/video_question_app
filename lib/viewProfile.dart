import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' hide context;
import 'package:path_provider/path_provider.dart';
import 'package:teacher/constants.dart';
import "package:image_picker/image_picker.dart";
import 'package:teacher/shared_preferences_helpers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:teacher/drawer.dart';


///Builds the viewProfilePage.
class ViewPage extends StatefulWidget {
  final String email;
  ViewPage({this.email});
  ViewPageState createState() {
    return ViewPageState();
  }
}

///Builds the state associated with viewProfilePage.
class ViewPageState extends State<ViewPage> {

  ///Number of questions answered by the user.
  String _quesAnswered = "12";

  ///Number of questions asked by the user.
  String _quesAsked = "10";

  ///Status of upload is stored in it.
  bool uploading = false;

  String profPic;
  ///Stores details of the user whose profile pic is  to viewed
  ///
  /// *Name
  /// *Age
  /// *Phone
  /// *e-mail
  /// *Interests.
  String fullName = "loading...";
  String age;
  String phone;
  String email;
  String interests;

  ///Fetches the info of user whose profile is to be viewed
  ///
  ///Sets the value of controllers for
  ///*name
  ///*age
  ///*phone
  ///*email
  ///*interests
  ///*profilePic.
  void getInfo() async {
    print("ENTERED GETINFO");
    var uri = new Uri.http("$serverIP:$serverPort", "/getProfileDetails");
    var request = new http.MultipartRequest("POST", uri);

    request.fields["email"] = widget.email;
    var response = await request.send();
    if(response.statusCode==200){
      var resData = await response.stream.bytesToString();
      var resDataJson = jsonDecode(resData.toString());

      fullName = resDataJson["Name"];
      email = resDataJson["Email"];
      phone = resDataJson["Phone"];
      age = resDataJson["Age"];
      interests = resDataJson["Interests"].toString();
      profPic = resDataJson["ProfilePic"].toString();
      print(profPic+"----------------");
//      if (resDataJson["ProfilePic"].toString() != "null") {
//        print(resDataJson["ProfilePic"]);
//        String profPic = resDataJson["ProfilePic"].toString();
//        await downloadImage(
//            profPic.substring(profPic.lastIndexOf("/") + 1));
      setState(() {});
    }else{
      print("SOME ERROR OCCURED");
    }


    var token = await getCurrentTokenId();
    print(token);

    var Response = await http.get(
        Uri.encodeFull("http://"+serverIP+":"+serverPort+"/getQuestionsInfo?tokenId=$token"),
        headers:{
          "Accept": "application/json"
        }
    );
    List list = new List();
    final map = jsonDecode(Response.body);
    setState(() {
      list = map;
      _quesAsked = list[0];
      _quesAnswered = list[1];
      print(list.toString());
    });

  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  BuildContext ctx;
  @override
  Widget build(BuildContext context){
    ctx = context;
    return Scaffold(
      // drawer: NavDrawer(email: EMAIL, userName: USER_NAME),
        appBar: AppBar(
          title: Text("View"),
        ),
        body: ViewPageBody());
  }

  ///All the widgets are assembled in order
  ///to display bio and statistics.
  Widget ViewPageBody() {
    Size screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          header(),
          SizedBox(
            height: 15.0,
          ),
          Text(
            fullName ,
            style: TextStyle(
                fontFamily: "FiraSans",
                fontWeight: FontWeight.bold,
                fontSize: 30.0),
          ),
          _buildStatContainer(),
          SizedBox(height: 20.0,),
          _buildSeparator(screenSize),
          _buildBio(context,screenSize),
          SizedBox(height: 20.0),
          _buildSeparator(screenSize),
          SizedBox(height: 20.0,)
        ],
      ),
    );
  }

  ///Creates a stack that displays profile image above the background image.
  Widget header() {
    return Stack(
      children: <Widget>[
        bottomMostWidget(),
        circularImage(),
      ],
    );
  }

  ///Sets profile in circular manner
  ///
  /// Icon is placed above profile pic to allow editing.
  /// If editing is done then selected image is set as profile pic.
  Widget circularImage() {
    print("prfile pic : $profPic");
    return Positioned(
      // width: 150.0,
      left: (MediaQuery.of(context).size.width - 150) / 2,
      // right: 25.0,
      top: MediaQuery.of(context).size.height / 6,
      child: Stack(
        children: <Widget>[
          Hero(
            tag: "View-pic",
            child: Container(
              //key: UniqueKey(),
              width: 150.0,
              height: 150.0,
              decoration: new BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 7.0)],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.0),
                image: new DecorationImage(
                  colorFilter: !uploading
                      ? null
                      : ColorFilter.mode(
                      Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  fit: BoxFit.fill,
                  image: (profPic != null && profPic != "null") ?new NetworkImage("http://$serverIP:$serverPort" + "/getProfilePic/${profPic.substring(profPic.lastIndexOf("/")+1)}") : new AssetImage("assets/images/profile_pic.png"),
                ),
              ),
              child: !uploading
                  ? null
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned(
            top: 100,
            left: 100,
            child: InkWell(
              child: Container(
                padding: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///Image is set behind the profile picture.
  Widget bottomMostWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        ClipPath(
          child: Container(
            height: 3 * MediaQuery.of(context).size.height / 7,
            width: MediaQuery.of(context).size.width,
            color: Colors.black.withOpacity(0.8),
          ),
          clipper: GetClipper(),
        ),
      ],
    );
  }


  ///Statistics are set here
  ///
  /// It includes
  /// **Number of questions answered by the user.
  /// **Number of questions asked by the user.
  Widget _buildStatItem(String label, String count) {
    TextStyle _statLabelTextStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w200,
      fontSize: 16.0,
    );
    TextStyle _statCountStyle = TextStyle(
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                count,
                style: _statCountStyle,
              ),
              Text(
                label,
                style: _statLabelTextStyle,
              )
            ],
          )
        ],
      ),
    );
  }

  ///Both statistics are placed adjacent to each other in this widget
  ///
  /// That is questions asked and answered.
  Widget _buildStatContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Questions Asked", _quesAsked),
          _buildStatItem("Questions Answered", _quesAnswered),
        ],
      ),
    );
  }

  ///Details of the user whose profile is to be viewed are
  ///are structured.
  Widget _buildBio(BuildContext context, Size screenSize) {
    TextStyle _bioTextStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
    );
    return Container(
      color: Theme
          .of(context)
          .scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          Text(
            "NAME : ${fullName}",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            "AGE : ${age}",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            "PHONE NUMBER : ${phone}",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            "E-mail : ${email}",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            "INTERESTS : ${interests}",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }


  ///Black single line separator is generated.
  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

}

class GetClipper extends CustomClipper<Path> {
  ///Clipper is created that partitions the background behind profile page.
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width + 150, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
