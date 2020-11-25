import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieDemo extends StatefulWidget {
  ChewieDemo({this.title = 'Chewie Demo'});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  VideoPlayerController _videoPlayerController2;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    this.initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1 != null ? _videoPlayerController1.dispose() : null;
    _videoPlayerController2 != null ? _videoPlayerController2.dispose() : null;
    _chewieController != null ? _chewieController.dispose() : null;
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 = VideoPlayerController.network(
        'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4');
    await _videoPlayerController1.initialize();
    _videoPlayerController2 = VideoPlayerController.network(
        'https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4');
    await _videoPlayerController2.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: _chewieController != null &&
                    _chewieController.videoPlayerController.value.initialized
                ? Chewie(
                    controller: _chewieController,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Loading'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
