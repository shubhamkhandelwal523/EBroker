// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

class LikedPropertiesState {
  final Set liked;
  Set? removedLikes;
  LikedPropertiesState({
    required this.liked,
    this.removedLikes,
  });

  LikedPropertiesState copyWith({
    Set? liked,
  }) {
    return LikedPropertiesState(
      liked: liked ?? this.liked,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'liked': liked.toList(),
    };
  }

  factory LikedPropertiesState.fromMap(Map<String, dynamic> map) {
    return LikedPropertiesState(
        liked: Set.from(
      (map['liked'] as Set),
    ));
  }

  String toJson() => json.encode(toMap());

  factory LikedPropertiesState.fromJson(String source) =>
      LikedPropertiesState.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'LikedPropertiesState(liked: $liked)';
}

class LikedPropertiesCubit extends Cubit<LikedPropertiesState> {
  LikedPropertiesCubit()
      : super(LikedPropertiesState(liked: {}, removedLikes: {}));

  void changeLike(dynamic id) {
    bool isAvailable = state.liked.contains(id);

    if (isAvailable) {
      state.liked.remove(id);
      state.removedLikes?.add(id);
    } else {
      state.liked.add(id);
    }

    emit(LikedPropertiesState(
        liked: state.liked, removedLikes: state.removedLikes));
  }

  void add(id) {
    state.liked.add(id);
    emit(LikedPropertiesState(
        liked: state.liked, removedLikes: state.removedLikes));
  }


  void emptyCubit(){
    emit(LikedPropertiesState(
      liked: {},
      removedLikes: {},
    ));
  }

  void clear() {
    state.liked.clear();
    state.removedLikes?.clear();
    emit(LikedPropertiesState(liked: {}, removedLikes: {}));
  }

//for locally ,
  Set? getRemovedLikes() {
    return state.removedLikes;
  }
}
