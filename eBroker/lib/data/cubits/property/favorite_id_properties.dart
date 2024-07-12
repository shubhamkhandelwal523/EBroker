// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteIDsCubit extends Cubit<FavoriteIDsState> {
  FavoriteIDsCubit() : super(FavoriteIDsState(list: {}));

  void addToFavoriteLocal(int id) {
    state.list.add(id);
    emit(FavoriteIDsState(list: state.list));
  }

  void removeFromFavourite(int id) {
    state.list.remove(id);
    emit(FavoriteIDsState(list: state.list));
  }

  bool isFavourite(int id) {
    return state.list.contains(id);
  }
}

class FavoriteIDsState {
  Set<int> list;

  FavoriteIDsState({
    required this.list,
  });
}
