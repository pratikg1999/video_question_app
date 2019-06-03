import 'package:shared_preferences/shared_preferences.dart';

saveCurrentLogin(String  token) async {

  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("Token", token);

}