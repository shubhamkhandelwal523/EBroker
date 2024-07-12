// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/data/repositories/favourites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/constant.dart';

enum FavoriteType {
  add("1"),
  remove("0");

  final String value;

  const FavoriteType(this.value);
}

abstract class AddToFavoriteCubitState {}

class AddToFavoriteCubitInitial extends AddToFavoriteCubitState {}

class AddToFavoriteCubitInProgress extends AddToFavoriteCubitState {}

class AddToFavoriteCubitSuccess extends AddToFavoriteCubitState {
  final int id;
  final FavoriteType favorite;
  AddToFavoriteCubitSuccess({
    required this.favorite,
    required this.id,
  });
}

class AddToFavoriteCubitFailure extends AddToFavoriteCubitState {
  final String errorMessage;

  AddToFavoriteCubitFailure(this.errorMessage);
}

class AddToFavoriteCubitCubit extends Cubit<AddToFavoriteCubitState> {
  AddToFavoriteCubitCubit() : super(AddToFavoriteCubitInitial());

  final FavoriteRepository _favouriteRepository = FavoriteRepository();

  Future<void> setFavroite({
    required int propertyId,
    required FavoriteType type,
  }) async {
    try {
      emit(AddToFavoriteCubitInProgress());
      await _favouriteRepository.addToFavorite(propertyId, type.value);
      if (type == FavoriteType.add) {
        Constant.favoritePropertyList.add((propertyId));
      } else {
        Constant.favoritePropertyList.remove((propertyId));
      }
      emit(AddToFavoriteCubitSuccess(id: propertyId, favorite: type));
    } catch (e) {
      emit(AddToFavoriteCubitFailure(e.toString()));
    }
  }
}
