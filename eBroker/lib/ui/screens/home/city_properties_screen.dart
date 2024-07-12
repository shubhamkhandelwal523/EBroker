import 'package:flutter/material.dart';

class CityPropertiesScreen extends StatefulWidget {
  final String cityName;

  const CityPropertiesScreen({super.key, required this.cityName});

  @override
  State<CityPropertiesScreen> createState() => _CityPropertiesScreenState();
}

class _CityPropertiesScreenState extends State<CityPropertiesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
