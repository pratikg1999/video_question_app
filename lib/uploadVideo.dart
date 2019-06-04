import 'package:http/http.dart' as http;
import 'package:teacher/constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:teacher/shared_preferences_helpers.dart';

uploadFile(String filePath) async {
  print("uploading");
  var url = "${serverIP}:${serverPort}/uploadFile";
  var uri = new Uri.http('${serverIP}:${serverPort}', '/uploadFile');

  var token = await getCurrentTokenId();

  final String videoDirectory = '${filePath}';

  var request = new http.MultipartRequest("POST", uri);
  print("successfuly parse the url $url");

  request.files.add( await http.MultipartFile.fromPath('video', videoDirectory, contentType: MediaType('video', 'mp4')));
  request.fields['tokenId'] = token;

  request.send().then((response) {
    print(response.statusCode);
    print(response.toString());
    if (response.statusCode == 200) print("Uploaded!");
  });
}

