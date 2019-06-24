import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:teacher/shared_preferences_helpers.dart';

///Uploads the file with path [filePath] to the server.
///
/// The function sends the video file to the server via a http request.
/// * uri is request path to the server.
/// * token is the unique session id associated with every logged in user.
/// * request defines the type(POST in this case) of the multipart request to the uri.
/// * response is the variable used to store the response of the http request.
/// * [DateTime.now()] is used to get the current time.
/// * [renameSync()] is used to rename the file.
uploadFile(String filePath) async {
  var uri = new Uri.http('$serverIP:$serverPort', '/uploadFile');

  var token = await getCurrentTokenId();

  final String videoDirectory = '$filePath';

  var request = new http.MultipartRequest("POST", uri);

  request.files.add( await http.MultipartFile.fromPath('video', videoDirectory, contentType: MediaType('video', 'mp4')));
  request.fields['tokenId'] = token;

  request.send().then((response) {
    if (response.statusCode == 200){
        Fluttertoast.showToast(
        msg: 'Successfully uploaded',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
    );
    }else{
       Fluttertoast.showToast(
        msg: 'Video failed to upload..',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
       );
      String currentTime =  DateTime.now().millisecondsSinceEpoch.toString();
      String newPath = videoDirectory.substring(0, videoDirectory.lastIndexOf("/")) + "/" + currentTime + "NotUploaded.mp4";
        File(filePath).renameSync(newPath);
    }
  });
}

