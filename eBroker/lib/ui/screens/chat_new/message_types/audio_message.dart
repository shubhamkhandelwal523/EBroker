import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:ebroker/ui/screens/widgets/custom_inkWell.dart';
import 'package:ebroker/utils/convert.dart';
import 'package:flutter/material.dart';

import '../../../../exports/main_export.dart';

class AudioMessage extends Message {
  @override
  String type = "audio";
  late AudioPlayer audioPlayer;
  ValueNotifier<bool> isPlaying = ValueNotifier(false);
  int position = 0;
  int durationChanged = 0;
  ValueNotifier<Duration?> duration = ValueNotifier(Duration.zero);
  ValueNotifier<double?> progressValue = ValueNotifier(0);
  AudioMessage() {
    id = DateTime.now().toString();
  }
  @override
  void init() async {
    print("HELLO I AM INIT");
    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((Duration event) {
      durationChanged = event.inSeconds;
      duration.value = event;
    });

    audioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      isPlaying.value = event == PlayerState.playing;
      print("PLAYER STATE IS#${event} ");
    });
    audioPlayer.onPositionChanged.listen((Duration event) {
      position = event.inSeconds;
      duration.value = event;
      double progressIndicatorValue = ConvertNumber.inRange(
          currentValue: event.inSeconds.toDouble(),
          minValue: 0,
          maxValue: durationChanged.toDouble(),
          newMaxValue: 1,
          newMinValue: 0);
      progressValue.value = progressIndicatorValue;
    });
    audioPlayer.setSourceUrl(message!.audio!);

    if (isSentNow && isSentByMe && isSent == false) {
      try {
        context!.read<SendMessageCubit>().send(
              senderId: HiveUtils.getUserId().toString(),
              recieverId: message!.receiverId!,
              attachment: message?.file,
              message: message!.message!,
              proeprtyId: message!.propertyId!,
              audio: message?.audio,
            );
      } catch (e) {
        print("i am issue!!! $e");
      }
    }

    ///if this message is not sent now so it will set id from server
    if (isSentNow == false) {
      id = message!.id!;
    }
    // duration.value = await audioPlayer.getDuration();
    // print("DURATION IS ${duration}");
    super.init();
  }

  @override
  void onRemove() {
    context!
        .read<DeleteMessageCubit>()
        .delete(int.parse(id), receiverId: int.parse(message!.receiverId!));
    super.onRemove();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget render(context) {
    Color messageColor = context.color.textColorDark;
    if (isSentByMe) {
      messageColor = context.color.brightness == Brightness.light
          ? context.color.textColorDark
          : Colors.black;
    }
    return ValueListenableBuilder(
        valueListenable: duration!,
        builder: (context, duration, child) {
          return Align(
            alignment:
                isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  height: 67,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  width: context.screenWidth * 0.74,
                  decoration: isSentByMe
                      ? getSentByMeDecoration(context)
                      : getOtherUserDecoration(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CustomInkWell(
                                onTap: () {
                                  if (isPlaying.value == true) {
                                    audioPlayer.pause();
                                  } else {
                                    audioPlayer.resume();
                                  }
                                },
                                color: isSentByMe
                                    ? getSentByMeDecoration(context)
                                        .color!
                                        .darken(20)
                                    : getOtherUserDecoration(context)
                                        .color!
                                        .darken(20),
                                shape: BoxShape.circle,
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  width: 50 / 1.4,
                                  height: 50 / 1.4,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: ValueListenableBuilder(
                                      valueListenable: isPlaying,
                                      builder: (context, isPlaying, child) {
                                        return Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow_outlined,
                                        );
                                      }),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: ValueListenableBuilder(
                                  valueListenable: progressValue,
                                  builder: (context, progressValue, child) {
                                    return GradientProgressIndicator(
                                      key: Key(message!.id!),
                                      onProgressDrag: (progress) {
                                        double progressIndicatorValue =
                                            ConvertNumber.inRange(
                                                currentValue: progress,
                                                minValue: 0,
                                                maxValue: 1,
                                                newMaxValue:
                                                    durationChanged.toDouble(),
                                                newMinValue: 0);

                                        audioPlayer.seek(Duration(
                                            seconds: progressIndicatorValue
                                                .toInt()));
                                      },
                                      value: progressValue,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                    "${duration!.inMinutes}:${duration.inSeconds}"),
                              )
                            ],
                          ),
                        ),
                        BlocBuilder<SendMessageCubit, SendMessageState>(
                          builder: (context, state) {
                            if (state is SendMessageInProgress) {
                              return Icon(Icons.watch_later_outlined);
                            }
                            return SizedBox.shrink();
                          },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Text((DateTime.parse(message!.date!))
                          .toLocal()
                          .toIso8601String()
                          .toString()
                          .formatDate(format: "hh:mm aa"))
                      .size(context.font.smaller)
                      .color(context.color.textLightColor),
                ),
              ],
            ),
          );
        });
  }

  BoxDecoration getSentByMeDecoration(BuildContext context) {
    return BoxDecoration(
        color: const Color(0xffEEEEEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.borderColor, width: 1.5));
  }

  BoxDecoration getOtherUserDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.color.borderColor, width: 1.5),
    );
  }
}

Map<Key, List<double>> preserveHeightMap = {};

class GradientProgressIndicator extends ProgressIndicator {
  GradientProgressIndicator({
    Key? key,
    double? value,
    Color? backgroundColor,
    this.width,
    Color? color,
    Animation<Color?>? valueColor,
    String? semanticsLabel,
    String? semanticsValue,
    this.minHeight,
    this.onProgressDrag,
    this.borderRadius = BorderRadius.zero,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          color: color,
          valueColor: valueColor,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

  @override
  Color? get backgroundColor => super.backgroundColor;
  final Function(double progress)? onProgressDrag;
  final double? minHeight;
  final BorderRadiusGeometry borderRadius;
  final double? width;

  @override
  State<GradientProgressIndicator> createState() =>
      _GradientLinearProgressIndicatorState();
}

class _GradientLinearProgressIndicatorState
    extends State<GradientProgressIndicator>
    with AutomaticKeepAliveClientMixin {
  List<double> heightMap = [];
  ValueNotifier<double> progress = ValueNotifier(0);
  final GlobalKey _globalKey = GlobalKey();
  double maxDragOffset = 0;
  int numberOfContainers = 0;

  @override
  void initState() {
    super.initState();
    if (!preserveHeightMap.containsKey(widget.key)) {
      Future.delayed(
        const Duration(milliseconds: 10),
        () {
          Map<String, double> widgetInfo =
              UiUtils.getWidgetInfo(context, _globalKey);
          maxDragOffset = widgetInfo['width']!;
          numberOfContainers = (maxDragOffset / 3).floor();
          heightMap = getRandomHeight(numberOfContainers);

          ///This is to solve pattern change issue ... this will store pattern.
          preserveHeightMap[widget.key!] = heightMap;
          setState(() {});
        },
      );

      progress.value = widget.value ?? 0.0;
    } else {
      heightMap = preserveHeightMap[widget.key!]!;
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant GradientProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      progress.value = widget.value ?? 0.0;
    }
    Map<String, double> widgetInfo = UiUtils.getWidgetInfo(context, _globalKey);
    if (widgetInfo['width'] != maxDragOffset) {
      Map<String, double> widgetInfo =
          UiUtils.getWidgetInfo(context, _globalKey);
      maxDragOffset = widgetInfo['width']!;
      numberOfContainers = (maxDragOffset / 3).floor();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTapDown: (details) {
        double inRange = ConvertNumber.inRange(
            currentValue: (details.localPosition).dx.clamp(0, maxDragOffset),
            minValue: 0,
            maxValue: maxDragOffset,
            newMaxValue: 1,
            newMinValue: 0);
        widget.onProgressDrag?.call(inRange);
        progress.value = inRange;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        double inRange = ConvertNumber.inRange(
            currentValue: (details.localPosition).dx.clamp(0, maxDragOffset),
            minValue: 0,
            maxValue: maxDragOffset,
            newMaxValue: 1,
            newMinValue: 0);
        progress.value = inRange;
        print("HEYYY $details");
        widget.onProgressDrag?.call(inRange);
      },
      child: ValueListenableBuilder(
          valueListenable: progress,
          builder: (context, progressValue, child) {
            return SizedBox(
              child: Container(
                key: _globalKey,
                height: widget.minHeight,
                child: Row(
                  children: [
                    ...List.generate(heightMap.length, (index) {
                      double inRange = ConvertNumber.inRange(
                          currentValue: progressValue.toDouble(),
                          minValue: 0,
                          maxValue: 1,
                          newMaxValue: heightMap.length.toDouble(),
                          newMinValue: 0);
                      return Container(
                        height: heightMap[index],
                        width: 3,
                        decoration: BoxDecoration(
                            color: inRange < index
                                ? Colors.grey
                                : context.color.tertiaryColor,
                            borderRadius: BorderRadius.circular(2)),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
    );
  }

  List<double> getRandomHeight(int count) {
    List<double> _heightMap = [];

    for (int index = 0; index < count; index++) {
      double height = Random().nextDouble() * (widget.minHeight ?? 30.0);
      _heightMap.add(height);
    }
    return _heightMap;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
