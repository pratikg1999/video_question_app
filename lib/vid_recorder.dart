import 'dart:async';
import 'dart:io';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class VidRecorder extends StatefulWidget {
  VidRecorderState createState() {
    return VidRecorderState();
  }
}

class VidRecorderState extends State<VidRecorder> {
  CameraController cameraController;
  List<CameraDescription> cameras;
  Future<void> isInitialized;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      cameraController = CameraController(cameras[1], ResolutionPreset.high);
      isInitialized = cameraController.initialize()
        ..then((value) {
          setState(() {});
        });
    });
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
                  child: cameraPreviewWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cameraPreviewWidget() {
    if (cameraController != null) {
      return FutureBuilder(
        future: isInitialized,
        builder: (context, snaphot) {
          return AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: CameraPreview(cameraController),
          );
        },
      );
    } else {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
  }
}
