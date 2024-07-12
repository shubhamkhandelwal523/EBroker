class GlobalFormat {
  final List _list = [];

  GlobalFormat build(
    String locale, {
    required List<CurrencyPoint> points,
  }) {
    _list.add({"locale": locale, "point": points});
    return this;
  }

  num _removeDecimalIfZero(double number) {
    if (number % 1 == 0) {
      return number.toInt();
    } else {
      return number;
    }
  }

  String format(String locale, {required num value}) {
    try {
      List current =
          _list.where((element) => locale == element['locale']).toList();
      List<CurrencyPoint> points =
          current.first['point'] as List<CurrencyPoint>;
      for (CurrencyPoint element in points) {
        if (element.toCodePoint == null) {
          if (value.toString().length == element.atPoint) {
            return "${value / element.devision} ${element.name}";
          }
        } else {
          if (value.toString().length >= element.atPoint &&
              value.toString().length <= element.toCodePoint!) {
            return "${_removeDecimalIfZero(value / element.devision)} ${element.name}";
          }
        }
      }
      return "";
    } catch (e) {
      return "";
    }
  }
}

class CurrencyPoint {
  final int atPoint;
  final String name;
  final int? toCodePoint;
  int devision = 1;

  CurrencyPoint(this.atPoint, this.name, {this.toCodePoint}) {
    devision = _calculateDivision();
  }
  int _calculateDivision() {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < atPoint; i++) {
      if (i == 0) {
        buffer.write("1");
      } else {
        buffer.write("0");
      }
    }
    return int.parse(buffer.toString());
  }
}

String currency(String locale, num value) {
  GlobalFormat buildFormatter = GlobalFormat().build("en", points: [
    CurrencyPoint(4, "K", toCodePoint: 5),
    CurrencyPoint(7, "M", toCodePoint: 8),
    CurrencyPoint(10, "B", toCodePoint: 11),
    CurrencyPoint(13, "T", toCodePoint: 14),
  ]).build("hi", points: [
    CurrencyPoint(4, "K", toCodePoint: 5),
    CurrencyPoint(6, "Lac", toCodePoint: 7),
    CurrencyPoint(8, "Cr", toCodePoint: 9),
    CurrencyPoint(9, "Arb", toCodePoint: 10),
  ]).build("ar_EN", points: [
    CurrencyPoint(3, "Alaf", toCodePoint: 4),
    CurrencyPoint(6, "Milyon", toCodePoint: 7),
    CurrencyPoint(9, "Milyar", toCodePoint: 10),
  ]).build("ar", points: [
    CurrencyPoint(3, "ألف", toCodePoint: 4),
    CurrencyPoint(6, "مليون", toCodePoint: 7),
    CurrencyPoint(9, "مليار", toCodePoint: 10),
  ]);

  return buildFormatter.format(locale, value: value);
}
