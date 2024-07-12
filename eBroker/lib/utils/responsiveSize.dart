// ignore_for_file: file_names

import 'package:flutter/material.dart';

//Warning Don't Edit or change this file otherwise your whole UI will get error

extension Sizing on num {
  ///Responsive height
  double rh(context) {
    //!Don't change [812]
    const double aspectedScreenHeight = 812;

    Size size = MediaQuery.of(context).size;
    double responsiveHeight = size.height * (this / aspectedScreenHeight);
    return responsiveHeight;
  }

  ///Responsive width
  double rw(context) {
    //!Don't change  [375]
    const double aspectedScreenWidth = 375;

    Size size = MediaQuery.of(context).size;
    double responsiveWidth = size.width * (this / aspectedScreenWidth);
    return responsiveWidth;
  }

  ///Responsive font
  double rf(context) {
    const double aspectedScreenHeight = 812;
    return (this / aspectedScreenHeight) * MediaQuery.of(context).size.height;
  }
}
