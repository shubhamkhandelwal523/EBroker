import 'dart:developer';

import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:flutter/material.dart';

import '../../../../exports/main_export.dart';

class TextMessage extends Message {
  TextMessage() {
    id = DateTime.now().toString();
  }
  @override
  void init() {
    if (isSentNow && isSentByMe && isSent == false) {
      context?.read<SendMessageCubit>().send(
            senderId: HiveUtils.getUserId().toString(),
            recieverId: message!.receiverId!,
            attachment: message?.file,
            message: message!.message!,
            proeprtyId: message!.propertyId!,
            audio: message?.audio,
          );
    }

    ///if this message is not sent now so it will set id from server
    if (isSentNow == false) {
      id = message!.id!;
    }

    super.init();
  }

  @override
  void onRemove() async {
    context!
        .read<DeleteMessageCubit>()
        .delete(int.parse(id), receiverId: int.parse(message!.receiverId!));

    super.onRemove();
  }

  @override
  Widget render(context) {
    Color messageColor = context.color.textColorDark;
    if (isSentByMe) {
      messageColor = context.color.brightness == Brightness.light
          ? context.color.textColorDark
          : Colors.black;
    }

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: context.screenWidth * 0.74),
              decoration: isSentByMe
                  ? getSentByMeDecoration(context)
                  : getOtherUserDecoration(context),
              // color: isSentByMe ? Color(0xffEEEEEE) : context.color.secondaryColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(message?.message ?? "")
                        .size(context.font.normal)
                        .color(messageColor),
                  ),
                  BlocConsumer<SendMessageCubit, SendMessageState>(
                    listener: (context, state) {
                      if (state is SendMessageSuccess) {
                        log("message senttt ${state.messageId}");
                        this.id = state.messageId.toString();
                        isSent = true;
                      }
                    },
                    builder: (context, state) {
                      if (state is SendMessageInProgress) {
                        return const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.watch_later_outlined,
                            size: 10,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text((DateTime.parse(message!.date!))
                      .toLocal()
                      .toIso8601String()
                      .toString()
                      .formatDate(format: "hh:mm aa"))
                  .size(context.font.smaller)
                  .color(context.color.textLightColor),
            )
          ],
        ),
      ),
    );
  }

  BoxDecoration getSentByMeDecoration(BuildContext context) {
    return BoxDecoration(
        color: const Color(0xffEEEEEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context!.color.borderColor, width: 1.5));
  }

  BoxDecoration getOtherUserDecoration(BuildContext context) {
    return BoxDecoration(
      color: context!.color.secondaryColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context!.color.borderColor, width: 1.5),
    );
  }

  @override
  String type = "text";
}
