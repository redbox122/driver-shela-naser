import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shellafood_delivery/util/images.dart';
import 'package:video_player/video_player.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool isNotification;
  const CustomImageWidget(
      {super.key,
      required this.image,
      this.height,
      this.width,
      this.fit = BoxFit.cover,
      this.isNotification = false});

  @override
  Widget build(BuildContext context) {
    final String safeImage = image.trim();
    if (safeImage.isEmpty || safeImage == 'null' || !safeImage.startsWith('http')) {
      return Image.asset(
        isNotification ? Images.notificationPlaceholder : Images.placeholder,
        height: height,
        width: width,
        fit: fit,
      );
    }
    return CachedNetworkImage(
      imageUrl: safeImage,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Image.asset(
          isNotification ? Images.notificationPlaceholder : Images.placeholder,
          height: height,
          width: width,
          fit: fit),
      errorWidget: (context, url, error) => Image.asset(
        isNotification ? Images.notificationPlaceholder : Images.placeholder,
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}

class VideoApp extends StatefulWidget {
  final String videoPath;
  const VideoApp({super.key, required this.videoPath});

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoPath),
    )..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button TEMPhas been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 500,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          VideoPlayer(_controller),
          Center(
            child: IconButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
