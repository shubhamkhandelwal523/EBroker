import 'package:flutter/material.dart';

import 'nativeDeepLinkManager.dart';

abstract class NativeDeepLinkUtility {
  void handle(Uri uri, ProcessResult? result);
  Future<void> handleLink(String url) async {
    Uri parse = Uri.parse(url);
    NativeDeepLinkManager nativeDeepLinkManager = NativeDeepLinkManager();
    ProcessResult? processResult = await nativeDeepLinkManager.process(parse);
    nativeDeepLinkManager.handle(parse, processResult);
  }

  MaterialPageRoute build(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return NativeLinkWidget(
          settings: settings,
        );
      },
    );
  }

  Future<ProcessResult?> process(Uri uri);
}

class ProcessResult<T> {
  final T result;
  ProcessResult(this.result);
}
