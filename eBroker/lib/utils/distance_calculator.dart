// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:latlong2/latlong.dart';

class CalculateDistance {
  final Distance distance = const Distance(calculator: DistanceHaversine());
  double kelometer(LatLng from, LatLng to) {
    return distance.as(
      LengthUnit.Kilometer,
      from,
      to,
    );
  }

  double meter(LatLng from, LatLng to) {
    return distance(from, to);
  }

  double mile(LatLng from, LatLng to) {
    return distance.as(LengthUnit.Mile, from, to);
  }

  InUnits combined(LatLng from, LatLng to) {
    return InUnits(
        kelometer: kelometer(from, to),
        meter: meter(from, to),
        miles: mile(from, to));
  }
}

class InUnits {
  final double kelometer;
  final double meter;
  final double miles;
  InUnits({
    required this.kelometer,
    required this.meter,
    required this.miles,
  });

  @override
  String toString() =>
      'InUnits(kelometer: $kelometer, meter: $meter, miles: $miles)';
}
