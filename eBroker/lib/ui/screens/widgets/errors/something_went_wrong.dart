import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SomethingWentWrong extends StatelessWidget {
  final FlutterErrorDetails? error;
  const SomethingWentWrong({super.key, this.error});

  static void asGlobalErrorBuilder() {
    if (kReleaseMode) {
      ErrorWidget.builder =
          (FlutterErrorDetails flutterErrorDetails) => SomethingWentWrong(
                error: flutterErrorDetails,
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: SvgPicture.asset(AppIcons.somethingwentwrong)),
        SizedBox(
          height: 10,
        ),
        const Text("Something went wrong!").size(context.font.larger).bold(),
      ],
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final StackTrace stack;

  const ErrorScreen({super.key, required this.stack});
  void _generateError(context) {
    final filteredStackLines = stack.toString().split('\n').where((line) {
      return !line.contains('package:flutter');
    }).map((line) {
      final parts = line.split(' ');
      return parts.length > 1 ? parts[1] : line;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorDetailScreen(stackLines: filteredStackLines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _generateError(context);
      },
      child: const Text('Generate Error'),
    );
  }
}

class ErrorDetailScreen extends StatelessWidget {
  final List<String> stackLines;

  const ErrorDetailScreen({super.key, required this.stackLines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtered and Prettified Error Stack Trace'),
      ),
      body: ListView.builder(
        itemCount: stackLines.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_formatStackTraceLine(stackLines[index])),
          );
        },
      ),
    );
  }
}

String _formatStackTraceLine(String line) {
  // Example format: "at Class.method (file.dart:42:23)"
  final startIndex = line.indexOf('at ') + 3;
  final endIndex = line.lastIndexOf('(');
  return line.substring(startIndex, endIndex);
}
