import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../../../../utils/Extensions/extensions.dart';
import '../../../../../utils/ui_utils.dart';
import '../audio_state.dart';
import '../globals.dart';
import 'flow_shader.dart';
import 'lottie_animation.dart';

class RecordButton extends StatefulWidget {
  const RecordButton(
      {Key? key,
      required this.controller,
      required this.callback,
      required this.isSending})
      : super(key: key);

  final AnimationController controller;
  final Function(dynamic path)? callback;
  final bool isSending;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const double size = 43;

  final double lockerHeight = 200;
  double timerWidth = 0;

  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;

  DateTime? startTime;
  Timer? timer;
  String recordDuration = "00:00";
  AudioRecorder? record;

  bool isLocked = false;
  bool showLottie = false;

  @override
  void initState() {
    super.initState();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth =
        MediaQuery.of(context).size.width - 2 * ChatGlobals.defaultPadding - 4;
    timerAnimation =
        Tween<double>(begin: timerWidth + ChatGlobals.defaultPadding, end: 0)
            .animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.2, 1, curve: Curves.easeIn),
    ));
    lockerAnimation =
        Tween<double>(begin: lockerHeight + ChatGlobals.defaultPadding, end: 0)
            .animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.2, 1, curve: Curves.easeIn),
    ));
  }

  @override
  void dispose() {
    if (record != null) record!.dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        (timer?.isActive ?? false) ? lockSlider() : const SizedBox.shrink(),
        (timer?.isActive ?? false) ? cancelSlider() : const SizedBox.shrink(),
        audioButton(),
        if (isLocked) timerLocked(),
      ],
    );
  }

  Widget lockSlider() {
    return Positioned(
      bottom: -lockerAnimation.value,
      child: Container(
        height: lockerHeight,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ChatGlobals.borderRadius),
          color: context.color.secondaryColor,
          //color: Colors.black,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //const FaIcon(FontAwesomeIcons.lock, size: 20),
            const Icon(Icons.lock, size: 20),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: Column(
                children: const [
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ChatGlobals.borderRadius),
          color: context.color.primaryColor,
          //color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              showLottie ? const LottieAnimation() : Text(recordDuration),
              FlowShader(
                duration: const Duration(seconds: 3),
                flowColors: [
                  context.color.tertiaryColor,
                  const Color(0xFF9E9E9E)
                ],
                child: Row(
                  children: [
                    const Icon(Icons.keyboard_arrow_left),
                    Text(UiUtils.translate(context, "slidetocancel")),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                //flowColors: const [Colors.white, Colors.grey],
              ),
              const SizedBox(width: size),
            ],
          ),
        ),
      ),
    );
  }

  Widget timerLocked() {
    return Positioned(
      right: 0,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ChatGlobals.borderRadius),
          color: context.color.secondaryColor,
          //color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 25),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              /*Vibrate.feedback(FeedbackType.success);
              timer?.cancel();
              timer = null;
              startTime = null;
              recordDuration = "00:00";

              var filePath = await Record().stop();
              AudioState.files.add(filePath!);
              Globals.audioListKey.currentState!
                  .insertItem(AudioState.files.length - 1);
              debugPrint(filePath);*/
              saveFile();
              setState(() {
                isLocked = false;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(recordDuration),
                const SizedBox(
                  width: 5,
                ),
                FlowShader(
                  duration: const Duration(seconds: 3),
                  flowColors: [context.color.tertiaryColor, Colors.grey],
                  child: Text(UiUtils.translate(context, "taploacktostop")),
                  //flowColors: const [Colors.white, Colors.grey],
                ),
                const Center(
                  child: Icon(
                    Icons.lock,
                    size: 18,
                    color: Colors.green,
                  ),
                  /*  child: FaIcon(
                    FontAwesomeIcons.lock,
                    size: 18,
                    color: Colors.green,
                  ), */
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget audioButton() {
    return GestureDetector(
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        //child: Widgets.chatSendBtnWidget(widget.isSending, isaudio: true),
        child: Container(
          height: size,
          width: size,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.color.tertiaryColor,
            //color: Theme.of(context).primaryColor,
          ),
          child: widget.isSending
              ? const CircularProgressIndicator()
              : const Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
        ),
      ),
      onLongPressDown: (_) {
        if (widget.isSending) return;
        debugPrint("onLongPressDown");
        widget.controller.forward();
      },
      onLongPressEnd: (details) async {
        if (widget.isSending) return;
        debugPrint("onLongPressEnd");

        if (isCancelled(details.localPosition, context)) {
          // if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.heavy);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          setState(() {
            showLottie = true;
          });

          Timer(const Duration(milliseconds: 1440), () async {
            widget.controller.reverse();
            debugPrint("Cancelled recording");
            var filePath = await record!.stop();
            debugPrint(filePath);
            File(filePath!).delete();
            debugPrint("Deleted $filePath");
            showLottie = false;
          });
        } else if (checkIsLocked(details.localPosition)) {
          widget.controller.reverse();

          // if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.heavy);
          debugPrint("Locked recording");
          debugPrint(details.localPosition.dy.toString());
          setState(() {
            isLocked = true;
          });
        } else {
          widget.controller.reverse();
          saveFile();
          /*Vibrate.feedback(FeedbackType.success);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          var filePath = await Record().stop();
          AudioState.files.add(filePath!);
          Globals.audioListKey.currentState!
              .insertItem(AudioState.files.length - 1);
          debugPrint(filePath);*/
        }
      },
      onLongPressCancel: () {
        if (widget.isSending) return;
        debugPrint("onLongPressCancel");
        widget.controller.reverse();
      },
      onLongPress: () async {
        if (widget.isSending) return;
        debugPrint("onLongPress");
        // if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.success);
        if (await AudioRecorder().hasPermission()) {
          record = AudioRecorder();
          ;
          await record!.start(
            const RecordConfig(
                sampleRate: 44100,
                bitRate: 128000,
                encoder: AudioEncoder.aacLc),
            path:
                "${ChatGlobals.documentPath}audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
          );
          startTime = DateTime.now();
          // print("duration==$recordDuration");
          timer = Timer.periodic(const Duration(seconds: 1), (_) {
            final minDur = DateTime.now().difference(startTime!).inMinutes;
            final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
            String min = minDur < 10 ? "0$minDur" : minDur.toString();
            String sec = secDur < 10 ? "0$secDur" : secDur.toString();
            // print("duration==$min:$sec");
            setState(() {
              recordDuration = "$min:$sec";
            });
          });
        }
      },
    );
  }

  Future<void> saveFile() async {
    // if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.success);
    timer?.cancel();
    timer = null;
    startTime = null;
    recordDuration = "00:00";

    var filePath = await AudioRecorder().stop();
    AudioState.files.add(filePath!);
    if (ChatGlobals.audioListKey.currentState != null) {
      ChatGlobals.audioListKey.currentState!
          .insertItem(AudioState.files.length - 1);
    }
    debugPrint(filePath);
    if (widget.callback != null) {
      widget.callback!(filePath);
    }
  }

  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return (offset.dx < -(MediaQuery.of(context).size.width * 0.2));
  }
}
