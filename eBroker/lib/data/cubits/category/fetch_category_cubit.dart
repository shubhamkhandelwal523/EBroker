// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/repositories/category_repository.dart';
import 'package:ebroker/utils/Network/cacheManger.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class FetchCategoryState {}

class FetchCategoryInitial extends FetchCategoryState {}

class FetchCategoryInProgress extends FetchCategoryState {}

class FetchCategorySuccess extends FetchCategoryState {
  final int total;
  final int offset;
  final bool isLoadingMore;
  final bool hasError;
  final List<Category> categories;
  FetchCategorySuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });

  FetchCategorySuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasError,
    List<Category>? categories,
  }) {
    return FetchCategorySuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      'offset': offset,
      'isLoadingMore': isLoadingMore,
      'hasError': hasError,
      'categories': categories.map((x) => x.toMap()).toList(),
    };
  }

  factory FetchCategorySuccess.fromMap(Map<String, dynamic> map) {
    return FetchCategorySuccess(
      total: map['total'] as int,
      offset: map['offset'] as int,
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['hasError'] as bool,
      categories: List<Category>.from(
        (map['categories']).map<Category>(
          (x) => Category.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory FetchCategorySuccess.fromJson(String source) =>
      FetchCategorySuccess.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FetchCategorySuccess(total: $total, offset: $offset, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)';
  }
}

class FetchCategoryFailure extends FetchCategoryState {
  final String errorMessage;

  FetchCategoryFailure(this.errorMessage);
}

class FetchCategoryCubit extends Cubit<FetchCategoryState> with HydratedMixin {
  FetchCategoryCubit() : super(FetchCategoryInitial()) {
    hydrate();
  }

  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<void> fetchCategories(
      {bool? forceRefresh, bool? loadWithoutDelay}) async {
    try {
      await CacheData().getData<FetchCategorySuccess>(
          forceRefresh: forceRefresh == true,
          delay: loadWithoutDelay == true ? 0 : null,
          onProgress: () {
            emit(FetchCategoryInProgress());
          },
          onNetworkRequest: () async {
            DataOutput<Category> categories =
                await _categoryRepository.fetchCategories(offset: 0);

            List<String> list =
                categories.modelList.map((element) => element.image!).toList();
            await HelperUtils.precacheSVG(list);

            return FetchCategorySuccess(
                total: categories.total,
                categories: categories.modelList,
                offset: 0,
                hasError: false,
                isLoadingMore: false);
          },
          onOfflineData: () {
            return (state as FetchCategorySuccess);
          },
          onSuccess: (data) {
            emit(data);
          },
          hasData: (state is FetchCategorySuccess));

      // if (forceRefresh != true) {
      //   if (state is FetchCategorySuccess) {
      //     await Future.delayed(Duration(
      //         seconds: loadWithoutDelay == true
      //             ? 0
      //             : AppSettings.hiddenAPIProcessDelay));
      //   } else {
      //     emit(FetchCategoryInProgress());
      //   }
      // } else {
      //   emit(FetchCategoryInProgress());
      // }

      // if (forceRefresh == true) {
      //   DataOutput<Category> categories =
      //       await _categoryRepository.fetchCategories(offset: 0);
      //
      //   List<String> list =
      //       categories.modelList.map((element) => element.image!).toList();
      //   await HelperUtils.precacheSVG(list);
      //
      //   log("CATEGORIES P${categories.modelList}");
      //   emit(FetchCategorySuccess(
      //       total: categories.total,
      //       categories: categories.modelList,
      //       offset: 0,
      //       hasError: false,
      //       isLoadingMore: false));
      // } else {
      //   if (state is! FetchCategorySuccess) {
      //     DataOutput<Category> categories =
      //         await _categoryRepository.fetchCategories(offset: 0);
      //
      //     List<String> list =
      //         categories.modelList.map((element) => element.image!).toList();
      //     await HelperUtils.precacheSVG(list);
      //
      //     emit();
      //   } else {
      //     await CheckInternet.check(
      //       onInternet: () async {
      //         DataOutput<Category> categories =
      //             await _categoryRepository.fetchCategories(offset: 0);
      //
      //         List<String> list = categories.modelList
      //             .map((element) => element.image!)
      //             .toList();
      //         await HelperUtils.precacheSVG(list);
      //
      //         emit(FetchCategorySuccess(
      //             total: categories.total,
      //             categories: categories.modelList,
      //             offset: 0,
      //             hasError: false,
      //             isLoadingMore: false));
      //       },
      //       onNoInternet: () {
      //         emit(FetchCategorySuccess(
      //             total: (state as FetchCategorySuccess).total,
      //             offset: (state as FetchCategorySuccess).offset,
      //             isLoadingMore: (state as FetchCategorySuccess).isLoadingMore,
      //             hasError: (state as FetchCategorySuccess).hasError,
      //             categories: (state as FetchCategorySuccess).categories));
      //       },
      //     );
      //   }
    } catch (e, st) {
      emit(FetchCategoryFailure(e.toString()));
    }
  }

  Future<Category> get(int id) async {
    try {
      DataOutput<Category> dataOutput =
          await _categoryRepository.fetchCategories(offset: 0, id: id);
      return dataOutput.modelList.first;
    } catch (e) {
      throw e;
    }
  }

  List<Category> getCategories() {
    if (state is FetchCategorySuccess) {
      return (state as FetchCategorySuccess).categories;
    }

    return <Category>[];
  }

  Future<void> fetchCategoriesMore() async {
    try {
      if (state is FetchCategorySuccess) {
        if ((state as FetchCategorySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchCategorySuccess).copyWith(isLoadingMore: true));
        DataOutput<Category> result = await _categoryRepository.fetchCategories(
          offset: (state as FetchCategorySuccess).categories.length,
        );

        FetchCategorySuccess categoryState = (state as FetchCategorySuccess);
        categoryState.categories.addAll(result.modelList);

        List<String> list =
            categoryState.categories.map((e) => e.image!).toList();
        await HelperUtils.precacheSVG(list);

        emit(FetchCategorySuccess(
            isLoadingMore: false,
            hasError: false,
            categories: categoryState.categories,
            offset: (state as FetchCategorySuccess).categories.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchCategorySuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchCategorySuccess) {
      return (state as FetchCategorySuccess).categories.length <
          (state as FetchCategorySuccess).total;
    }
    return false;
  }

  @override
  FetchCategoryState? fromJson(Map<String, dynamic> json) {
    print("Hydrating");
    try {
      var state = json['cubit_state'];

      if (state == "FetchCategorySuccess") {
        return FetchCategorySuccess.fromMap(json);
      }
    } catch (e) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchCategoryState state) {
    print("Storage token ${storageToken}");
    if (state is FetchCategorySuccess) {
      Map<String, dynamic> mapped = state.toMap();

      mapped['cubit_state'] = "FetchCategorySuccess";

      return mapped;
    }

    return null;
  }
}
