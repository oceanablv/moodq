import 'package:flutter/material.dart';

class GoalModel {
  final int id;
  final String title;
  final String desc;
  final IconData icon;
  bool isSelected;

  GoalModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    this.isSelected = false,
  });
}