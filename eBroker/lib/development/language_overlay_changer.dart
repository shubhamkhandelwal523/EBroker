import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LanguageOverlay {
  Future<void> addTool(context) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return const LanguageOverlayChanger();
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      overlayState.insert(overlayEntry);
    });
    // await Future.delayed(duration ?? const Duration(seconds: 3));

    // overlayEntry.remove();
    // onMessageClosed?.call();
  }
}

class LanguageOverlayChanger extends StatefulWidget {
  const LanguageOverlayChanger({super.key});

  @override
  State<LanguageOverlayChanger> createState() => LanguageOverlayChangerState();
}

class LanguageOverlayChangerState extends State<LanguageOverlayChanger> {
  double x = 50;
  double y = 50;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: y,
      left: x,
      child: Material(
        textStyle: const TextStyle(decoration: TextDecoration.none),
        child: Draggable(
          onDragUpdate: (d) {
            x = d.globalPosition.dx;
            y = d.globalPosition.dy;
            setState(() {});
          },
          feedbackOffset: const Offset(-1, 0),
          feedback: Container(),
          child: InkWell(
            onTap: () {
              // if (context.read<LanguageCubit>().currentLanguageCode() == "en") {
              //   context.read<LanguageCubit>().changeLanguage("ar");
              // } else {
              //   context.read<LanguageCubit>().changeLanguage("en");
              // }
            },
            child: Container(
              height: 50,
              color: const Color.fromARGB(255, 85, 40, 65),
              child: const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Change language",
                  style: TextStyle(color: Colors.white),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
