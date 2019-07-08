import 'package:shared_preferences/shared_preferences.dart';


/// **email** key of shared preferences
const EMAIL_KEY_SP = "email";

/// **Token** key of shared preferences
const TOKEN_KEY_SP = "Token";

/// **Name** key of shared preferences
const USER_NAME_SP = "Name";

/// **Age** key of shared preferences
const AGE_KEY_SP = "Age";

/// **Phone** key of shared preferences
const PHONE_KEY_SP = "Phone";

/// **Interests** key of shared preferences
const INTERESTS_KEY_SP = "Interests";

const LOADING_KEY_SP = "loading";

/// saves the [token] of the current login
saveCurrentLogin(String  token) async {

  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(TOKEN_KEY_SP, token);

}

/// Saves a [key] [value] pair in shared preferences
saveInSP(String key, String value) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(key, value);
}

/// Returns the value of the [key] stored in shared preferences
Future<String> getFromSP(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(key);
}


/// Returns the token id of the current login
Future<String> getCurrentTokenId() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(TOKEN_KEY_SP);
}

/// Checks if the [key] is present in the shared preferences
Future<bool> isKeyPresentInSP(String key) async  {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getKeys().contains(key);
}

/// Removes the [key] from shared preferences
Future<bool> removeKeyFromSP(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return  preferences.remove(key);
}