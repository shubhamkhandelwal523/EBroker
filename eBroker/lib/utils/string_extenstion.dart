import 'package:intl/intl.dart';

extension StringExtention<T extends String> on T {
  ///Number with suffix 10k,10M ,1b
  String priceFormate({bool? disabled}) {
    double numericValue = double.parse(this);
    String formattedNumber = '';

    if (numericValue % 1 == 0) {
      /// If the numeric value is an integer, show it without decimal places
      formattedNumber = NumberFormat.compact().format(numericValue);
    } else {
      // If the numeric value has decimal places, format it with 2 decimal digits
      formattedNumber = NumberFormat('#,##0.00').format(numericValue);
    }

    if (disabled == true) {
      return this;
    }

    return formattedNumber;
  }

  double toDouble() {
    return double.parse(this);
  }
}
