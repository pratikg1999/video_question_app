import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';


class ChewieListItemNet extends StatefulWidget{

  /// The url from where the video is to be downloaded.
  final String url;

  /// Constructor of [ChewieListItemNet].
  ChewieListItemNet({
    @required this.url,
    Key key
  }) : super(key : key);

  @override
  ChewieListItemNetState createState() {
    return ChewieListItemNetState();
  }
}

class ChewieListItemNetState extends State<ChewieListItemNet>{

  /// VideoPlayerController instance required to play video associated with [ChewieListItemNet].
  VideoPlayerController videoPlayerController;

  /// ChewieController instance required to control [ChewieListItemNet].
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController =new VideoPlayerController.network(widget.url);
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

  // @override
  // void deactivate() {
  //   videoPlayerController.dispose();
  //   _chewieController.dispose();
  //   super.deactivate();
  // }

  /// To remove unneeded resources associated with each of the chewieListItem.
  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

}