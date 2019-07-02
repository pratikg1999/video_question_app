
/// Server's IP address
final String serverIP =  "192.168.43.27"; //"10.196.22.121";//

/// Server's port address
final String serverPort = "8080";   


// Error messages:
/// **User already signed in other device** error
const String ERROR_ALREADY_SIGNED_IN =  "User already signed in other device";

/// **Incorrect password** error
const String ERROR_INCORRECT_PASSWORD= "Incorrect password";

/// **Email not verified** error
const String ERROR_EMAIL_NOT_VERIFIED = "Email not verified";

/// **Email doesn't exist.Please signup first...** error
const String ERROR_EMAIL_NOT_PRESENT = "Email doesn't exist.Please signup first...";

/// **User with this email already exists** error
const String ERROR_USER_ALREADY_EXISTS = "User with this email already exists";

// To store username and email used in Drawers (dont delete it)
/// Name of the currently logged-in user.
String USER_NAME;

/// Email of the currently logged-in user
String EMAIL;

/// True if account type is **user**
bool isUser=true;