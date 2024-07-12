import '../../utils/api.dart';
import '../model/data_output.dart';
import '../model/transaction_model.dart';

class TransactionRepository {
  Future<DataOutput<TransactionModel>> fetchTransactions() async {
    Map<String, dynamic> parameters = {};

    Map<String, dynamic> response =
        await Api.get(url: Api.getPaymentDetails, queryParameters: parameters);

    List<TransactionModel> transactionList = (response['data'] as List)
        .map((e) => TransactionModel.fromMap(e))
        .toList();

    return DataOutput<TransactionModel>(
        total: transactionList.length, modelList: transactionList);
  }
}
