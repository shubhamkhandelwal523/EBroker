import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:flutter/material.dart';

enum MessageSendStatus { progress, success, fail }

abstract class Message {
  abstract String type;
  String id = "";
  bool? isSent;
  bool isSentByMe = false;
  bool isSentNow = false;
  ChatMessageModel? message;
  BuildContext? context;

  Message();

  @override
  String toString() {
    return 'Message{type: $type, id: $id}';
  }

  void init() {}
  void dispose() {}
  void onRemove() {}

  void setContext(BuildContext context) {
    this.context = context;
  }

  Widget render(BuildContext context);
}

class MessageAction {
  final String action;
  final Message message;

  MessageAction({required this.action, required this.message});
}

class MessageId {
  final String id;
  MessageId(this.id);
  factory MessageId.empty(String id) {
    return MessageId(id);
  }
  factory MessageId.senderId(String id) {
    return MessageId(id);
  }
}
