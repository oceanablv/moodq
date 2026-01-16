import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';

class OnboardingController {
  
  final List<GoalModel> _goals = [
    GoalModel(id: 1, title: "Manage Stress", desc: "Handle daily pressure", icon: Icons.psychology),
    GoalModel(id: 2, title: "Emotional Awareness", desc: "Understand feelings", icon: Icons.favorite),
    GoalModel(id: 3, title: "Better Sleep", desc: "Improve sleep quality", icon: Icons.nightlight_round),
    GoalModel(id: 4, title: "Daily Mindfulness", desc: "Consistent practice", icon: Icons.bolt),
    GoalModel(id: 5, title: "Journaling Habit", desc: "Express thoughts", icon: Icons.edit_note),
    GoalModel(id: 6, title: "Anxiety Support", desc: "Tools for anxiety", icon: Icons.accessibility_new),
  ];

  List<GoalModel> get goals => _goals;
  void toggleGoal(int index) {
    _goals[index].isSelected = !_goals[index].isSelected;
  }
  bool isGoalsValid() {
    return _goals.any((element) => element.isSelected);
  }
  List<String> getSelectedGoals() {
    return _goals
        .where((g) => g.isSelected)
        .map((g) => g.title)
        .toList();
  }
  
}