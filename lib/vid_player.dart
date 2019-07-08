import 'dart:async';
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
  double curVolume = 1.0;
  StreamController<Duration> seekController = new StreamController<Duration>();

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
        // _controller.setLooping(true);
        curVolume = _controller.value.volume;
        // _controller.play();

        // isPlaying = true;
      });
    _controller.addListener(() {
      if (_controller.value.initialized) {
        seekController.sink.add(_controller.value.position);
        if (_controller.value.position >= _controller.value.duration) {
          // _controller.pause(); produces error
          // _controllerInit = _controller.initialize();
          setState(() {});
        }
      }
    });
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
            return AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }

  void doOnTap() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      if (_controller.value.position >= _controller.value.duration) {
        // _controller.pause();
        _controller.seekTo(Duration(microseconds: 0));
      }
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
          Positioned(
            child: Container(
              color: Colors.black.withAlpha(80),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: drawSeekBar(),
                    ),
                  ),
                  muteButton(),
                ],
              ),
            ),
            bottom: 1,
            left: 1, //This is necessary for bounding the row and expanded
            right: 1, // This is necessary for bounding the row and expanded
          ),
          // drawSeekBar(),
        ],
      ),
    );
  }

  Widget drawSeekBar() {
    return StreamBuilder(
      stream: seekController.stream,
      builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
        if (snapshot.hasData) {
          return Slider(
            min: 0.0,
            max: _controller.value.duration.inMicroseconds.toDouble(),
            value: snapshot.data.inMicroseconds.toDouble(),
            onChanged: (newValue) {
              print("abcd ${snapshot.data}");
              bool toPause = false;
              if(_controller.value.position>=_controller.value.duration){
                toPause = true;
              }
              _controller.seekTo(Duration(microseconds: newValue.toInt()));
              if(toPause){
                _controller.pause();
              }
            },
          );
        } else {
          return Slider(
            min: 0.0,
            max: 1.0,
            value: 0,
            onChanged: null,
          );
        }
      },
    );
  }

  void doMute() {
    if (_controller.value.volume > 0) {
      curVolume = _controller.value.volume;
      _controller.setVolume(0.0);
    } else {
      _controller.setVolume(curVolume);
    }
    setState(() {});
  }

  Widget muteButton() {
    if (_controller.value.volume == 0.0) {
      return IconButton(
        icon: Icon(
          Icons.volume_off,
          color: Colors.white,
        ),
        color: Colors.black.withAlpha(200),
        onPressed: doMute,
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.volume_up,
          color: Colors.white,
        ),
        color: Colors.black.withAlpha(200),
        onPressed: doMute,
      );
    }
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
    print("video disposing");
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    print("video deactivating");
    super.deactivate();
  }
}
