import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchPropertyState {}

class FetchPropertyInitial extends FetchPropertyState {}

class FetchPropertyInProgress extends FetchPropertyState {}

class FetchPropertySuccess extends FetchPropertyState {}

class FetchPropertyFailure extends FetchPropertyState {
  final String errorMessage;

  FetchPropertyFailure(this.errorMessage);
}

class FetchPropertyCubit extends Cubit<FetchPropertyState> {
  // final PropertyRepository _propertyRepository = PropertyRepository();
  FetchPropertyCubit() : super(FetchPropertyInitial());
}
