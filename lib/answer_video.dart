import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teacher/shared_preferences_helpers.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class AnswerVideoRecorder extends StatefulWidget {
  final String questionName;
  AnswerVideoRecorder(this.questionName);
  @override
  _AnswerVideoRecorderState createState() {
    return _AnswerVideoRecorderState();
  }
}

class _AnswerVideoRecorderState extends State<AnswerVideoRecorder> {
  CameraController controller;
  String videoPath;
  List<CameraDescription> cameras;
  int selectedCameraIdx = 0;
  bool toUpload = true;

  String currentTime;
  String email;
  String videoDirectory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _setUpCameras() async {
    try {
      // initialize cameras.
      cameras = await availableCameras();
      // initialize camera controllers.
      controller = new CameraController(cameras[0], ResolutionPreset.medium);
      await controller.initialize();
    } on CameraException catch (e) {
      print(e);
      await controller.initialize();
    }
    if (mounted == false) return;
    setState(() {});
  }

  @override
  void initState() {
    _setUpCameras();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Ask Question'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _captureControlRowWidget(),
                Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    print("controller: $controller");
    print(controller?.value);
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  Widget _cameraTogglesRowWidget() {
    if (cameras == null) {
      print("cameras is null");
      return Row();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: _onSwitchCamera,
            icon: Icon(_getCameraLensIcon(lensDirection)),
            label: Text(
                "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}")),
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  /// Display the control bar with buttons to record videos.
  Widget _captureControlRowWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.videocam),
              color: Colors.blue,
              onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isRecordingVideo
                  ? _onRecordButtonPressed
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              color: Colors.red,
              onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isRecordingVideo
                  ? _onStopButtonPressed
                  : null,
            )
          ],
        ),
      ),
    );
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
    selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${controller.value.errorDescription}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    });

    try {
      print("initializing");
      await controller.initialize();
      print("intialze complete");
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }



  void _onRecordButtonPressed() {
    _startVideoRecording().then((String filePath) {
      if (filePath != null) {
        Fluttertoast.showToast(
            msg: 'Recording video started',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white
        );
      }
    });
  }

  Future<String> _startVideoRecording() async {
    email = await getFromSP(EMAIL_KEY_SP);
    if (!controller.value.isInitialized) {
      Fluttertoast.showToast(
          msg: 'Please wait',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);

      return null;
    }

    // Do nothing if a recording is on progress
    if (controller.value.isRecordingVideo) {
      return null;
    }

    final Directory appDirectory = await getExternalStorageDirectory();
    setState(() {
      videoDirectory = '${appDirectory.path}/Drupal_Videos/answers';
      currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    });
    await Directory(videoDirectory).create(recursive: true);

    final String filePath = '$videoDirectory/$currentTime.mp4';
    print('lsadkjfl;kalsfjdlaksdjfl;kajl;dfkjas');
    print(filePath);
    try {
      await controller.startVideoRecording(filePath);
      videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    Fluttertoast.showToast(
        msg: 'Error: ${e.code}\n${e.description}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _onStopButtonPressed() async {
    await _stopVideoRecording();

  }

  Future<void> _stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
      if(toUpload)
        uploadAnswer(videoPath, widget.questionName);
      else{
        String newPath = videoDirectory + "/" + currentTime + "NotUploaded.mp4";
        print(newPath);
        File(videoPath).renameSync(newPath);
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

  }


  uploadAnswer(String filePath, String questionName) async {
    print("uploading");
    // var url = "$serverIP:$serverPort/uploadAnswer";
    var uri = new Uri.http('$serverIP:$serverPort', '/uploadAnswer');

    var token = await getCurrentTokenId();

    final String videoDirectory = '$filePath';

    var request = new http.MultipartRequest("POST", uri);
    print("successfuly parse the url $uri");

    request.files.add( await http.MultipartFile.fromPath('video', videoDirectory, contentType: MediaType('video', 'mp4')));
    request.fields['tokenId'] = token;
    request.fields['questionName'] = questionName;

    request.send().then((response) {
      print(response.statusCode);
      print(response.toString());
      if (response.statusCode == 200){
        print("Uploaded!");
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
        String currentTime=  DateTime.now().millisecondsSinceEpoch.toString();
        String newPath = videoDirectory.substring(0, videoDirectory.lastIndexOf("/")) + "/" + currentTime + "NotUploaded.mp4";
        print(newPath);
        File(filePath).renameSync(newPath);
      }
    });
  }
}