import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:teacher/LoginPage.dart';

class NavDrawer extends StatefulWidget {
  final String userName;
  final String email;

  NavDrawer({this.userName, this.email});

  DrawerState createState() {
    return new DrawerState();
  }
}

class DrawerState extends State<NavDrawer> {
  void logOutAction() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
    int statusCode = await logOut();
    if(statusCode ==200){
      print('logged out');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(widget.userName.substring(0, 0)),
            ),
            accountEmail: Text(widget.email),
            accountName: Text(widget.userName),
          ),
          ListTile(
            title: Text("My questions"),
            leading: Icon(Icons.card_membership),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => Navigator.of(context).pushNamed('/questions'),
          ),
          ListTile(
            title: Text("My answers"),
            leading: Icon(Icons.camera_roll),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => Navigator.of(context).pushNamed('/answers'),
          ),
          ListTile(
            title: Text("Log out"),
            trailing: Icon(Icons.power_settings_new),
            onTap: () async {
//              Navigator.pop(context); //Gives error
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  });
//              await Future.delayed(Duration(seconds: 3), (){print("after 3 seconds");}); // await is neccessary
              int statusCode = await logOut();
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false);
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
