import 'package:flutter/material.dart';
import 'package:teacher/LoginPage.dart';
import 'shared_preferences_helpers.dart';

class NavDrawer extends StatefulWidget {
  final String userName;
  final String email;

  NavDrawer({this.userName, this.email});

  DrawerState createState() {
    return new DrawerState();
  }
}

class DrawerState extends State<NavDrawer> {
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.userName.substring(0, 1).toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            accountEmail: Text(widget.email),
            accountName: Text(widget.userName),
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
              title: Text("Not Uploaded questions"),
              leading: Icon(Icons.card_membership),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ask', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/questions');
              }),
          ListTile(
              title: Text("Uploaded questions"),
              leading: Icon(Icons.card_membership),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ask', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/uploadedvideo');
              }),
          ListTile(
              title: Text("My answers"),
              leading: Icon(Icons.camera_roll),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ask', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/answers');
              }),
              ListTile(
              title: Text("My profile"),
              leading: Icon(Icons.person),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ask', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/profile');
              }),
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
