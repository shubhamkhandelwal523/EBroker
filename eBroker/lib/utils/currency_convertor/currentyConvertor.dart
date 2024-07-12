// import 'dart:async';
//
// abstract class CurrencyConvertorService {
//   abstract String baseCurrency;
//
//   FutureOr<List<Currency>> execute();
// }
//
// class Currency {
//   final String name;
//   final double rate;
//
//   Currency(this.name, this.rate);
// }
//
// class ExchangeRatesApi implements CurrencyConvertorService {
//   @override
//   late String baseCurrency;
//   @override
//   FutureOr<List<Currency>> execute() async {}
// }
//
// class CurrencyRateProvider {
//   final CurrencyConvertorService service;
//
//   CurrencyRateProvider(this.service, {required this.baseCurrency});
//
//   final String baseCurrency;
//
//   Future<List<Currency>> getExchangeRates() async {
//     service.baseCurrency = this.baseCurrency;
//     List<Currency> respnse = await service.execute();
//
//     return respnse;
//   }
// }
