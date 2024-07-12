// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dio/dio.dart';
import 'package:ebroker/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendMessageState {}

class SendMessageInitial extends SendMessageState {}

class SendMessageInProgress extends SendMessageState {}

class SendMessageSuccess extends SendMessageState {
  final int messageId;
  SendMessageSuccess({
    required this.messageId,
  });
}

class SendMessageFailed extends SendMessageState {
  final dynamic error;
  SendMessageFailed(
    this.error,
  );
}

class SendMessageCubit extends Cubit<SendMessageState> {
  SendMessageCubit() : super(SendMessageInitial());
  final ChatRepostiory _chatRepostiory = ChatRepostiory();
  void send(
      {required String senderId,
      required String recieverId,
      required String message,
      required String proeprtyId,
      dynamic audio,
      dynamic attachment}) async {
    try {
      emit(SendMessageInProgress());
      MultipartFile? audioFile;
      MultipartFile? attachmentFile;

      if (audio != null) {
        audioFile = await MultipartFile.fromFile(audio);
      }
      if (attachment != null) {
        attachmentFile = await MultipartFile.fromFile(attachment);
      }

      ///If use is not uploading any text so we will upload [File].
      var message0 = message;
      if (attachment != null && message == "") {
        message0 = "";
      }

      var result = await _chatRepostiory.sendMessage(
          senderId: senderId,
          recieverId: recieverId,
          message: message0,
          proeprtyId: proeprtyId,
          attachment: attachmentFile,
          audio: audioFile);

      emit(SendMessageSuccess(messageId: result['id']));
    } catch (e) {
      emit(SendMessageFailed(e.toString()));
    }
  }

//This will check if given file like audio recording or attachment is local or it is coming from remote server
  bool isRemoteFile(dynamic file) {
    if (file is String) {
      return true;
    } else {
      return false;
    }
  }
}
