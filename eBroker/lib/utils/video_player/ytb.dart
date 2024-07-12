import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtbRepo {
  var yt = YoutubeExplode();
  Future<Video> getVideoMetadata(String url) async {
    Video video = await yt.videos.get(url);

    return video;
  }

  Future<List<Map>> getOnlyAudio(String videoId) async {
    List<Map> _temp = [];
    StreamManifest streamManifest =
        await yt.videos.streamsClient.getManifest(videoId);

    for (AudioOnlyStreamInfo audioStream in streamManifest.audioOnly) {
      _temp.add({
        "type": "audio",
        'url': audioStream.url.toString(),
        'size': audioStream.size.totalMegaBytes.toStringAsFixed(2),
        'quality': audioStream.qualityLabel,
        'bitrate': audioStream.bitrate.megaBitsPerSecond
      });
    }
    return _temp;
  }

  Future<List<Map>> getMuxed(String videoId) async {
    List<Map> _temp = [];
    StreamManifest streamManifest =
        await yt.videos.streamsClient.getManifest(videoId);

    for (MuxedStreamInfo muxed in streamManifest.muxed) {
      _temp.add({
        "type": "video",
        'url': muxed.url.toString(),
        'size': muxed.size.totalMegaBytes.toStringAsFixed(2),
        'quality': muxed.videoQuality.name,
        'bitrate': muxed.bitrate.megaBitsPerSecond
      });
    }
    return _temp;
  }
}
