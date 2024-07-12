import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/articles_repository.dart';
import '../model/article_model.dart';
import '../model/data_output.dart';

abstract class FetchArticlesState {}

class FetchArticlesInitial extends FetchArticlesState {}

class FetchArticlesInProgress extends FetchArticlesState {}

class FetchArticlesSuccess extends FetchArticlesState {
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<ArticleModel> articlemodel;
  final int offset;
  final int total;
  FetchArticlesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.articlemodel,
    required this.offset,
    required this.total,
  });

  FetchArticlesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<ArticleModel>? articlemodel,
    int? offset,
    int? total,
  }) {
    return FetchArticlesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      articlemodel: articlemodel ?? this.articlemodel,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchArticlesFailure extends FetchArticlesState {
  final dynamic errorMessage;
  FetchArticlesFailure(this.errorMessage);
}

class FetchArticlesCubit extends Cubit<FetchArticlesState> {
  FetchArticlesCubit() : super(FetchArticlesInitial());

  final ArticlesRepository _articleRepository = ArticlesRepository();

  Future<void> fetchArticles() async {
    try {
      emit(FetchArticlesInProgress());

      DataOutput<ArticleModel> result =
          await _articleRepository.fetchArticles(offset: 0);

      emit(
        FetchArticlesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            articlemodel: result.modelList,
            offset: 0,
            total: result.total),
      );
    } catch (e) {
      emit(FetchArticlesFailure(e));
    }
  }

  Future<void> fetchArticlesMore() async {
    try {
      if (state is FetchArticlesSuccess) {
        if ((state as FetchArticlesSuccess).isLoadingMore) {
          return;
        }

        emit((state as FetchArticlesSuccess).copyWith(isLoadingMore: true));

        DataOutput<ArticleModel> result =
            await _articleRepository.fetchArticles(
          offset: (state as FetchArticlesSuccess).articlemodel.length,
        );

        FetchArticlesSuccess articlemodelState =
            (state as FetchArticlesSuccess);
        articlemodelState.articlemodel.addAll(result.modelList);
        emit(FetchArticlesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            articlemodel: articlemodelState.articlemodel,
            offset: (state as FetchArticlesSuccess).articlemodel.length,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchArticlesSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchArticlesSuccess) {
      return (state as FetchArticlesSuccess).articlemodel.length <
          (state as FetchArticlesSuccess).total;
    }
    return false;
  }
}
