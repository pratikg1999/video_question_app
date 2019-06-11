import 'package:flutter/material.dart';

class CheckBox extends StatefulWidget {
  @override
  CheckBoxState createState() => new CheckBoxState();
}

class CheckBoxState extends State<CheckBox> {
  Map<String, bool> values = {
    'foo': true,
    'bar': false,
  };

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('CheckBox')),
      body:
          new ListView(
            children: values.keys.map((String key) {
              return new CheckboxListTile(
                title: new Text(key),
                value: values[key],
                onChanged: (bool value) {
                  setState(() {
                    values[key] = value;
                  });
                },
              );
            }).toList(),

          ),

    );
  }
}