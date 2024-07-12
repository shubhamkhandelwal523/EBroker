import '../../utils/api.dart';
import '../../utils/constant.dart';
import '../model/article_model.dart';
import '../model/data_output.dart';

class ArticlesRepository {
  Future<DataOutput<ArticleModel>> fetchArticles({required int offset}) async {
    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    Map<String, dynamic> result =
        await Api.get(url: Api.getArticles, queryParameters: parameters);

    List<ArticleModel> modelList = (result['data'] as List)
        .map((element) => ArticleModel.fromJson(element))
        .toList();

    return DataOutput<ArticleModel>(
        total: result['total'] ?? 0, modelList: modelList);
  }

  Future<ArticleModel> fetchArticlesBySlugId(String slug) async {
    Map<String, dynamic> parameters = {"slug_id": slug};

    Map<String, dynamic> result =
        await Api.get(url: Api.getArticles, queryParameters: parameters);

    List<ArticleModel> modelList = (result['data'] as List)
        .map((element) => ArticleModel.fromJson(element))
        .toList();

    return modelList.first;
  }
}
