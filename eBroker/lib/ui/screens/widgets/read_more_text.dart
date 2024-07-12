import 'package:flutter/material.dart';

import '../../../utils/ui_utils.dart';

class ReadMoreText extends StatefulWidget {
  final String text;
  final int? maxVisibleCharectors;
  final TextStyle? style;
  final TextStyle? readMoreButtonStyle;
  const ReadMoreText(
      {super.key,
      required this.text,
      this.maxVisibleCharectors,
      this.style,
      this.readMoreButtonStyle});

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool showingFullText = false;

  buildReadMore(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: DefaultTextStyle.of(context).style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    final numLines = textPainter.computeLineMetrics().length;

    if (numLines > 5) {
      return Wrap(
        children: [
          Text(
            showingFullText ? text : _truncateText(text),
            style: widget.style,
          ),
          TextButton(
            style: const ButtonStyle(
              padding: MaterialStatePropertyAll(EdgeInsets.zero),
            ),
            onPressed: () {
              setState(() {
                showingFullText = !showingFullText;
              });
            },
            child: Text(
              showingFullText
                  ? UiUtils.translate(context, "readLessLbl")
                  : UiUtils.translate(context, "readMoreLbl"),
              style: widget.readMoreButtonStyle,
            ),
          ),
        ],
      );
    }

    return Text(text);
  }

  String _truncateText(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: DefaultTextStyle.of(context).style),
      maxLines: 4,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    final endIndex = textPainter
        .getPositionForOffset(
            Offset(MediaQuery.of(context).size.width, double.infinity))
        .offset;

    final truncatedText = text.substring(0, endIndex).trim();
    return truncatedText.length < text.length
        ? "$truncatedText..."
        : truncatedText;
  }

  @override
  Widget build(BuildContext context) {
    return buildReadMore(widget.text);
  }
}
