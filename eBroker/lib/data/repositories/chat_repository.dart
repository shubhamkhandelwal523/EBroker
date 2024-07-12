import 'package:dio/dio.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/registerar.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:flutter/material.dart';

import '../../utils/api.dart';
import '../../utils/constant.dart';
import '../../utils/hive_utils.dart';
import '../model/chat/chated_user_model.dart';
import '../model/data_output.dart';

class ChatRepostiory {
  BuildContext? _setContext;

  void setContext(BuildContext context) {
    _setContext = context;
  }

  Future<DataOutput<ChatedUser>> fetchChatList(int pageNumber) async {
    Map<String, dynamic> response = await Api.get(
        url: Api.getChatList,
        queryParameters: {"page": pageNumber, "per_page": Constant.loadLimit});

    List<ChatedUser> modelList = (response['data'] as List).map(
      (e) {
        return ChatedUser.fromJson(e, context: _setContext);
      },
    ).toList();

    return DataOutput(total: response['total_page'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<Message>> getMessages(
      {required int page, required int userId, required int propertyId}) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.getMessages,
      queryParameters: {
        "user_id": userId,
        "property_id": propertyId,
        "page": page,
        "per_page": Constant.minChatMessages
      },
    );
    List<Message> modelList = (response['data']['data'] as List).map(
      (result) {
        //Creating model
        ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(result);
        chatMessageModel.setIsSentByMe(
            HiveUtils.getUserId() == chatMessageModel.senderId.toString());
        chatMessageModel.setIsSentNow(false);
        chatMessageModel.date = result['created_at'];
        //Creating message widget
        Message message = filterMessageType(chatMessageModel);
        message.isSentByMe = chatMessageModel.isSentByMe ?? false;
        message.isSentNow = chatMessageModel.isSentNow ?? false;
        message.message = chatMessageModel;

        return message;
      },
    ).toList();

    return DataOutput(total: response['total_page'] ?? 0, modelList: modelList);
  }

  Future<Map<String, dynamic>> sendMessage(
      {required String senderId,
      required String recieverId,
      required String? message,
      required String proeprtyId,
      MultipartFile? audio,
      MultipartFile? attachment}) async {
    Map<String, dynamic> parameters = {
      "sender_id": senderId,
      "receiver_id": recieverId,
      "message": message,
      "property_id": proeprtyId,
      "file": attachment,
      "audio": audio
    };

    if (attachment == null) {
      parameters.remove("file");
    }
    if (audio == null) {
      parameters.remove("audio");
    }
    Map<String, dynamic> map =
        await Api.post(url: Api.sendMessage, parameter: parameters);
    return map;
  }
}
