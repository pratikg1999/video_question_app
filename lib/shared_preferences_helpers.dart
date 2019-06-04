import 'package:shared_preferences/shared_preferences.dart';

final EMAIL_KEY_SP = "email";
final TOKEN_KEY_SP = "Token";

saveCurrentLogin(String  token) async {

  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("Token", token);

}

/// Saves a [key] [value] pair in shared preferences
saveInSP(String key, String value) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(key, value);
}

Future<String> getFromSP(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(key);
}

Future<String> getCurrentTokenId() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString("Token");
}

Future<bool> isKeyPresentInSP(String key) async  {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getKeys().contains(key);
}

Future<bool> removeKeyFromSP(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return  preferences.remove(key);
}