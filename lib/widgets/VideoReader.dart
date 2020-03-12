import 'dart:io';

import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  Map<String, dynamic> args;
  VideoPage(this.args);
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.args['path']))
      ..initialize().then((_) {
        setState(() {});
      });
//    _controller = VideoPlayerController.network(
//        'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4')
//      ..initialize().then((_) {
//        setState(() {});
//      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FileUtil.getFileName(widget.args['path'])),
      ),
      body: Center(
        child: _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
