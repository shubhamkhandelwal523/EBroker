import 'dart:async';

import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/file_message.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/text_and_file.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:ebroker/utils/context_menu.dart';
import 'package:flutter/material.dart';

import 'audio_message.dart';
import 'text_message.dart';

class MessageType {
  final List<Message> _messageTypes = [
    TextMessage(),
    AudioMessage(),
    FileMessage(),
    FileAndText(),
  ];

  Message? get(String type) {
    return _messageTypes.where((element) => element.type == type).first;
  }
}

Message filterMessageType(ChatMessageModel data) {
  return MessageType().get(data.chatMessageType!)!;
}

class ChatMessageHandler {
  static final List<String> sentMessageIds = [];
  static final List<Message> _messages = [];
  static BuildContext? messageContext;
  static final StreamController<MessageAction> _messageStream =
      StreamController<MessageAction>.broadcast();
  static final StreamController<List<Message>> _allMessageStream =
      StreamController<List<Message>>.broadcast();

  static Stream<List<Message>> listenMessages() {
    return _allMessageStream.stream;
  }

  static void add(ChatMessageModel data) async {
    try {
      Message message = filterMessageType(data);

      message.isSentByMe = data.isSentByMe ?? false;
      message.isSentNow = data.isSentNow ?? false;
      message.message = data;
      message.isSent =
          data.isSentByMe == true ? sentMessageIds.contains(message.id) : null;

      ///This is to determine which messages are sent..because in flutter reverse list view there is issue of calling initstate of another instance
      if (!sentMessageIds.contains(message.id) &&
          message.isSentByMe &&
          message.isSentNow) {
        sentMessageIds.add(message.id);
      }

      ///this is to resolve flutter's strange issue of not calling init state
      if (message.type == "audio") {
        if (messageContext!.mounted) {
          message.setContext(messageContext!);
        }

        message.init();
      }

      _messageStream.sink.add(MessageAction(action: "add", message: message));
    } catch (e, st) {}
  }

  static void remove(dynamic id) async {
    try {
      int messageIndex = _messages.indexWhere((element) {
        return element.id == id;
      });
      Message deleatableMessage = _messages[messageIndex];
      _messageStream.sink.add(MessageAction(
        action: "remove",
        message: deleatableMessage,
      ));
    } catch (e) {}
  }

  static void flush() {
    _messages.clear();
  }

  static void fillMessages(List<Message> messages) {
    _messages.addAll(messages);

    ///this will call init state of the audio element when loading which we are not calling in render method so here we have to call it
    messages.forEach((element) {
      if (element.type == "audio") {
        element.init();
      }
    });
    _allMessageStream.sink.add(messages);
  }

  static void syncMessages() {
    _allMessageStream.sink.add(_messages);
  }

  static void handle() {
    _messageStream.stream.listen(
      (MessageAction messageAction) {
        if (messageAction.action == "add") {
          _messages.insert(0, messageAction.message);

          syncMessages();
        }
        if (messageAction.action == "remove") {
          messageAction.message.onRemove();
          _messages.remove(messageAction.message);
          syncMessages();
        }
      },
    );
  }
}

///This class is using for render changes and
class RenderMessage extends StatefulWidget {
  final Message message;

  const RenderMessage({key, required this.message}) : super(key: key);

  @override
  MessageRenderState<RenderMessage> createState() => _RenderMessageState();
}

class _RenderMessageState extends MessageRenderState<RenderMessage>
    with AutomaticKeepAliveClientMixin {
  Widget? render;
  @override
  void initState() {
    // if (isRendered()) {

    if (context.mounted) {
      ChatMessageHandler.messageContext = context;
    }

    widget.message.setContext(context);
    if (widget.message.type != "audio") {
      widget.message.init();
    }
    // }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      widget.message.setContext(context);
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ContextMenuRegion(
      contextMenuBuilder: (context, offset) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: offset,
          ),
          buttonItems: <ContextMenuButtonItem>[
            if (widget.message.type == "text" ||
                widget.message.type == "file_and_text")
              ContextMenuButtonItem(
                type: ContextMenuButtonType.copy,
                onPressed: () {
                  ContextMenuController.removeAny();
                },
                label:
                    'Copy${widget.message.type == "file_and_text" ? " Text" : ""}',
              ),
            if (widget.message.isSentByMe)
              ContextMenuButtonItem(
                type: ContextMenuButtonType.delete,
                onPressed: () {
                  ChatMessageHandler.remove(widget.message.id);

                  ContextMenuController.removeAny();
                },
                label: 'Delete',
              ),
          ],
        );
      },
      child: Builder(builder: (ctx) {
        return widget.message.render(context);
      }),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

abstract class MessageRenderState<T extends StatefulWidget> extends State<T> {
  static List renderedMessage = [];
  bool isRendered() {
    if (renderedMessage.contains(this.widget.key)) {
      return true;
    } else {
      renderedMessage.add(this.widget.key);
      return false;
    }
  }
}
