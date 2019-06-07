import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ChewieListItem extends StatefulWidget{

  final VideoPlayerController videoPlayerController;

  ChewieListItem({
    @required this.videoPlayerController,
    Key key
  }) : super(key : key);

  @override
  ChewieListItemState createState() {
    return ChewieListItemState();
  }
}

class ChewieListItemState extends State<ChewieListItem>{

  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      aspectRatio: 16 / 9,
      videoPlayerController: widget.videoPlayerController,
      autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) {
      return Padding(
          padding: EdgeInsets.all(10.0),
          child: Chewie(
            controller: _chewieController,
          ),
      );
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
  }

}