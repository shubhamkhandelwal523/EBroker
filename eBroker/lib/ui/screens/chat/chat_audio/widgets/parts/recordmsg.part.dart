part of "../chat_widget.dart";

class RecordMessage extends StatefulWidget {
  final String url;
  final bool isSentByMe;
  const RecordMessage({super.key, required this.url, required this.isSentByMe});

  @override
  State<RecordMessage> createState() => _RecordMessageState();
}

class _RecordMessageState extends State<RecordMessage> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int position = 0;
  int durationChanged = 0;

  @override
  void initState() {
    audioPlayer.onDurationChanged.listen((Duration event) {
      durationChanged = event.inSeconds;
      setState(() {});
    });

    audioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      isPlaying = event == PlayerState.playing;

      setState(() {});
    });
    audioPlayer.onPositionChanged.listen((Duration event) {
      position = event.inSeconds;
      setState(() {});
    });
    // audioPlayer.seek(const Duration(seconds: 1));

    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
            onTap: () {
              if (!isPlaying) {
                if (widget.url.startsWith(("http")) ||
                    widget.url.startsWith("https")) {
                  audioPlayer.play(UrlSource(widget.url));
                } else {
                  audioPlayer.play(DeviceFileSource(widget.url));
                }
              } else {
                audioPlayer.stop();
              }
            },
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: widget.isSentByMe
                  ? context.color.primaryColor
                  : context.color.tertiaryColor,
            )),
        Slider(
          activeColor: widget.isSentByMe
              ? context.color.primaryColor
              : context.color.tertiaryColor,
          inactiveColor: widget.isSentByMe
              ? context.color.primaryColor.withOpacity(0.3)
              : context.color.tertiaryColor.withOpacity(0.3),
          value: position.toDouble(),
          onChanged: (v) {
            audioPlayer.seek(Duration(seconds: v.toInt()));
            setState(() {});
          },
          min: 0,
          max: durationChanged.toDouble(),
        ),
        if ((durationChanged - position) != 0)
          Text((durationChanged - position).toString()).color(widget.isSentByMe
              ? context.color.primaryColor
              : context.color.textColorDark)
      ],
    );
  }
}
