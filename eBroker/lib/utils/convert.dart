// ignore_for_file: file_names,

class ConvertNumber {
  //
  //using min max normalization
  //
  static double inRange({
    required double currentValue,
    required double minValue,
    required double maxValue,
    required double newMaxValue,
    required double newMinValue,
  }) {
    double converatedValue = 0.0;
    converatedValue = (currentValue - minValue) /
            (maxValue - minValue) *
            (newMaxValue - newMinValue) +
        newMinValue;
    return converatedValue;
  }

  static T clamp<T extends num>(
      T value, T min, T max, Function(ClampReached reached) callBack) {
    if (value == max) {
      callBack(ClampReached.max);
    } else if (value == min) {
      callBack(ClampReached.min);
    }
    return value.clamp(min, max) as T;
  }

  static bool isInteger(num value) => (value % 1) == 0;
}

class ConvertString {
  static String preetyfyDuration(String text) {
    if (!text.contains(".")) {
      return text;
    }
    return text.substring(0, text.indexOf("."));
  }
}

///enums
enum ClampReached { min, max }
