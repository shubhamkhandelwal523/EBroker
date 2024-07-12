// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/chat_repository.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadChatMessagesState {}

class LoadChatMessagesInitial extends LoadChatMessagesState {}

class LoadChatMessagesInProgress extends LoadChatMessagesState {}

class LoadChatMessagesSuccess extends LoadChatMessagesState {
  List<Message> messages;
  int currentPage;
  int userId;
  int propertyId;
  int totalPage;
  bool isLoadingMore;
  LoadChatMessagesSuccess({
    required this.messages,
    required this.currentPage,
    required this.userId,
    required this.propertyId,
    required this.totalPage,
    required this.isLoadingMore,
  });

  LoadChatMessagesSuccess copyWith({
    List<Message>? messages,
    int? currentPage,
    int? userId,
    int? propertyId,
    int? totalPage,
    bool? isLoadingMore,
  }) {
    return LoadChatMessagesSuccess(
      messages: messages ?? this.messages,
      currentPage: currentPage ?? this.currentPage,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      totalPage: totalPage ?? this.totalPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  String toString() {
    return 'LoadChatMessagesSuccess(messages: $messages, currentPage: $currentPage, userId: $userId, propertyId: $propertyId, totalPage: $totalPage, isLoadingMore: $isLoadingMore)';
  }
}

class LoadChatMessagesFailed extends LoadChatMessagesState {
  final dynamic error;
  LoadChatMessagesFailed({
    required this.error,
  });
}

class LoadChatMessagesCubit extends Cubit<LoadChatMessagesState> {
  LoadChatMessagesCubit() : super(LoadChatMessagesInitial());
  final ChatRepostiory _chatRepostiory = ChatRepostiory();

  Future<void> load({required int userId, required int propertyId}) async {
    try {
      emit(LoadChatMessagesInProgress());
      DataOutput<Message> result = await _chatRepostiory.getMessages(
        page: 1,
        userId: userId,
        propertyId: propertyId,
      );
      emit(
        LoadChatMessagesSuccess(
            messages: result.modelList,
            currentPage: 1,
            propertyId: propertyId,
            isLoadingMore: false,
            totalPage: result.total,
            userId: userId),
      );
    } catch (e, st) {
      emit(LoadChatMessagesFailed(error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    try {
      if (state is LoadChatMessagesSuccess) {
        if ((state as LoadChatMessagesSuccess).isLoadingMore) {
          return;
        }
        emit((state as LoadChatMessagesSuccess).copyWith(isLoadingMore: true));

        DataOutput<Message> result = await _chatRepostiory.getMessages(
            page: (state as LoadChatMessagesSuccess).currentPage + 1,
            userId: (state as LoadChatMessagesSuccess).userId,
            propertyId: (state as LoadChatMessagesSuccess).propertyId);

        LoadChatMessagesSuccess messagesSuccessState =
            (state as LoadChatMessagesSuccess);

        messagesSuccessState.messages.addAll(result.modelList);

        emit(LoadChatMessagesSuccess(
            messages: messagesSuccessState.messages,
            currentPage: (state as LoadChatMessagesSuccess).currentPage + 1,
            propertyId: (state as LoadChatMessagesSuccess).propertyId,
            isLoadingMore: false,
            totalPage: result.total,
            userId: (state as LoadChatMessagesSuccess).userId));
      }
    } catch (e) {
      emit((state as LoadChatMessagesSuccess).copyWith(isLoadingMore: false));
    }
  }

  bool hasMoreChat() {
    if (state is LoadChatMessagesSuccess) {
      return (state as LoadChatMessagesSuccess).currentPage <
          (state as LoadChatMessagesSuccess).totalPage;
    }
    return false;
  }
}
