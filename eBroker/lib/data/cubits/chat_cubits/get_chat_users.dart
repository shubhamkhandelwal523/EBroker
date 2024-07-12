// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/chat_repository.dart';
import 'package:ebroker/data/model/chat/chated_user_model.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../model/data_output.dart';

abstract class GetChatListState {}

class GetChatListInitial extends GetChatListState {}

class GetChatListInProgress extends GetChatListState {}

class GetChatListInternalProcess extends GetChatListState {}

class GetChatListSuccess extends GetChatListState {
  final int total;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasError;
  final List<ChatedUser> chatedUserList;
  GetChatListSuccess({
    required this.total,
    required this.currentPage,
    required this.isLoadingMore,
    required this.hasError,
    required this.chatedUserList,
  });

  GetChatListSuccess copyWith({
    int? total,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasError,
    List<ChatedUser>? chatedUserList,
  }) {
    return GetChatListSuccess(
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      chatedUserList: chatedUserList ?? this.chatedUserList,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      'currentPage': currentPage,
      'isLoadingMore': isLoadingMore,
      'hasError': hasError,
      'chatedUserList': chatedUserList.map((x) => x.toJson()).toList(),
    };
  }

  factory GetChatListSuccess.fromMap(Map<String, dynamic> map) {
    return GetChatListSuccess(
      total: map['total'] as int,
      currentPage: map['currentPage'] as int,
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['hasError'] as bool,
      chatedUserList: List<ChatedUser>.from(
        (map['chatedUserList'] as List<int>).map<ChatedUser>(
          (x) => ChatedUser.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class GetChatListFailed extends GetChatListState {
  final dynamic error;

  GetChatListFailed(this.error);
}

class GetChatListCubit extends Cubit<GetChatListState> with HydratedMixin {
  GetChatListCubit() : super(GetChatListInitial());
  final ChatRepostiory _chatRepostiory = ChatRepostiory();

  ///Setting build context for later use
  void setContext(BuildContext context) {
    _chatRepostiory.setContext(context);
  }

  void fetch() async {
    try {
      emit(GetChatListInProgress());

      DataOutput<ChatedUser> result = await _chatRepostiory.fetchChatList(1);

      emit(
        GetChatListSuccess(
          isLoadingMore: false,
          hasError: false,
          chatedUserList: result.modelList,
          currentPage: 1,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(GetChatListFailed(e));
    }
  }

  void addNewChat(ChatedUser user) {
    //this will create new chat in chat list if there is no already
    if (state is GetChatListSuccess) {
      List<ChatedUser> chatedUserList =
          (state as GetChatListSuccess).chatedUserList;
      bool contains = chatedUserList.any(
        (element) => element.userId == user.userId,
      );
      if (contains == false) {
        chatedUserList.insert(0, user);
        emit((state as GetChatListSuccess)
            .copyWith(chatedUserList: chatedUserList));
      }
    }
  }

  Future<void> loadMore() async {
    try {
      if (state is GetChatListSuccess) {
        if ((state as GetChatListSuccess).isLoadingMore) {
          return;
        }
        emit((state as GetChatListSuccess).copyWith(isLoadingMore: true));

        DataOutput<ChatedUser> result = await _chatRepostiory.fetchChatList(
          (state as GetChatListSuccess).currentPage + 1,
        );

        GetChatListSuccess messagesSuccessState = (state as GetChatListSuccess);

        // messagesSuccessState.await.insertAll(0, result.modelList);
        messagesSuccessState.chatedUserList.addAll(result.modelList);
        emit(GetChatListSuccess(
          chatedUserList: messagesSuccessState.chatedUserList,
          currentPage: (state as GetChatListSuccess).currentPage + 1,
          hasError: false,
          isLoadingMore: false,
          total: result.total,
        ));
      }
    } catch (e) {
      emit((state as GetChatListSuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }

  bool hasMoreData() {
    if (state is GetChatListSuccess) {
      return (state as GetChatListSuccess).currentPage <
          (state as GetChatListSuccess).total;
    }

    return false;
  }

  @override
  GetChatListState? fromJson(Map<String, dynamic> json) {
    return null;
  }

  @override
  Map<String, dynamic>? toJson(GetChatListState state) {
    return null;
  }
}
