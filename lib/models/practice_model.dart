import 'package:flutter/material.dart';

class Practice {
  final String title;
  final String desc;
  final String category;
  final String duration;
  final IconData icon;
  final Color color;
  final String tag;

  Practice({
    required this.title,
    required this.desc,
    required this.category,
    required this.duration,
    required this.icon,
    required this.color,
    required this.tag,
  });
}

class DASSResult {
  final int totalScore;
  final String category;
  final DateTime createdAt;

  DASSResult({
    required this.totalScore,
    required this.category,
    required this.createdAt,
  });
}
