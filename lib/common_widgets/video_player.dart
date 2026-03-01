import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnboardingVideo extends StatefulWidget {
  final String videoPath;

  const OnboardingVideo({super.key, required this.videoPath});

  @override
  State<OnboardingVideo> createState() => _OnboardingVideoState();
}

class _OnboardingVideoState extends State<OnboardingVideo> {
  late VideoPlayerController _controller;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.videoPath);

    try {
      await _controller.initialize();

      if (mounted) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      }
    } catch (e) {
      // Handle error gracefully
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video';
        });
        debugPrint('VideoPlayer Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Show placeholder when video fails to load
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Colors.white54,
              ),
              SizedBox(height: 8),
              Text(
                'Video unavailable',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.fitWidth,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      );
    }

    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      ),
    );
  }
}
