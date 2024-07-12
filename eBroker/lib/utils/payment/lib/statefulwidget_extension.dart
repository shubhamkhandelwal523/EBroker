import 'package:flutter/material.dart';

extension LazyNavigaton on StatefulWidget {
  open(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return this;
      },
    ));
  }
}
