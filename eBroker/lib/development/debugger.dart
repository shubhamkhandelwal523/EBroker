import 'dart:io';

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_view/json_view.dart';
import 'package:path_provider/path_provider.dart';

class Debugger {
  static ValueNotifier<List<ApiRequest>> requests = ValueNotifier([]);
  static List<ValueListenable<Box<dynamic>>> notifiers = [];
  static void clearRequest() async {
    if (!kDebugMode) {
      return;
    }
    requests.value.clear();
    requests.notifyListeners();
  }

  static void addRequest(ApiRequest request) {
    if (!kDebugMode) {
      return;
    }
    requests.value.add(request);
    requests.notifyListeners();
  }

  static void updateRequest({
    required int requestHash,
    required int statusCode,
    required Map response,
  }) {
    if (!kDebugMode) {
      return;
    }
    int index = requests.value
        .indexWhere((element) => element.id == ValueKey(requestHash));
    requests.value[index].response = response;
    requests.value[index].status = statusCode;
    requests.notifyListeners();
  }

  void insert(BuildContext context) {
    if (!kDebugMode) {
      return;
    }
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      return const MyOverlay();
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      overlayState.insert(overlayEntry);
    });
  }
}

class MyOverlay extends StatefulWidget {
  const MyOverlay({super.key});

  @override
  State<MyOverlay> createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyOverlay> {
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
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const ToolBottomSheet();
                },
              );
            },
            child: Container(
              height: 50,
              color: const Color.fromARGB(255, 85, 40, 65),
              child: const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Debugger",
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

class ToolBottomSheet extends StatefulWidget {
  const ToolBottomSheet({super.key});

  @override
  State<ToolBottomSheet> createState() => _ToolBottomSheetState();
}

class _ToolBottomSheetState extends State<ToolBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(
              child: const Text("API Request").color(Colors.black),
            ),
            Tab(
              child: const Text(
                "Hive Request",
                selectionColor: Colors.black,
              ).color(Colors.black),
            ),
          ]),
          Expanded(
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: TabBarView(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            Debugger.clearRequest();
                          },
                          child: const Text("Clear")),
                      Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: Debugger.requests,
                            builder: (context, value, child) {
                              return ListView.builder(
                                itemCount: value.length,
                                reverse: false,
                                padding: const EdgeInsets.all(10),
                                itemBuilder: (context, index) {
                                  ApiRequest request = value[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Host:${Uri.parse(request.url).host}")
                                              .setMaxLines(lines: 1),
                                          Text("Endpoint:${Uri.parse(request.url).pathSegments.last}")
                                              .setMaxLines(lines: 1),
                                          Text("Status:${request.status ?? '--'}")
                                              .setMaxLines(lines: 1),
                                          ExpansionTile(
                                            title: const Text("Response"),
                                            dense: true,
                                            children: [
                                              JsonView(
                                                json: request.response,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                              )
                                            ],
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                  const HiveListenerWidget()
                ])),
          ),
        ],
      ),
    );
  }
}

class ApiRequest {
  final Key id;
  final String url;
  final Map parameter;
  int? status;
  Map? response;
  ApiRequest(this.id, this.url, this.parameter, {this.response, this.status});
}

class HiveListenerWidget extends StatefulWidget {
  const HiveListenerWidget({super.key});

  @override
  State<HiveListenerWidget> createState() => _HiveListenerWidgetState();
}

class _HiveListenerWidgetState extends State<HiveListenerWidget> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Box name"),
                    content: TextField(
                      controller: _controller,
                    ),
                    actions: [
                      MaterialButton(
                        onPressed: () {
                          _controller.text = "";
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          Directory directory =
                              await getApplicationDocumentsDirectory();
                          Hive.init(directory.path);
                          Debugger.notifiers
                              .add(Hive.box(_controller.text).listenable());
                          setState(() {});
                          _controller.text = "";
                          Navigator.pop(context);
                        },
                        child: const Text("Done"),
                      )
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.add)),
        Expanded(
          child: ListView.builder(
            itemCount: Debugger.notifiers.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ValueListenableBuilder(
                valueListenable: Debugger.notifiers[index],
                builder: (context, value, child) {
                  return ExpansionTile(
                    title: Text(value.name),
                    trailing: TextButton(
                      child: const Text("Change"),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ChangeValueDialog(
                              boxKey: value.name,
                            );
                          },
                        );
                      },
                    ),
                    children: [
                      JsonView(
                        json: value.toMap(),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ChangeValueDialog extends StatefulWidget {
  final String boxKey;
  const ChangeValueDialog({super.key, required this.boxKey});

  @override
  State<ChangeValueDialog> createState() => _ChangeValueDialogState();
}

class _ChangeValueDialogState extends State<ChangeValueDialog> {
  // TextEditingController _keyController = TextEditingController();
  TextEditingController _valueController = TextEditingController();
  late String selectedKey = Hive.box(widget.boxKey).toMap().keys.first;
  String selectedType = "String";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change key"),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        MaterialButton(
          onPressed: () {
            Hive.box(widget.boxKey).put(selectedKey, _valueController.text);
            Navigator.pop(context);
          },
          child: const Text("Set"),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton(
            value: selectedKey,
            items: Hive.box(widget.boxKey)
                .toMap()
                .keys
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
            onChanged: (value) {
              selectedKey = value.toString();
              setState(() {});
            },
          ),
          Text(Hive.box(widget.boxKey).get(selectedKey).runtimeType.toString()),
          if (Hive.box(widget.boxKey).get(selectedKey) is bool) ...{
            DropdownButton(
              value: Hive.box(widget.boxKey).get(selectedKey),
              onChanged: (value) {
                Hive.box(widget.boxKey).put(selectedKey, value);
              },
              items: [true, false]
                  .map((e) => DropdownMenuItem(
                        child: Text(e.toString()),
                        value: e,
                      ))
                  .toList(),
            ),
          } else ...{
            TextField(
              controller: _valueController,
              decoration: InputDecoration(hintText: "Value"),
            ),
          }
        ],
      ),
    );
  }
}
