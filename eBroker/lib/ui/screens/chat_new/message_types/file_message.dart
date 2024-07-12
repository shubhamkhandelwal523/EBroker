import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/text_and_file.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class FileMessage extends Message {
  @override
  String type = "file";
  List<String> imageExtensions = ["png", "jpg", "jpeg", "webp", "bmp"];
  FileMessage() {
    id = DateTime.now().toString();
  }
  @override
  void init() {
    if (isSentNow && isSentByMe && isSent == false) {
      context!.read<SendMessageCubit>().send(
            senderId: HiveUtils.getUserId().toString(),
            recieverId: message!.receiverId!,
            attachment: message?.file,
            message: message!.message!,
            proeprtyId: message!.propertyId!,
            audio: message?.audio,
          );
    }
    if (isSentNow == false) {
      id = message!.id!;
    }
    super.init();
  }

  @override
  Widget render(context) {
    String extension = message!.file!.split(".").last.toString();

    if (imageExtensions.contains(extension)) {
      return ImageAttachmentWidget(
        isSentByMe: isSentByMe,
        message: message,
        onFileSent: () {
          isSent = true;
        },
        onId: (id) {
          this.id = id;
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: fileWidget(context, extension),
    );
  }

  @override
  void onRemove() {
    context!
        .read<DeleteMessageCubit>()
        .delete(int.parse(id), receiverId: int.parse(message!.receiverId!));
    super.onRemove();
  }

  Widget fileWidget(BuildContext context, String extension) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: context.screenWidth * 0.74,
            // height: 65,
            decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 65,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Container(
                          height: 65,
                          child: Center(
                              child: Text(extension.toUpperCase())
                                  .color(context.color.textColorDark)
                                  .size(context.font.small)),
                        ),
                      ),
                      Container(
                        width: 1.5,
                        height: 50,
                        color: context.color.borderColor.darken(10),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text(message!.file!.split("/").last),
                        ),
                      ),
                      FileDownloadButton(
                        url: message!.file!,
                      ),
                    ],
                  ),
                ),
                BlocConsumer<SendMessageCubit, SendMessageState>(
                  listener: (context, state) {
                    if (state is SendMessageSuccess) {
                      this.id = state.messageId.toString();
                      // widget.onId.call(state.messageId.toString());
                      // widget.onFileSent.call();
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
    );
  }
}
