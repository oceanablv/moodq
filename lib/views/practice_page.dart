import 'package:flutter/material.dart';
import 'package:ref2_testing_moodq/views/box_breath.dart';
import '../theme.dart';
import '../controllers/practice_controller.dart';
import '../models/practice_model.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final List<String> categories = ["All", "Breathing", "Mindfulness", "Grounding", "Sleep"];
  String selectedCategory = "All";

  final PracticeController _practiceController = PracticeController();

  void _showDASS21Modal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DASS21Questionnaire(controller: _practiceController, parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final practices = _practiceController.getPractices();
    final filteredPractices = selectedCategory == "All"
      ? practices
      : practices.where((p) => p.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Practices", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text("Guided exercises for your wellbeing", style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                ],
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: categories.map((cat) {
                  bool isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.white10),
                      ),
                      child: Text(cat, style: TextStyle(color: isSelected ? Colors.black : Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  if (selectedCategory == "All") ...[
                    _buildDASS21Card(),
                    const SizedBox(height: 20),
                    const Text("Exercises", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                  ],
                  ...filteredPractices.map((practice) => _buildPracticeCard(practice)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDASS21Card() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade800, Colors.teal.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.psychology, color: Colors.tealAccent, size: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                child: const Text("Questionnaire", style: TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Text("Mental Health Check (DASS-21)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text("Assess your levels of depression, anxiety, and stress.", style: TextStyle(color: Colors.teal.shade100, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showDASS21Modal(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.teal.shade900, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Start Assessment", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildPracticeCard(Practice practice) {
    return GestureDetector(
      onTap: () {
        if (practice.title == "Box Breathing") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BoxBreathingPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${practice.title} coming soon!")));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                  child: Icon(practice.icon, color: practice.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(practice.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(practice.duration, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(practice.desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                 Text(practice.category, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                 const SizedBox(width: 10),
                 Text(practice.tag, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DASS21Questionnaire extends StatefulWidget {
  final PracticeController controller;
  final BuildContext parentContext;
  const DASS21Questionnaire({super.key, required this.controller, required this.parentContext});
  @override
  State<DASS21Questionnaire> createState() => _DASS21QuestionnaireState();
}

class _DASS21QuestionnaireState extends State<DASS21Questionnaire> with WidgetsBindingObserver {
  late final List<String> questions;

  Map<int, int> answers = {};
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    questions = widget.controller.getDASSQuestions();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // no super call; observer method implemented here
    if (state == AppLifecycleState.paused) {
      // If user backgrounds app before finishing questionnaire, persist partial result
      if (answers.isNotEmpty && currentIndex < questions.length) {
        final int total = answers.values.fold(0, (s, v) => s + v);
        String category = "";
        if (total <= 14) {
          category = "Normal";
        } else if (total <= 25) category = "Moderate Stress";
        else category = "Severe Stress";
        widget.controller.saveDASSResult(total, category);
      }
    }
  }

  Future<void> _calculateAndSaveResult() async {
    final result = await widget.controller.processDASSAnswers(answers);
    final int totalScore = result['score'] as int;
    final String category = result['category'] as String;
    final bool suggest = result['suggest'] as bool;

    // Close the bottom sheet using the parent context to ensure proper navigator
    try {
      Navigator.pop(widget.parentContext);
    } catch (_) {
      Navigator.pop(context);
    }

    // Show the result dialog using the parent context so it appears above the scaffold
    _showResultDialogParent(totalScore, category, suggest);
  }

  void _showResultDialogParent(int score, String category, bool suggest) {
    showDialog(
      context: widget.parentContext,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Assessment Complete", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Score: $score", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Status: $category", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              suggest 
                ? "Your results indicate a higher stress level. We strongly recommend taking the 'Box Breathing' exercise now."
                : "Your results are within the normal range. Keep maintaining your mental wellbeing.",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          if (suggest)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(widget.parentContext, MaterialPageRoute(builder: (context) => const BoxBreathingPage()));
              },
              child: const Text("Take Box Breathing", style: TextStyle(color: AppTheme.primaryColor)),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Question ${currentIndex + 1}/${questions.length}", style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey))
            ],
          ),
          const SizedBox(height: 20),
          Text(questions[currentIndex], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          const Text("How much did this apply to you over the past week?", style: TextStyle(color: Colors.grey)),
          const Spacer(),
          _buildOption(0, "Did not apply to me at all"),
          _buildOption(1, "Applied to me to some degree"),
          _buildOption(2, "Applied to me to a considerable degree"),
          _buildOption(3, "Applied to me very much"),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildOption(int value, String text) {
    bool isSelected = answers[currentIndex] == value;
    return GestureDetector(
      onTap: () {
        setState(() => answers[currentIndex] = value);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (currentIndex < questions.length - 1) {
            setState(() => currentIndex++);
          } else {
            _calculateAndSaveResult();
          }
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey), color: isSelected ? AppTheme.primaryColor : Colors.transparent),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14))),
          ],
        ),
      ),
    );
  }
}