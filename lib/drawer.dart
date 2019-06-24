import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teacher/LoginPage.dart';
import 'constants.dart';
import 'shared_preferences_helpers.dart';


/// Navigation Drawer for the app.
/// 
/// The navigation drawer consists of following routes-
/// 1. User information with profile-pic which on click will send to [ProfilePage].
/// 2. My uploaded questions- The questions asked by the current user
/// 3. Not uploaded questions- The questions not uploaded
/// 4. My answers- The answers given by current user
/// 5. Questions for me- The questions asked by other users that current user can answer( based on his interests)
/// 6. Anwers to my questions- The answers for the questions already asked by user
/// 7. my Profile- Shows current user profile
/// 8. Log-out - To logout the current user
/// 9. Close - To close the navigation drawer
class NavDrawer extends StatefulWidget {
  NavDrawer();

  DrawerState createState() {
    return new DrawerState();
  }
}

class DrawerState extends State<NavDrawer> {
  /// Name of the currently logged-in user
  String userName = USER_NAME;

  /// Email of the currently logged-in user
  String email = EMAIL;

  /// Reference to the file containing profile-pic of the currently logged-in user 
  File profilePicFile;
//  void logOutAction() async {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return Center(
//            child: CircularProgressIndicator(),
//          );
//        });
//    int statusCode = await logOut();
//    if(statusCode ==200){
//      print('logged out');
//    }
//
//  }

  /// Re-assigns the [profielPicFile] and [userName]
  /// 
  /// Called whenever the parent widget changes.
  /// This may occur when user starts the navigation drawer again by clicking on the hamburger icon
  @override
  didUpdateWidget(old) {
    // print("drawer didupdate widget");
    initProfilePicFile();
    userName = USER_NAME;
    super.didUpdateWidget(old);
  }


  /// Initializes the [profilePicFile].
  /// 
  /// [profilePicFile] is null if the user hasn't updated his profile-pic even once
  /// Otherwise it points to the file storing profile-pic (made at time of login)
  Future initProfilePicFile() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    profilePicFile = File(join(appDir.path, "profile_pic.png"));
    if (!profilePicFile.existsSync()) {
      print("profile pic doesnt exist in file");
      profilePicFile = null;
    }
    if (mounted == true) {
      setState(() {
        print(profilePicFile);
        if (profilePicFile != null) {
          FileImage(profilePicFile).evict();
        }
      });
    }
  }

  @override
  void initState() {
    initProfilePicFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: InkWell(
                  child: Hero(
                    tag: "profile-pic",
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: profilePicFile == null
                                  ? AssetImage("assets/images/profile_pic.png")
                                  : FileImage(profilePicFile))),
                      // height: 50.0,
                      // width: 50.0,
                    ),
                  ),
                  onTap: () {
                    // Navigator.of(context).pushNamedAndRemoveUntil(
                    //     '/ask', (Route<dynamic> route) => false);
                    Navigator.of(context).pushNamed('/profile');
                  },
                )
                // Text(
                //   widget.userName.substring(0, 1).toUpperCase(),
                //   style: TextStyle(fontWeight: FontWeight.bold),
                // ),
                ),
            accountEmail: Text(email),
            accountName: Text(userName),
          ),
          ListTile(
              title: Text("Ask question"),
              leading: Icon(Icons.question_answer),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ask', (Route<dynamic> route) => false);
              }
            //Navigator.of(context).pushNamed('/ask'),
          ),
          ListTile(
              title: Text("My Uploaded questions"),
              leading: Icon(Icons.card_membership),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ask', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/uploadedvideo');
              }),
              ListTile(
              title: Text("My Not Uploaded questions"),
              leading: Icon(Icons.card_membership),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ask', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/questions');
              }),
          isUser?
          ListTile(
              title: Text("My answers"),
              leading: Icon(Icons.camera_roll),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                print(isUser);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ask', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/answers');
                 }):ListTile(),

              ListTile(
              title: Text("Questions for me"),
              leading: Icon(Icons.question_answer),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/questionsAsked', (Route<dynamic> route) => false);
              }
              
            //Navigator.of(context).pushNamed('/ask'),
          ),
          ListTile(
              title: Text("Answers To My Question"),
              leading: Icon(Icons.question_answer),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/answersPage', (Route<dynamic> route) => false);
              }
            //Navigator.of(context).pushNamed('/ask'),
          ),
             
          isUser?ListTile(
              title: Text("My profile"),
              leading: Icon(Icons.person),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //     '/ask', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/profile');
              }):ListTile(),
          ListTile(
            title: Text("Log out"),
            trailing: Icon(Icons.power_settings_new),
            onTap: () async {
//              Navigator.pop(context); //Gives error
              print(await isKeyPresentInSP(TOKEN_KEY_SP));
              print(await isKeyPresentInSP(EMAIL_KEY_SP));
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                          AlertDialog(
                            //decoration: BoxDecoration(color: Color.fromRGBO(30, 30, 30, 1)),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircularProgressIndicator(),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Logging out",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]));
                  });
//              await Future.delayed(Duration(seconds: 3), (){print("after 3 seconds");}); // await is neccessary
              int statusCode = await logOut();
              Navigator.pop(context); //hiding the progress dialog
              if (statusCode == 200) {
//                Navigator.of(context).pushNamed('/login');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', (Route<dynamic> route) => false);
              } else {
                Scaffold.of(context).showSnackBar(
                    new SnackBar(content: Text("Unable to logout")));
              }
            },
          ),
          ListTile(
            title: Text("Close"),
            trailing: Icon(Icons.close),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
