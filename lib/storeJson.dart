import 'dart:io';
import 'dart:convert'; //to convert json to maps and vice versa
import 'package:path_provider/path_provider.dart'; //add path provider dart plugin on pubspec.yaml file



  /// Creates a file with name [fileName] in the [dir.path].
  void createFile(Map<String, String> content, Directory dir, String fileName) {
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    file.writeAsStringSync(json.encode(content));
  }


  /// Add the [key]-[value] pair to the JSON file with name [email].
  ///
  /// If the JSON file doesn't exist, it gives a call to the [createFile()] method.
  void addToFile(String email, String key,String value) {
    Directory dir;
    File jsonFile;
    Map<String, String>content = Map();
    content[key] = value;
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + email);
      if (jsonFile.existsSync()) {
        Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
        if(jsonFileContent == null){
          jsonFile.writeAsStringSync(json.encode(content));
        }
        else{
          jsonFileContent.addAll(content);
          jsonFile.writeAsStringSync(json.encode(jsonFileContent));
        }
      }
      else{
        createFile(content, dir, email);
      }
    });
  }

  ///Returns a list of all the uploaded questions in the JSON file with name [email].
  Future<List<String>> getUploaded(String email) async {
    Directory dir;
    File jsonFile ;
    List<String>result = List();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + email);
      if(!jsonFile.existsSync()){
        Map<String,String> temp = new Map();
        createFile(temp, dir, email);
        return result;
      }else {
        Map file = json.decode(jsonFile.readAsStringSync());

        if(file != null){
          file.forEach((s1, s2) {
            if (s2 == "Uploaded") {
              result.add(s1);

            }
          });
        }
      }
    });
    return result;
  }
///Returns a list of all the not uploaded questions in the JSON file with name [email].
  Future<List<String>> getNotUploaded(String email)async{
    Directory dir;
    File jsonFile ;
    List<String>result = List();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + email);
      if(!jsonFile.existsSync()){
        Map<String,String> temp = new Map();
        createFile(temp, dir, email);
        return result;
      }else {
        Map file = json.decode(jsonFile.readAsStringSync());

        if(file != null){
          file.forEach((s1, s2) {
            if (s2 == "Not_Uploaded") {
              result.add(s1);

            }
          });
        }
      }
    });
    return result;
  }

  /// Removes the key-value pair from the JSON file, name [email], with key as [key].
  void removeFromFile(String email,String key){
    Directory dir;
    File jsonFile;
    Map file;
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + email);
      if(jsonFile.existsSync()) {
          file = json.decode(jsonFile.readAsStringSync());
          file.remove(key);
      }
      jsonFile.writeAsStringSync(json.encode(file));
    });
  }
  
  /// Updates the [key] in the JSON file, name [email], from **NotUploaded** to **Uploaded**.
  void updateFile(String email,String key){
    Directory dir;
    File jsonFile;
    Map<String,dynamic> file;
    Map<String,dynamic> temp = new Map();
    String k = key + ".mp4";
    temp[k] = "Uploaded";
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + email);
      if(jsonFile.existsSync()) {
        file = json.decode(jsonFile.readAsStringSync());
        file.remove(key+"NotUploaded.mp4");
        file.addAll(temp);
      }
      else{
        createFile(temp, dir, email);
      }
      jsonFile.writeAsStringSync(json.encode(file));
    });
  }
  
  /// Deletes a file with name as [email].
  void deleteFile(String email){
    Directory dir;
    File jsonFile;
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + email);
      jsonFile.delete();
    });
  }
