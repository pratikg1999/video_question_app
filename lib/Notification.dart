import 'package:flutter/material.dart';

class check_notify extends StatefulWidget {
  check_notify({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _check_notifyState createState() => _check_notifyState();
}

class _check_notifyState extends State<check_notify> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: new Text('NOTIFICATIONS'),
        )
    );
  }
}