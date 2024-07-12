enum UnitTypes {
  squareFeet,
  squareMeter,
  acre,
  hectare,
  gaj,
  bigha,
  cent,
  katha,
  guntha,
}

UnitTypes getEnum(String value) {
  return UnitTypes.values.where((e) => e.name == value).toList()[0];
}

class AreaConverter {
  convert(num value, {required UnitTypes from, required UnitTypes to}) {
    //Square Feet <----------->Square Meter

    if (from == UnitTypes.squareFeet && to == UnitTypes.squareMeter) {
      return (value * 0.092903);
    }
    if (from == UnitTypes.squareMeter && to == UnitTypes.squareFeet) {
      return (value * 10.763915);
    }

    //Square Feet <----------->Acre
    if (from == UnitTypes.squareFeet && to == UnitTypes.acre) {
      return (value * 0.00002295);
    }
    if (from == UnitTypes.acre && to == UnitTypes.squareFeet) {
      return (value * 43560.057264);
    }

    //Square Feet <----------->Hectare

    if (from == UnitTypes.squareFeet && to == UnitTypes.hectare) {
      return (value * 0.000009);
    }
    if (from == UnitTypes.hectare && to == UnitTypes.squareFeet) {
      return (value * 107639.150512);
    }
    //Square Feet <----------->Gaj

    if (from == UnitTypes.squareFeet && to == UnitTypes.gaj) {
      return (value * 0.112188);
    }
    if (from == UnitTypes.gaj && to == UnitTypes.squareFeet) {
      return (value * 8.913598);
    }

    //Square Feet <----------->Bigha

    if (from == UnitTypes.squareFeet && to == UnitTypes.bigha) {
      return (value * 0.000037);
    }
    if (from == UnitTypes.bigha && to == UnitTypes.squareFeet) {
      return (value * 27000.010764);
    }
    //Square Feet <----------->Cent

    if (from == UnitTypes.squareFeet && to == UnitTypes.cent) {
      return (value * 0.002296);
    }
    if (from == UnitTypes.cent && to == UnitTypes.squareFeet) {
      return (value * 435.508003);
    }
    //Square Feet <----------->Katha

    if (from == UnitTypes.squareFeet && to == UnitTypes.katha) {
      return (value * 0.000735);
    }
    if (from == UnitTypes.katha && to == UnitTypes.squareFeet) {
      return (value * 1361.000614);
    }
    //Square Feet <----------->Guntha

    if (from == UnitTypes.squareFeet && to == UnitTypes.guntha) {
      return (value * 0.0009182);
    }
    if (from == UnitTypes.guntha && to == UnitTypes.squareFeet) {
      return (value * 1089.000463);
    }

    //Square Meter <----------->Acre

    if (from == UnitTypes.squareMeter && to == UnitTypes.acre) {
      return (value * 0.00024677419354838707);
    }
    if (from == UnitTypes.acre && to == UnitTypes.squareMeter) {
      return (value * 4046.860000);
    }

    //Square Meter <----------->Hectare

    if (from == UnitTypes.squareMeter && to == UnitTypes.hectare) {
      return (value * 0.000100);
    }
    if (from == UnitTypes.hectare && to == UnitTypes.squareMeter) {
      return (value * 10000.000000);
    }
    //Square Meter <----------->gaj

    if (from == UnitTypes.squareMeter && to == UnitTypes.gaj) {
      return (value * 1.207584);
    }
    if (from == UnitTypes.gaj && to == UnitTypes.squareMeter) {
      return (value * 0.828100);
    }
    //Square Meter <----------->Bigha

    if (from == UnitTypes.squareMeter && to == UnitTypes.bigha) {
      return (value * 0.000399);
    }
    if (from == UnitTypes.bigha && to == UnitTypes.squareMeter) {
      return (value * 2508.382000);
    }

    //Square Meter <----------->Cent

    if (from == UnitTypes.squareMeter && to == UnitTypes.cent) {
      return (value * 0.024688172043010752);
    }
    if (from == UnitTypes.cent && to == UnitTypes.squareMeter) {
      return (value * 40.460000);
    }

    //Square Meter <----------->Katha

    if (from == UnitTypes.squareMeter && to == UnitTypes.katha) {
      return (value * 0.007909);
    }
    if (from == UnitTypes.katha && to == UnitTypes.squareMeter) {
      return (value * 126.441040);
    }

    //Square Meter <----------->Guntha

    if (from == UnitTypes.squareMeter && to == UnitTypes.guntha) {
      return (value * 0.009884);
    }
    if (from == UnitTypes.guntha && to == UnitTypes.squareMeter) {
      return (value * 101.171410);
    }

    //Acre <----------->Hectare

    if (from == UnitTypes.acre && to == UnitTypes.hectare) {
      return (value * 0.404686);
    }
    if (from == UnitTypes.hectare && to == UnitTypes.acre) {
      return (value * 2.4710538146717);
    }

    //Acre <----------->gaj

    if (from == UnitTypes.acre && to == UnitTypes.gaj) {
      return (value * 4886.921869);
    }
    if (from == UnitTypes.gaj && to == UnitTypes.acre) {
      return (value * 0.000205);
    }

    //Acre <----------->Bigha

    if (from == UnitTypes.acre && to == UnitTypes.bigha) {
      return (value * 1.613335);
    }
    if (from == UnitTypes.bigha && to == UnitTypes.acre) {
      return (value * 0.619834);
    }

    //Acre <----------->Cent

    if (from == UnitTypes.acre && to == UnitTypes.cent) {
      return (value * 100.021256);
    }
    if (from == UnitTypes.cent && to == UnitTypes.acre) {
      return (value * 0.009998);
    }
    //Acre <----------->Katha

    if (from == UnitTypes.acre && to == UnitTypes.katha) {
      return (value * 32.005906);
    }
    if (from == UnitTypes.katha && to == UnitTypes.acre) {
      return (value * 0.031244);
    }
    //Acre <----------->Guntha

    if (from == UnitTypes.acre && to == UnitTypes.guntha) {
      return (value * 40.000036);
    }
    if (from == UnitTypes.guntha && to == UnitTypes.acre) {
      return (value * 0.025000);
    }
    //Hectare <----------->gaj

    if (from == UnitTypes.hectare && to == UnitTypes.gaj) {
      return (value * 12075.836252);
    }
    if (from == UnitTypes.gaj && to == UnitTypes.hectare) {
      return (value * 0.000083);
    }

    //Hectare <----------->Bigha

    if (from == UnitTypes.hectare && to == UnitTypes.bigha) {
      return (value * 3.986634);
    }
    if (from == UnitTypes.bigha && to == UnitTypes.hectare) {
      return (value * 0.250838);
    }
    //Hectare <----------->Cent

    if (from == UnitTypes.hectare && to == UnitTypes.cent) {
      return (value * 247.157687);
    }
    if (from == UnitTypes.cent && to == UnitTypes.hectare) {
      return (value * 0.004046);
    }

    //Hectare <----------->Katha

    if (from == UnitTypes.hectare && to == UnitTypes.katha) {
      return (value * 79.088245);
    }
    if (from == UnitTypes.katha && to == UnitTypes.hectare) {
      return (value * 0.012644);
    }

    //Hectare <----------->Guntha

    if (from == UnitTypes.hectare && to == UnitTypes.guntha) {
      return (value * 98.842153);
    }
    if (from == UnitTypes.guntha && to == UnitTypes.hectare) {
      return (value * 0.010117);
    }

    //Gaj <----------->Bigha

    if (from == UnitTypes.gaj && to == UnitTypes.bigha) {
      return (value * 0.000330);
    }
    if (from == UnitTypes.bigha && to == UnitTypes.gaj) {
      return (value * 3029.081029);
    }

    //Gaj <----------->Cent

    if (from == UnitTypes.gaj && to == UnitTypes.cent) {
      return (value * 0.020467);
    }
    if (from == UnitTypes.cent && to == UnitTypes.gaj) {
      return (value * 48.858833);
    }

    //Gaj <----------->Katha

    if (from == UnitTypes.gaj && to == UnitTypes.katha) {
      return (value * 0.006549);
    }
    if (from == UnitTypes.katha && to == UnitTypes.gaj) {
      return (value * 152.688129);
    }

    //Gaj <----------->Guntha

    if (from == UnitTypes.gaj && to == UnitTypes.guntha) {
      return (value * 0.008185);
    }
    if (from == UnitTypes.guntha && to == UnitTypes.gaj) {
      return (value * 122.172938);
    }

    //Bigha <----------->Cent

    if (from == UnitTypes.bigha && to == UnitTypes.cent) {
      return (value * 61.996589);
    }
    if (from == UnitTypes.cent && to == UnitTypes.bigha) {
      return (value * 0.016130);
    }
    //Bigha <----------->Katha

    if (from == UnitTypes.bigha && to == UnitTypes.katha) {
      return (value * 19.838353);
    }
    if (from == UnitTypes.katha && to == UnitTypes.bigha) {
      return (value * 0.050407);
    }
    //Cent <----------->Katha

    if (from == UnitTypes.cent && to == UnitTypes.katha) {
      return (value * 0.319991);
    }
    if (from == UnitTypes.katha && to == UnitTypes.cent) {
      return (value * 3.125087);
    }
    //Cent <----------->Guntha

    if (from == UnitTypes.cent && to == UnitTypes.guntha) {
      return (value * 0.399915);
    }
    if (from == UnitTypes.guntha && to == UnitTypes.cent) {
      return (value * 2.500529);
    }
    //Katha <----------->Guntha

    if (from == UnitTypes.katha && to == UnitTypes.guntha) {
      return (value * 1.249770);
    }
    if (from == UnitTypes.guntha && to == UnitTypes.katha) {
      return (value * 0.800147);
    }
    if (from == to) {
      return value;
    }
  }
}
