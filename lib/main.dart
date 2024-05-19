import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaterialApp(
      home: VideoStreamingWindow(),
    ),
  );
}

class VideoStreamingWindow extends StatefulWidget {
  const VideoStreamingWindow({super.key});

  @override
  State<VideoStreamingWindow> createState() => _VideoStreamingWindowState();
}

class _VideoStreamingWindowState extends State<VideoStreamingWindow>
    with WidgetsBindingObserver {
  late VlcPlayerController _videoPlayerController;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VlcPlayerController.network(
      "rtsp://192.168.59.1:7070/webcam",
      autoInitialize: true,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    _videoPlayerController.addListener(_checkVideoState);
  }

  void _checkVideoState() {
    final state = _videoPlayerController.value.playingState;
    if (state == PlayingState.buffering) {
      setState(() {
        _isBuffering = true;
      });
    } else {
      setState(() {
        _isBuffering = false;
      });
    }

    if (state == PlayingState.stopped || state == PlayingState.error) {
      _reopenVideo();
    }
  }

  void _reopenVideo() {
    _videoPlayerController
        .setMediaFromNetwork(
      "rtsp://192.168.59.1:7070/webcam",
    )
        .then((_) {
      _videoPlayerController.play();
    });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_checkVideoState);
    _videoPlayerController.pause();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _reopenVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Streaming')),
      body: Stack(
        children: [
          VlcPlayer(
            controller: _videoPlayerController,
            aspectRatio: 16 / 9,
            placeholder: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
          if (_isBuffering)
            Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
