import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';


/// A [ChewieListItem] uses the video_player under the hood and wraps it in a friendly Material or Cupertino UI!

class ChewieListItem extends StatefulWidget{


  ///[ChewListItem]'s constructor uses parameter [file] to initialise a new object.
  final File file;


  /// Constructor for ChewieListItem.
  ChewieListItem({
    @required this.file,
    Key key
  }) : super(key : key);

  @override
  ChewieListItemState createState() {
//    print("chewie $file");
    return ChewieListItemState();
  }

}


///Builds the state associated with the [ChewieListItem].
class ChewieListItemState extends State<ChewieListItem>{


  ///VideoPlayerController instance required to play video associated with the [ChewieListItem].
  VideoPlayerController videoPlayerController;

  ///ChewieController instance required to control the [ChewieListItem].
  ChewieController _chewieController;


  /// * [videoPlayerController] is initialised to play video stored in [file].
  /// * [_chewieController] is initialised for the [ChewieListItem].
  @override
  void initState() {
    super.initState();
    videoPlayerController =new VideoPlayerController.file(widget.file);
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


  /// Disposes [videoPlayerController] and [_chewieController].
  @override
  void deactivate() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.deactivate();
  }

  /// To remove unneeded resources associated with the [videoPlayerController] and [_chewieController].
  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

}