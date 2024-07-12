import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

import '../../../data/cubits/Utility/fetch_transactions_cubit.dart';
import '../../../data/model/transaction_model.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) {
            return FetchTransactionsCubit();
          },
          child: const TransactionHistory(),
        );
      },
    );
  }

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListener);

  late Map<int, String> statusMap;
  @override
  void initState() {
    context.read<FetchTransactionsCubit>().fetchTransactions();
    super.initState();
  }

  _pageScrollListener() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchTransactionsCubit>().hasMoreData()) {
        context.read<FetchTransactionsCubit>().fetchTransactionsMore();
      }
    }
  }

  @override
  void didChangeDependencies() {
    statusMap = {
      1: UiUtils.translate(context, "statusSuccess"),
      2: UiUtils.translate(context, "statusFail")
    };
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title: UiUtils.translate(context, "transactionHistory")),
      body: BlocBuilder<FetchTransactionsCubit, FetchTransactionsState>(
        builder: (context, state) {
          if (state is FetchTransactionsInProgress) {
            return Center(
              child: UiUtils.progress(),
            );
          }
          if (state is FetchTransactionsFailure) {
            if (state.errorMessage is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () {
                  context.read<FetchTransactionsCubit>().fetchTransactions();
                },
              );
            }

            return const SomethingWentWrong();
          }
          if (state is FetchTransactionsSuccess) {
            if (state.transactionmodel.isEmpty) {
              return NoDataFound(
                onTap: () {
                  context.read<FetchTransactionsCubit>().fetchTransactions();
                },
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _pageScrollController,
                    itemCount: state.transactionmodel.length,
                    itemBuilder: (context, index) {
                      TransactionModel transaction =
                          state.transactionmodel[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16),
                        child: Container(
                            // height: 100,
                            decoration: BoxDecoration(
                                color: context.color.secondaryColor,
                                border: Border.all(
                                    color: context.color.borderColor,
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(10)),
                            child: customTransactionItem(context, transaction)

                            // ListTile(
                            //     contentPadding:
                            //         const EdgeInsetsDirectional.fromSTEB(
                            //             16, 5, 16, 5),
                            //     style: ListTileStyle.list,
                            //     subtitle: Row(
                            //       children: [
                            //         Expanded(
                            //           child: Text(
                            //             transaction.createdAt
                            //                 .toString()
                            //                 .formatDate(),
                            //           ).size(context.font.small),
                            //         ),
                            //       ],
                            //     ),
                            //     trailing: Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Text(
                            //             "${Constant.currencySymbol}${transaction.amount}"),
                            //         Text(statusMap[int.parse(transaction.status)]
                            //             .toString())
                            //       ],
                            //     ),
                            //     title: Row(
                            //       children: [
                            //         Expanded(
                            //             child: Text(transaction.transactionId
                            //                 .toString())),
                            //         const SizedBox(
                            //           width: 5,
                            //         ),
                            //         GestureDetector(
                            //             onTap: () async {
                            //               await HapticFeedback.vibrate();
                            //               var clipboardData = ClipboardData(
                            //                   text: transaction.transactionId ??
                            //                       "");
                            //
                            //               Clipboard.setData(clipboardData)
                            //                   .then((_) {
                            //                 ScaffoldMessenger.of(context)
                            //                     .showSnackBar(SnackBar(
                            //                         content: Text(UiUtils
                            //                             .getTranslatedLabel(
                            //                                 context, "copied"))));
                            //               });
                            //             },
                            //             child: Icon(
                            //               Icons.copy,
                            //               size: context.font.larger,
                            //             ))
                            //       ],
                            //     )),
                            //

                            ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress()
              ],
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget customTransactionItem(
      BuildContext context, TransactionModel transaction) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 41,
              decoration: BoxDecoration(
                color: context.color.tertiaryColor,
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(4),
                  bottomEnd: Radius.circular(4),
                ),
              ),
              // padding: const EdgeInsets.symmetric(vertical: 2.0),
              // margin: EdgeInsets.all(4),
              // height:,
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.transactionId.toString(),
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.createdAt.toString().formatDate(),
                  ).size(context.font.small),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await HapticFeedback.vibrate();
                var clipboardData =
                    ClipboardData(text: transaction.transactionId ?? "");
                Clipboard.setData(clipboardData).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(UiUtils.translate(context, "copied")),
                    ),
                  );
                });
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: context.color.borderColor, width: 1.5)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.copy,
                    size: context.font.larger,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${Constant.currencySymbol}${transaction.amount}")
                    .bold(weight: FontWeight.w700)
                    .color(context.color.tertiaryColor),
                SizedBox(
                  height: 6,
                ),
                Text(statusMap[int.parse(transaction.status)].toString()),
              ],
            ),
          ],
        ),
      );
    });
  }
}
