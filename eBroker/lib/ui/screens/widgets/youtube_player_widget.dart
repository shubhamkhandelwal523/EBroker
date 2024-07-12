import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final VoidCallback onLandscape;
  final VoidCallback onPortrate;

  final String videoUrl;
  const YoutubePlayerWidget(
      {super.key,
      required this.videoUrl,
      required this.onLandscape,
      required this.onPortrate});

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController controller;

  getVideoId() {
    return YoutubePlayer.convertUrlToId(widget.videoUrl)!;
  }

  @override
  void initState() {
    controller = YoutubePlayerController(
      initialVideoId: getVideoId(),
      flags: const YoutubePlayerFlags(
        showLiveFullscreenButton: true,
        autoPlay: false,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: YoutubePlayerBuilder(
      onEnterFullScreen: () {
        widget.onLandscape.call();
      },
      onExitFullScreen: () {
        widget.onPortrate.call();
      },
      player: YoutubePlayer(
        controller: controller,
      ),
      builder: (context, child) {
        return child;
      },
    ));
  }
}
