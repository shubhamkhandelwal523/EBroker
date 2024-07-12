import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFieldsCubit extends Cubit<DynamicFieldsState> {
  DynamicFieldsCubit() : super(DynamicFieldsInitial());
}

class DynamicFieldsState {}

class DynamicFieldsInitial extends DynamicFieldsState {}
