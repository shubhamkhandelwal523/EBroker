import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoPlayerWideget extends StatefulWidget {
  final String url;
  final EdgeInsetsGeometry? padding;
  const VideoPlayerWideget({super.key, required this.url, this.padding});

  @override
  State<VideoPlayerWideget> createState() => _VideoPlayerWidegetState();
}

class _VideoPlayerWidegetState extends State<VideoPlayerWideget> {
  YoutubeExplode youtubeExplode = YoutubeExplode();
  String? url;

  getYoutubeVideo(url) async {
    try {
      Video video = await youtubeExplode.videos.get(url);
      StreamManifest manifest =
          await youtubeExplode.videos.streams.getManifest(video.id.value);

      MuxedStreamInfo videoQuality =
          manifest.muxed.sortByVideoQuality().bestQuality;
      print("QUALITY IS ${videoQuality.url}");
      url = videoQuality.url.toString();
      _flickmanager = FlickManager(
          autoPlay: false,
          videoPlayerController:
              VideoPlayerController.networkUrl(videoQuality.url));
      setState(() {});
    } catch (e) {
      print("ISSU IS $e");
    }
  }

  Future getYoutubeVideoQualityUrls() async {
    Video? video =
        await YtbRepo().getVideoMetadata("https://youtu.be/lSf5ThEETPk");

    List<Map> list = await YtbRepo().getMuxed(video.id.value);
    print("List map is $list");
  }

  bool isYoutube(String url) {
    return HelperUtils.isYoutubeVideo(url);
  }

  FlickManager? _flickmanager;
  @override
  void initState() {
    if (isYoutube(widget.url)) {
      getYoutubeVideo(widget.url);
    } else {
      _flickmanager = FlickManager(
          autoPlay: false,
          videoPlayerController:
              VideoPlayerController.networkUrl(Uri.parse(widget.url)));
      setState(() {});
    }
    super.initState();
  }

  @override
  void dispose() {
    _flickmanager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flickmanager != null) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: FlickVideoPlayer(
          flickManager: _flickmanager!,
        ),
      );
    }
    return Container(
      height: 0,
    );
  }
}
