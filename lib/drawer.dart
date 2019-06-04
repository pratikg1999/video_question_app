import 'package:flutter/material.dart';
import 'constants.dart';

class NavDrawer extends StatefulWidget{
  final String userName;
  final String email;

  NavDrawer({this.userName, this.email});

  DrawerState createState(){
    return new DrawerState();
  }
}

class DrawerState extends State<NavDrawer>{
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(widget.userName.substring(0,0)),
            ),
            accountEmail: Text(widget.email),
            accountName: Text(widget.userName),
          ),
          ListTile(
            title: Text("My questions"),
            leading: Icon(Icons.card_membership),
            trailing: Icon(Icons.arrow_forward),
            onTap: ()=> Navigator.of(context).pushNamed('/questions'),
          ),
          ListTile(
            title: Text("My answers"),
            leading: Icon(Icons.camera_roll),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => Navigator.of(context).pushNamed('/answers'),
          ),
          ListTile(
            title: Text("Close"),
            trailing: Icon(Icons.close),
            onTap: ()=> Navigator.of(context).pop(),
          ),
          ListTile(
            title: Text("Log out"),
            trailing: Icon(Icons.power_settings_new),
            onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false),
          ),
        ],
      ),
    );
  }

}