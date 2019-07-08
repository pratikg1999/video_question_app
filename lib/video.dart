import 'dart:async';
import 'dart:io';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'uploadVideo.dart';
import 'storeJson.dart';
import 'package:teacher/shared_preferences_helpers.dart';

/// Video Recorder page to ask question
///
/// The video recorded is saved in the external storage with current timestamp as name.
/// It can be uploaded instantly to server if user selects to do so,
/// otherwise it can be uploaded later on.
/// The details of the video is also stored in a JSON file present locally in the application's root directory.
/// The JSON file is handy when loading the user's videos.
class VideoRecorderExample extends StatefulWidget {
  @override
  _VideoRecorderExampleState createState() {
    return _VideoRecorderExampleState();
  }
}

/// The video recorder screen UI.
class _VideoRecorderExampleState extends State<VideoRecorderExample> {
  /// [CameraController] to get access to the camera
  CameraController controller;

  /// The complete path of the currently-being-recorded video
  String videoPath;

  /// The list of cameras present in the device.
  List<CameraDescription> cameras;

  /// The index of the currently selected camera from [cameras]
  int selectedCameraIdx = 0;

  /// Whether the current video is to be uploaded to the server.
  bool toUpload = true;

  /// The current time used as name of the [videoPath].
  String currentTime;

  /// Email of the currently logged-in user.
  String email;

  /// The path where all videos are stored.
  String videoDirectory;

  /// The key for the [Scaffold] of this.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Asks the user to permit to write external storage
  ///
  /// Permission is necessary as video files are stored in external storage
  requestWritePermission() async {
    PermissionStatus permissionStatus =
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);

    if (permissionStatus == PermissionStatus.authorized) {
      setState(() {
        //_allowWriteFile = true;
      });
    }
  }

  requestCameraPermission() async {
    PermissionStatus permissionStatusCamera =
        await SimplePermissions.requestPermission(Permission.Camera);
    if (permissionStatusCamera == PermissionStatus.authorized) {
      setState(() {
        //_allowWriteFile = true;
      });
    }
    PermissionStatus permissionStatusAudio =
        await SimplePermissions.requestPermission(Permission.RecordAudio);
    if (permissionStatusAudio == PermissionStatus.authorized) {
      setState(() {
        //_allowWriteFile = true;
      });
    }
  }

  requestPermissions() async {
    await requestCameraPermission();
    await requestWritePermission();
  }

  /// Performas initial set-up of the camera.
  ///
  /// By-default back-camera is used to record videos.
  Future<void> _setUpCameras() async {
try {
      // initialize cameras.
      cameras = await availableCameras();
      // initialize camera controllers.
      controller = new CameraController(cameras[0], ResolutionPreset.medium);
      await controller.initialize();
    } on CameraException catch (e) {
      print(e);
//      await controller.initialize();
    }
    if (mounted==false) return;
    setState(() {

    });
  }

  /// Takes External Storage write permission and sets up the camera.
  ///
  /// calls [requestWritePermission()] and [_setUpCameras()] internally to do so.
  @override
  void initState() {
    super.initState();
    requestPermissions();
     availableCameras()
         .then((availableCameras) {
       cameras = availableCameras;
       if (cameras.length > 0) {
         setState(() {
           selectedCameraIdx = 1;
         });
         _onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
       }
     })
         .catchError((err) {
       print('Error: $err.code\nError Message: $err.message');
     });
     //_setUpCameras();
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

  /// Returns the icon to display in the _switch camera_ button
  ///
  /// The icon is according to the current camera being used.
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

  /// Displays 'Loading' text when the camera is still loading.
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

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null) {
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

  /// Returns the current timestamp from the system.
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// Switches the camera according to the [cameraDescription].
  ///
  /// The [cameraDescription] contains the information of the camera to be used.
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

//      if (controller.value.hasError) {
//        Fluttertoast.showToast(
//            msg: 'Camera error ${controller.value.errorDescription}',
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.CENTER,
//            timeInSecForIos: 1,
//            backgroundColor: Colors.red,
//            textColor: Colors.white
//        );
//      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Cycles the camera to be used.
  ///
  /// The next camera in the [cameras] is selected
  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx == 1 ? 0:1;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  /// Performs action on Record button pressed.
  ///
  /// calls [_startVideoRecording()] internally to perform video recording
  void _onRecordButtonPressed() {
    _startVideoRecording().then((String filePath) {
      print("FILLLEEEPATHHH");
      print(filePath);
      if (filePath != null) {
        Fluttertoast.showToast(
            msg: 'Recording video started',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white);
      }
    });
  }

  /// shows dialog to ask user whether to upload the currently recorded video, just save locally, or discard it
  ///
  /// Makes [toUpload] true or false accordingly as **Upload now** or **Upload later** is selected.
  /// If **Upload now** is selected-
  /// * [toUpload] is made true
  /// * [_stopVideoRecording()] is called to stop video recording
  /// * [addToFile()] is called to update local JSON file with the current video
  ///
  /// If **Upload later** is selected-
  /// * [toUpload] is made false
  /// * [_stopVideoRecording()] is called to stop video recording
  /// * [addToFile()] is called to update local JSON file with the current video
  ///
  ///  If **Discard** is selected-
  /// * The currently recorded video is deleted
  ///
  Future<void> _showDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AlertDialog(
              title: new Text("Select an option"),
              content: new Text("What do you want to do?"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Upload Now"),
                  onPressed: () {
                    setState(() {
                      toUpload=true;
                    });
                    _stopVideoRecording().then((_) {
                      if (mounted) setState(() {});
                    });
                    addToFile( email,currentTime+".mp4","Uploaded");
                    Navigator.of(context).pop();
                    return;
                  },
                ),
                new FlatButton(
                  child: new Text("Upload Later"),
                  onPressed: () {
                    setState(() {
                      toUpload=false;
                    });
                    _stopVideoRecording().then((_) {
                      if (mounted) setState(() {});
                    });
                    addToFile(email,currentTime+ "NotUploaded" +".mp4","Not_Uploaded");
                    Navigator.of(context).pop();
                    return;
                  },
                ),
                new FlatButton(
                  child: new Text("Discard"),
                  onPressed: () async {
                    //await controller.stopVideoRecording();
                    File file = new File(videoPath);
                    file.delete();

                    // Fluttertoast.showToast(
                    //     msg: 'Successfully deleted video',
                    //     toastLength: Toast.LENGTH_SHORT,
                    //     gravity: ToastGravity.CENTER,
                    //     timeInSecForIos: 1,

                    //     textColor: Colors.black
                    // );
                    Navigator.of(context).pop();
                    return;
                  },
                ),
              ],
            ),
          );
      },
    );
  }

  /// Performs action on Stop button pressed
  void _onStopButtonPressed() async {
    if (!controller.value.isRecordingVideo) {
      return;
    }
    await controller.stopVideoRecording();
    await _showDialog();
  }

  /// Starts the video recording.
  ///
  /// It does the following-
  /// * Sets [email] of the currently logged-in user
  /// * Creates the [videoDiretory]
  /// * Gets [currentTime]
  /// * Sets the [videoPath] by using the [currentTime]
  /// * Starts recording video in the [videoPath]
  Future<String> _startVideoRecording() async {
    email = await getFromSP(EMAIL_KEY_SP);
    if (!controller.value.isInitialized) {
      print("CONTROLLER IS NOT INITIALISED");
      Fluttertoast.showToast(
          msg: 'Please wait',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white
      );
      return null;
    }

    // Do nothing if a recording is on progress
    if (controller.value.isRecordingVideo) {
      print("STILL RECORDING VIDEO");
      return null;
    }

    final Directory appDirectory = await getExternalStorageDirectory();
    setState(() {
      videoDirectory = '${appDirectory.path}/Drupal_Videos';
      currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    });
    await Directory(videoDirectory).create(recursive: true);

    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await controller.startVideoRecording(filePath);
      videoPath = filePath;
    } on CameraException catch (e) {
      print("IN CATCH");
      print("22222222222222222");
      _showCameraException(e);
      return null;
    }
    print("No ERRORRR");
    return filePath;
  }

  /// Stops the video recording. The video is saved in [videoPath].
  ///
  /// If [toUpload] is true-
  /// * Uploads the video to the server by calling [uploadFile()]
  ///
  /// If [toUpload] is false-
  /// * Renames the file by appending "NotUploaded" to it
  /// * Doesn't upload it.
  Future<void> _stopVideoRecording() async {

    try {
      //await controller.stopVideoRecording();
      if(toUpload){
        uploadFile(videoPath);
      }
        
      else{
        String newPath = videoDirectory + "/" + currentTime + "NotUploaded.mp4";
        File(videoPath).renameSync(newPath);
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  /// Shows the exception/error [e] occured in [controller]
  ///
  /// Helper method called to show exceptions.
  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';

    Fluttertoast.showToast(
        msg: 'Error: ${e.code}\n${e.description}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }
}

/// The wrapper class for video recorder.
class VideoRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoRecorderExample(),
    );
  }
}
