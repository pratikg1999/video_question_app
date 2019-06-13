import 'dart:async';

class Bloc{
  final _passwordController = StreamController<String>();
  static String actualPassword="";
  final validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (String password,sink){
        if(password != actualPassword){
          sink.addError("Passwords don't match");
        }
      },
    );
  Function(String) get changePassword{
    return _passwordController.sink.add;
  }

  Stream<String> get password{
    return _passwordController.stream.transform(validatePassword);
  }



  
}