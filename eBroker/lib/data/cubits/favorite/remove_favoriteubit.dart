// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/favourites_repository.dart';

abstract class RemoveFavoriteState {}

class RemoveFavoriteInitial extends RemoveFavoriteState {}

class RemoveFavoriteInProgress extends RemoveFavoriteState {}

class RemoveFavoriteSuccess extends RemoveFavoriteState {
  final int id;
  RemoveFavoriteSuccess({
    required this.id,
  });
}

class RemoveFavoriteFailure extends RemoveFavoriteState {
  final String errorMessage;

  RemoveFavoriteFailure(this.errorMessage);
}

class RemoveFavoriteCubit extends Cubit<RemoveFavoriteState> {
  final FavoriteRepository _favoriteRepository = FavoriteRepository();

  RemoveFavoriteCubit() : super(RemoveFavoriteInitial());

  void remove(int propertyID) async {
    try {
      emit(RemoveFavoriteInProgress());
      await _favoriteRepository.removeFavorite(propertyID);
      emit(RemoveFavoriteSuccess(id: propertyID));
    } catch (e) {
      emit(RemoveFavoriteFailure(e.toString()));
    }
  }
}
