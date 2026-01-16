import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../controllers/practice_controller.dart'; // Import Controller

class BoxBreathingPage extends StatefulWidget {
  const BoxBreathingPage({super.key});

  @override
  State<BoxBreathingPage> createState() => _BoxBreathingPageState();
}

class _BoxBreathingPageState extends State<BoxBreathingPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  // Logic Variables
  bool isActive = false;
  String instruction = "Ready";
  int counter = 4;
  int phaseIndex = 0; // 0: Inhale, 1: Hold, 2: Exhale, 3: Hold
  
  // Session Timer (5 Menit default)
  Timer? _sessionTimer;
  int _remainingTime = 300; // 5 menit dalam detik
  int _timeSpent = 0; // Variabel untuk mencatat waktu yang dilalui

  // Controller untuk Database
  final PracticeController _practiceController = PracticeController();

  // Animation Controller untuk Lingkaran
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  Timer? _breathingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Setup Animasi (Durasi 4 detik untuk inhale/exhale)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Jika user keluar saat masih aktif, catat waktu terakhir
    if (isActive) {
      _practiceController.logPracticeTime(_timeSpent, "Stopped");
    }
    WidgetsBinding.instance.removeObserver(this);
    _scaleController.dispose();
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App sent to background — if session aktif, log it as Paused and stop timers
      if (isActive) {
        _practiceController.logPracticeTime(_timeSpent, "Paused");
        _sessionTimer?.cancel();
        _breathingTimer?.cancel();
        _scaleController.stop();
        setState(() {
          isActive = false;
          instruction = "Paused";
        });
      }
    }
  }

  // Format Waktu (MM:SS)
  String get _timerString {
    final minutes = (_remainingTime / 60).floor();
    final seconds = _remainingTime % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- LOGIC UTAMA BREATHING ---
  void _startBreathing() {
    setState(() {
      isActive = true;
      instruction = "Breathe in";
      phaseIndex = 0;
      counter = 4;
    });

    _scaleController.forward(); // Mulai membesar
    _runPhaseLogic();
    _startSessionTimer();
  }

  void _stopBreathing() {
    setState(() {
      isActive = false;
      instruction = "Paused";
    });
    _scaleController.stop();
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();

    // Catat ke database saat di-pause/stop manual
    _practiceController.logPracticeTime(_timeSpent, "Stopped");
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
          _timeSpent++; // Hitung durasi latihan
        });
      } else {
        _stopBreathingManual(); // Fungsi stop tanpa log ganda
        // Selesai penuh: Catat ke database
        _practiceController.logPracticeTime(_timeSpent, "Completed");
      }
    });
  }

  // Fungsi pembantu untuk menghentikan timer tanpa memicu log "Stopped"
  void _stopBreathingManual() {
    setState(() {
      isActive = false;
      instruction = "Finished";
    });
    _scaleController.stop();
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();
  }

  void _runPhaseLogic() {
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 1) {
          counter--;
        } else {
          // Pindah Fase
          counter = 4;
          phaseIndex = (phaseIndex + 1) % 4;
          _handlePhaseChange();
        }
      });
    });
  }

  void _handlePhaseChange() {
    switch (phaseIndex) {
      case 0: // Inhale
        instruction = "Breathe in";
        _scaleController.forward(); 
        break;
      case 1: // Hold (Full)
        instruction = "Hold";
        break;
      case 2: // Exhale
        instruction = "Breathe out";
        _scaleController.reverse(); 
        break;
      case 3: // Hold (Empty)
        instruction = "Hold";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Box Breathing",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  Text(
                    "$_timerString remaining",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _remainingTime / 300,
                    backgroundColor: Colors.grey[800],
                    color: AppTheme.primaryColor,
                    minHeight: 4,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- ANIMATION CIRCLE ---
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 2),
                  ),
                ),
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          border: Border.all(color: AppTheme.primaryColor, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ]
                        ),
                      ),
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.air, size: 40, color: Color(0xFFFA8072)),
                    const SizedBox(height: 10),
                    Text(
                      instruction,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isActive ? "$counter" : "Start",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Text("Follow the circle's movement", style: TextStyle(color: Colors.grey)),
            const Spacer(),

            // --- BOTTOM CONTROLS ---
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: AppTheme.cardColor, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        _stopBreathing();
                        setState(() {
                          _remainingTime = 300;
                          _timeSpent = 0; // Reset durasi
                          counter = 4;
                          phaseIndex = 0;
                          instruction = "Ready";
                          _scaleController.reset();
                        });
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isActive ? _stopBreathing : _startBreathing,
                      icon: Icon(isActive ? Icons.pause : Icons.play_arrow, color: Colors.black),
                      label: Text(
                        isActive ? "Pause" : "Start",
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}