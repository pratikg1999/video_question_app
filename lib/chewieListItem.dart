import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

class ChewieListItem extends StatefulWidget{

   File file;

  ChewieListItem({
    @required this.file,
    Key key
  }) : super(key : key);

  @override
  ChewieListItemState createState() {
    return ChewieListItemState();
  }
}

class ChewieListItemState extends State<ChewieListItem>{

  VideoPlayerController videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController =new VideoPlayerController.file(widget.file);
    _chewieController = ChewieController(
      aspectRatio: 16 / 9,
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
  void dispose() {
    _chewieController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

}