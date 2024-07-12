// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';

class EnquiryIdsLocalCubit extends Cubit<EnquiryIdsLocalState> {
  EnquiryIdsLocalCubit() : super(EnquiryIdsLocalState(ids: []));

  void add(id) {
    List? ids = state.ids;
    ids?.add(
      id,
    );
    emit(
      EnquiryIdsLocalState(ids: ids),
    );
  }
}

class EnquiryIdsLocalState {
  List? ids;
  EnquiryIdsLocalState({
    this.ids,
  });

  EnquiryIdsLocalState copyWith({
    List? ids,
  }) {
    return EnquiryIdsLocalState(
      ids: ids ?? this.ids,
    );
  }

  @override
  String toString() => 'EnquiryIdsLocalState(ids: $ids)';
}
