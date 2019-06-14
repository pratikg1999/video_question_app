import 'package:shared_preferences/shared_preferences.dart';

saveCurrentLogin(String  token) async {

  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("Token", token);
//  print(preferences.getString("Token"));

}

Future<String> getCurrentTokenId() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
//  List<String> list= preferences.getStringList("Token");
//  print(list);
//  print(list.toString());
  String res =  preferences.getString("Token");
  print (res);
  return res;
}