import 'package:flutter/material.dart';

class Drug {
  final String name;
  final String dosage;
  final List<TimeOfDay> times;
  final List<bool> days;

  Drug(
      {required this.name,
      required this.dosage,
      required this.times,
      required this.days});
}
