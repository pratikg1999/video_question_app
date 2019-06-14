import 'package:shared_preferences/shared_preferences.dart';

const EMAIL_KEY_SP = "email";
const TOKEN_KEY_SP = "Token";
const USER_NAME_SP = "Name";

saveCurrentLogin(String  token) async {

  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(TOKEN_KEY_SP, token);

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
  return preferences.getString(TOKEN_KEY_SP);
}

Future<bool> isKeyPresentInSP(String key) async  {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getKeys().contains(key);
}

Future<bool> removeKeyFromSP(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return  preferences.remove(key);
}