// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:ebroker/app/app_theme.dart';
import 'package:ebroker/data/cubits/chat_cubits/send_message.dart';
import 'package:ebroker/ui/screens/chat/chat_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../data/cubits/system/app_theme_cubit.dart';
import '../../../../../utils/Extensions/extensions.dart';
import '../../../../../utils/Notification/chat_message_handler.dart';
import '../../../../../utils/helper_utils.dart';
import '../../../../../utils/hive_utils.dart';
import '../../../../../utils/ui_utils.dart';

part "parts/attachment.part.dart";
part "parts/recordmsg.part.dart";

////Please don't make chaneges without sufficent knowledege in this file. otherwise you will be responsable for it
///
//This will store and ensure that msg is already sent so we don't have to send it again
Set sentMessages = {};

class ChatMessage extends StatefulWidget {
  final String message;
  final String senderId;
  final bool isSentByMe;
  final bool? isSentNow;
  final String propertyId;
  final String reciverId;
  final bool isChatAudio;
  final bool hasAttachment;
  final dynamic audioFile;
  final String time;
  final dynamic attachment;
  final Function(int id)? onHold;

  const ChatMessage(
      {super.key,
      this.isSentNow,
      required this.message,
      required this.isSentByMe,
      required this.isChatAudio,
      this.audioFile,
      this.attachment,
      required this.senderId,
      required this.time,
      required this.hasAttachment,
      required this.propertyId,
      required this.reciverId,
      this.onHold});

  @override
  State<ChatMessage> createState() => ChatMessageState();

  Map toMap() {
    Map data = {};
    data['key'] = key;
    data['message'] = message;
    data['isSentNow'] = isSentNow;
    data['isSentByMe'] = isSentByMe;
    data['isChatAudio'] = isChatAudio;
    data['senderId'] = senderId;
    data['propertyId'] = propertyId;
    data['reciverId'] = reciverId;
    data['hasAttachment'] = hasAttachment;
    data['audioFile'] = audioFile;
    data['time'] = time;
    data['attachment'] = attachment;
    return data;
  }

  factory ChatMessage.fromMap(Map json) {
    var chat = ChatMessage(
        key: json['key'],
        message: json['message'],
        isSentByMe: json['isSentByMe'],
        isChatAudio: json['isChatAudio'],
        senderId: json['senderId'],
        audioFile: json['audioFile'],
        attachment: json['attachment'],
        time: json['time'],
        hasAttachment: json['hasAttachment'],
        propertyId: json['propertyId'],
        reciverId: json['reciverId']);
    return chat;
  }
}

class ChatMessageState extends State<ChatMessage>
    with AutomaticKeepAliveClientMixin {
  bool isChatSent = false;
  bool selectedMessage = false;
  static bool isMounted = false;
  String? link;
  final ValueNotifier _linkAddNotifier = ValueNotifier("");
  @override
  void initState() {
    ///isSentNow is for check if we are not appending messages multiple time
    if (widget.isSentByMe &&
        (widget.isSentNow == true) &&
        isChatSent == false) {
      if (!sentMessages.contains(widget.key)) {
        context.read<SendMessageCubit>().send(
              senderId: HiveUtils.getUserId().toString(),
              recieverId: widget.reciverId,
              attachment: widget.attachment,
              message: widget.message,
              proeprtyId: widget.propertyId,
              audio: widget.audioFile,
            );
      }
      sentMessages.add(widget.key);

      isMounted = true;
    }

    super.initState();
  }

  String _emptyTextIfAttachmentHasNoText() {
    if (widget.hasAttachment) {
      if (widget.message == "[File]") {
        return "";
      } else {
        return widget.message;
      }
    } else {
      return widget.message;
    }
  }

  bool _isLink(String input) {
    ///This will check if text contains link
    final matcher = RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
    return matcher.hasMatch(input);
  }

  List _replaceLink() {
    //This function will make part of text where link starts. we put invisible charector so we can split it with it
    final linkPattern = RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");

    ///This is invisible charector [You can replace it with any special chareactor which generally nobody use]
    const String substringIdentifier = "‎";

    ///This will find and add invisible charector in prefix and suffix
    String splitMapJoin = _emptyTextIfAttachmentHasNoText().splitMapJoin(
      linkPattern,
      onMatch: (match) {
        return substringIdentifier + match.group(0)! + substringIdentifier;
      },
      onNonMatch: (match) {
        return match;
      },
    );
    //finally we split it with invisible charector so it will become list
    return splitMapJoin.split(substringIdentifier);
  }

  List<String> _matchAstric(String data) {
    var pattern = RegExp(r"\*(.*?)\*");

    String mapJoin = data.splitMapJoin(
      pattern,
      onMatch: (p0) {
        return "‎${p0.group(0)!}‎";
      },
      onNonMatch: (p0) {
        return p0;
      },
    );

    return mapJoin.split("‎");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool isDark =
        context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark;

    return GestureDetector(
      onLongPress: () {
        selectedMessageid.value = (widget.key as ValueKey).value;
        selectedRecieverId.value = int.parse(widget.reciverId);
        showDeletebutton.value = true;
      },
      onTap: () {
        selectedMessage = false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Container(
          alignment:
              widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(
            // top: MediaQuery.of(context).size.height * 0.007,
            right: widget.isSentByMe ? 20 : 0,
            left: widget.isSentByMe ? 0 : 20,
          ),
          child: Column(
            crossAxisAlignment: widget.isSentByMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints:
                    BoxConstraints(maxWidth: context.screenWidth * 0.74),
                decoration: BoxDecoration(
                    color: selectedMessage == true
                        ? (widget.isSentByMe == true
                            ? context.color.tertiaryColor.darken(45)
                            : context.color.secondaryColor.darken(45))
                        : (widget.isSentByMe
                            ? const Color(0xffEEEEEE)
                            : context.color.secondaryColor),
                    borderRadius: BorderRadius.circular(8)

                    // BorderRadius.only(
                    //   topRight: widget.isSentByMe
                    //       ? Radius.zero
                    //       : const Radius.circular(10),
                    //   topLeft: widget.isSentByMe
                    //       ? const Radius.circular(10)
                    //       : Radius.zero,
                    //   bottomLeft: const Radius.circular(10),
                    //   bottomRight: const Radius.circular(10),
                    // ),
                    ),
                child: Wrap(
                  runAlignment: WrapAlignment.end,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        child: widget.isChatAudio
                            ? RecordMessage(
                                url: widget.audioFile ?? "",
                                isSentByMe: widget.isSentByMe,
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.hasAttachment)
                                    AttachmentMessage(
                                        url: widget.attachment,
                                        isSentByMe: widget.isSentByMe),

                                  //This is preview builder for image

                                  SelectableText.rich(
                                    TextSpan(
                                      style: TextStyle(
                                          color: (isDark && !widget.isSentByMe)
                                              ? context.color.buttonColor
                                              : Colors.black),
                                      children: _replaceLink().map((data) {
                                        //This will add link to msg
                                        if (_isLink(data)) {
                                          //This will notify priview object that it has link
                                          _linkAddNotifier.value = data;
                                          _linkAddNotifier.notifyListeners();

                                          return TextSpan(
                                              text: data,
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  await launchUrl(
                                                      Uri.parse(data));
                                                },
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Colors.blue[800]));
                                        }
                                        //This will make text bold
                                        return TextSpan(
                                          text: "",
                                          children:
                                              _matchAstric(data).map((text) {
                                            if (text
                                                    .toString()
                                                    .startsWith("*") &&
                                                text.toString().endsWith("*")) {
                                              return TextSpan(
                                                  text:
                                                      text.replaceAll("*", ""),
                                                  style: TextStyle(
                                                      color: (isDark &&
                                                              !widget
                                                                  .isSentByMe)
                                                          ? context
                                                              .color.buttonColor
                                                          : Colors.black,
                                                      fontWeight:
                                                          FontWeight.w800));
                                            }

                                            return TextSpan(
                                                text: text,
                                                style: TextStyle(
                                                    color: (isDark &&
                                                            !widget.isSentByMe)
                                                        ? context
                                                            .color.buttonColor
                                                        : Colors.black));
                                          }).toList(),
                                          style: TextStyle(
                                              color: widget.isSentByMe
                                                  ? context.color.secondaryColor
                                                  : context
                                                      .color.textColorDark),
                                        );
                                      }).toList(),
                                    ),
                                    style: TextStyle(
                                        color: (isDark && !widget.isSentByMe)
                                            ? context.color.buttonColor
                                            : Colors.black),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (widget.isSentByMe && widget.isSentNow == true) ...[
                      BlocConsumer<SendMessageCubit, SendMessageState>(
                        listener: (context, state) {
                          if (state is SendMessageSuccess) {
                            isChatSent = true;

                            ///Value which we added locally
                            ValueKey? uniqueIdentifier = widget.key as ValueKey;

                            ////We were added local id so whenit completed we will replace it with server message id

                            ChatMessageHandlerOLD.updateMessageId(
                                uniqueIdentifier.value, state.messageId);

                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              if (mounted) setState(() {});
                            });
                          }
                        },
                        builder: (context, state) {
                          if (state is SendMessageInProgress) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: 5.0, bottom: 2),
                              child: Icon(
                                Icons.watch_later_outlined,
                                size: context.font.smaller,
                                color: Colors.black,
                              ),
                            );
                          }

                          if (state is SendMessageFailed) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: 5.0, bottom: 2),
                              child: Icon(
                                Icons.error,
                                size: context.font.smaller,
                                color: Colors.black,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      )
                    ]
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Text(
                  (DateTime.parse(widget.time))
                      .toLocal()
                      .toIso8601String()
                      .toString()
                      .formatDate(format: "hh:mm aa"), //
                  style: TextStyle(
                      color: widget.isSentByMe
                          ? context.color.textLightColor
                          : context.color.textLightColor),
                ).size(context.font.smaller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
