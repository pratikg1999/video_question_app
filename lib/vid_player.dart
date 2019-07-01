import 'dart:io';

import "package:video_player/video_player.dart";
import 'package:flutter/material.dart';

class VidPlayer extends StatefulWidget {
  final String vidUri;
  final String vidSource;
  static const String NET_SOURCE = "network";
  static const String ASSET_SOURCE = "asset";
  static const String FILE_SOURCE = "file";
  VidPlayer({this.vidUri, this.vidSource, Key key}) : super(key: key);

  @override
  VidPlayerState createState() {
    return VidPlayerState();
  }
}

class VidPlayerState extends State<VidPlayer> {
  VideoPlayerController _controller;
  Future<void> _controllerInit;
  // bool isPlaying = false;
  @override
  void initState() {
    if (widget.vidSource == VidPlayer.NET_SOURCE) {
      _controller = VideoPlayerController.network(widget.vidUri);
    } else if (widget.vidSource == VidPlayer.FILE_SOURCE) {
      _controller = VideoPlayerController.file(File(widget.vidUri));
    } else if (widget.vidSource == VidPlayer.ASSET_SOURCE) {
      _controller = VideoPlayerController.asset(widget.vidUri);
    }
    _controllerInit = _controller.initialize()
      ..then((value) {
        _controller.setLooping(true);

        // _controller.play();

        // isPlaying = true;
      });
    // _controller.addListener(() {
    //   if(_controller.value.position == _controller.value.duration){
    //     _controller.seekTo(Duration(seconds: 0));
    //     _controller.pause();
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(5),
      child: FutureBuilder(
        future: _controllerInit,
        builder: (context, snapshot) {
          if (snapshot.hasData ||
              snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the VideoPlayer.
            // return AspectRatio(
            //   aspectRatio: 16 / 9,
            //   // Use the VideoPlayer widget to display the video.
            //   child: VideoPlayer(_controller),
            // );
            return player();
          } else {
            print("connection state is not connected");
            return AspectRatio(aspectRatio: 16/9, child: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }

  void doOnTap() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  Widget player() {
    return GestureDetector(
      onTap: doOnTap,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(_controller),
          ),
          playPauseButton(),
        ],
      ),
    );
  }

  Widget playPauseButton() {
    if (_controller.value.isPlaying) {
      return Container(
        height: 0,
        width: 0,
      );
    } else {
      return Container(
        child: Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 50,
        ),
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.black.withAlpha(200)),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
