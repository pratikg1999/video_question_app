import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

class ChewieListItemNet extends StatefulWidget{

  String url;

  ChewieListItemNet({
    @required this.url,
    Key key
  }) : super(key : key){

  }

  @override
  ChewieListItemNetState createState() {
//    print("chewie $file");
    return ChewieListItemNetState();
  }
}

class ChewieListItemNetState extends State<ChewieListItemNet>{

  VideoPlayerController videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController =new VideoPlayerController.network(widget.url);
    print(videoPlayerController.dataSource);
    _chewieController = ChewieController(
      aspectRatio: 16/9 ,
      videoPlayerController: videoPlayerController,
      autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: new AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(
            controller: _chewieController,
          ),
        )

    );
  }

  @override
  void deactivate() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.deactivate();
  }
  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

}