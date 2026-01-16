import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../controllers/mood_controller.dart';
import '../controllers/profile_controller.dart'; 
import '../models/mood_model.dart';
import 'mood_page.dart';
import 'jurnal_page.dart';
import 'practice_page.dart';
import 'insight_page.dart'; 
import 'profile_page.dart';

class CrisisResource {
  final String title;
  final String contact;
  final String desc;
  CrisisResource({required this.title, required this.contact, required this.desc});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MoodController _moodController = MoodController();
  final ProfileController _profileController = ProfileController();

  // State Variables
  String userName = "Loading...";
  String moodEmoji = '😐';
  String recentMoodLabel = 'No Data';
  double recentMoodIntensity = 0.0;
  int totalEntries = 0;
  int streak = 0;
  bool isLoading = true;
  MoodModel? _latestMood;
  
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load cached data immediately after first frame so UI can paint fast,
    // then refresh from network. This avoids blocking the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  // --- LOGIKA LOAD DATA (VERSI PAKSA UPDATE) ---
  Future<void> _loadAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Read cached user display name immediately so UI can show it fast.
    String fullName = prefs.getString('name') ?? "Guest";
    String firstName = fullName.split(' ')[0];
    String? userId = prefs.getString('id');
    debugPrint('HomeScreen: cached data found for user id=$userId');

    if (mounted) {
      setState(() {
        userName = firstName; // show cached name immediately
        // keep isLoading true until network returns? set to false so content shows fast
        isLoading = false;
      });
    }

    // Load cached moods & stats to show numbers quickly (non-blocking)
    try {
      _moodController.getCachedMoodInsights('all').then((cachedMoods) {
        if (cachedMoods.isNotEmpty && mounted) {
          // Compute display values from cached data
          int finalTotal = cachedMoods.length;
          var latestMood = cachedMoods.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
          String finalLabel = latestMood.moodLabel ?? "Neutral";
          double finalIntensity = latestMood.intensity;
          int finalStreak = 1;
          setState(() {
            totalEntries = finalTotal;
            recentMoodLabel = finalLabel;
            recentMoodIntensity = finalIntensity;
            streak = finalStreak;
            moodEmoji = _moodController.getMoodEmoji(finalLabel);
          });
        }
      });
      _moodController.getCachedHomeStats().then((cachedStats) {
        if (cachedStats != null && mounted) {
          setState(() {
            totalEntries = cachedStats.totalEntries ?? totalEntries;
            streak = cachedStats.streak ?? streak;
            if ((recentMoodLabel == "No Data" || recentMoodIntensity == 0.0) && (cachedStats.moodLabel ?? '').isNotEmpty) {
              recentMoodLabel = cachedStats.moodLabel!;
              recentMoodIntensity = cachedStats.intensity;
              moodEmoji = _moodController.getMoodEmoji(recentMoodLabel);
            }
          });
        }
      });
    } catch (_) {}

    // 1. AMBIL LIST MOOD TERLEBIH DAHULU (SUMBER KEBENARAN)
    List<MoodModel> allMoods = await _moodController.getMoodInsights('all');
    debugPrint('HomeScreen: getMoodInsights returned ${allMoods.length} items');
    for (var m in allMoods) {
      debugPrint('  mood -> label:${m.moodLabel} intensity:${m.moodIntensity} createdAt:${m.createdAt}');
    }
    
    // 2. AMBIL STATS CUMA BUAT STREAK
    MoodModel? stats = await _moodController.getHomeStats();

    // Variable default
    int finalTotal = 0;
    int finalStreak = 0;
    String finalLabel = "No Data";
    double finalIntensity = 0.0;

    // 3. LOGIKA UTAMA: HITUNG DARI LIST BIAR AKURAT
    if (allMoods.isNotEmpty) {
      finalTotal = allMoods.length; // Hitung total dari list langsung

      // Pilih entry dengan tanggal paling baru (lebih robust daripada mengandalkan posisi list)
      try {
          var latestMood = allMoods.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
          _latestMood = latestMood;
        finalLabel = latestMood.moodLabel ?? "Neutral";
        finalIntensity = latestMood.intensity; // use robust getter from model
      } catch (_) {
        // Fallback: ambil terakhir jika reduce gagal
        var latestMood = allMoods.last;
        finalLabel = latestMood.moodLabel ?? "Neutral";
        finalIntensity = latestMood.intensity; // use robust getter
          _latestMood = latestMood;
      }
    } else if (stats != null) {
      // Jika API "insights" tidak mengembalikan list (mis. endpoint berbeda),
      // gunakan nilai statistik dari endpoint home stats sebagai fallback.
      finalTotal = stats.totalEntries ?? 0;
      if ((stats.moodLabel ?? '').isNotEmpty) {
        finalLabel = stats.moodLabel!;
        finalIntensity = stats.intensity;
      }
    }

    // 4. Ambil Streak dari API (karena hitung streak manual itu rumit)
    // Prefer authoritative total from stats when available. This prevents
    // mismatch when insights endpoint returns a partial list or different shape.
    if (stats != null) {
      finalTotal = stats.totalEntries ?? finalTotal;
      finalStreak = stats.streak ?? 0;
      // If stats provides a label/intensity but we didn't get list data,
      // use stats' last-known mood as fallback (label/intensity may be more
      // up-to-date in some backend implementations).
      if ((finalLabel == "No Data" || finalIntensity == 0.0) && (stats.moodLabel ?? '').isNotEmpty) {
        finalLabel = stats.moodLabel!;
        finalIntensity = stats.intensity;
      }
    } else if (finalTotal > 0) {
      finalStreak = 1; // Fallback minimal streak 1 kalau ada data
    }

    if (mounted) {
      setState(() {
        userName = firstName;
        isLoading = false;
        
        totalEntries = finalTotal;
        streak = finalStreak;
        recentMoodLabel = finalLabel;
        recentMoodIntensity = finalIntensity;
        
        // Update Emoji
        moodEmoji = _moodController.getMoodEmoji(finalLabel);
      });
    }
  }

  // --- UI: CRISIS MODAL ---
  void _showCrisisSupportModal() {
    final List<CrisisResource> resources = [
      CrisisResource(title: "Layanan SEJIWA", contact: "119", desc: "Layanan Psikologi untuk Sehat Jiwa"),
      CrisisResource(title: "Panggilan Darurat", contact: "112", desc: "Polisi, Ambulans, Damkar"),
      CrisisResource(title: "Halo Kemenkes", contact: "1500567", desc: "Informasi kesehatan"),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppTheme.background, 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Crisis Support", style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final res = resources[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(res.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(res.desc, style: const TextStyle(color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone, color: Colors.greenAccent),
                        onPressed: () => _profileController.makePhoneCall(res.contact),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadAllData();
  }

  void _openMoodPopup() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const MoodPopup(), 
    );
    if (result == true) {
      _loadAllData(); // Refresh data setelah input
    }
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi, $userName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text("How are you feeling today?", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                InkWell(
                  onTap: () => _onItemTapped(4),
                  child: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Daily Check-in
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Daily Check-in", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text("Take a moment to track\nyour mood", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _openMoodPopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Check In", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BANNER CALL CENTER (Sudah dipastikan ada)
            _buildEmergencyBanner(),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard("$streak", "Day Streak", "🔥 Keep it up!")),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard("$totalEntries", "Total Entries", "All time")),
              ],
            ),
            const SizedBox(height: 20),

            // Recent Mood Trend
            _buildMoodTrendCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildEmergencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("Need immediate support?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: _showCrisisSupportModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text("Get Help"),
          )
        ],
      ),
    );
  }

  Widget _buildMoodTrendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Recent Mood Trend", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text("$moodEmoji $recentMoodLabel", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          const SizedBox(width: 8),
                          if (_latestMood != null) ...[
                            IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.white70), onPressed: () => _showEditLatestMood(context)),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: () async {
                              if (_latestMood == null) return;
                              bool? confirm = await showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF151C2F), title: const Text('Delete Mood', style: TextStyle(color: Colors.white)), content: const Text('Delete the latest mood entry?', style: TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent)))],));
                              if (confirm == true) {
                                bool ok = await _moodController.deleteMood(_latestMood!.id ?? '');
                                if (ok) { if(!mounted) return; _loadAllData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mood deleted'), backgroundColor: Colors.green)); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red)); }
                              }
                            }),
                          ]
                        ]),
                        Text("Intensity: ${recentMoodIntensity.toStringAsFixed(1)}/10", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Text("$totalEntries entries\nlogged", textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.grey))
                  ],
                )
              ],
            ),
    );
  }

  void _showEditLatestMood(BuildContext context) {
    if (_latestMood == null) return;
    final mood = _latestMood!;

    TextEditingController noteController = TextEditingController(text: mood.note ?? '');
    double intensity = mood.intensity;
    String selectedLabel = mood.moodLabel ?? 'Neutral';
    bool isSaving = false;

    final List<Map<String, dynamic>> moodsList = [
      {"label": "Terrible", "emoji": "😢", "color": Colors.red},
      {"label": "Bad", "emoji": "😕", "color": Colors.orange},
      {"label": "Neutral", "emoji": "😐", "color": Colors.yellow},
      {"label": "Good", "emoji": "😊", "color": Colors.lightGreen},
      {"label": "Excellent", "emoji": "🤩", "color": Colors.green},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF1B263B), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text("Edit Mood", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(moodsList.length, (index) {
                    bool isSelected = selectedLabel == moodsList[index]['label'];
                    return GestureDetector(onTap: () => setState(() { selectedLabel = moodsList[index]['label']; }), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isSelected ? moodsList[index]['color'].withOpacity(0.2) : Colors.transparent, shape: BoxShape.circle, border: isSelected ? Border.all(color: moodsList[index]['color'], width: 2) : null), child: Text(moodsList[index]['emoji'], style: TextStyle(fontSize: isSelected ? 32 : 24))));
                  })),
                  const SizedBox(height: 16),
                  Text(selectedLabel, style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  Slider(value: intensity, min: 0, max: 10, divisions: 10, label: intensity.round().toString(), onChanged: (v) => setState(() => intensity = v)),
                  const SizedBox(height: 8),
                  TextField(controller: noteController, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Note (optional)", hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: Colors.black12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(12))),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey)))),
                    Expanded(child: ElevatedButton(onPressed: isSaving ? null : () async {
                      setState(() { isSaving = true; });
                      bool ok = await _moodController.updateMood(mood.id ?? '', selectedLabel, intensity, noteController.text);
                      setState(() { isSaving = false; });
                      if (ok) { if(!mounted) return; Navigator.pop(context); _loadAllData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mood updated'), backgroundColor: Colors.green)); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update'), backgroundColor: Colors.red)); }
                    }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.black), child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Text('Update')))
                  ])
                ]),
              ),
            ),
          );
        });
      }
    );
  }

  Widget _buildStatCard(String value, String label, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(sub, style: const TextStyle(fontSize: 12, color: Colors.orange)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List halaman tetap sama
    final List<Widget> pages = [
      _buildHomeContent(),
      JournalPage(),
      PracticePage(),
      InsightPage(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      
      body: SafeArea(
        // Langsung panggil halaman berdasarkan index.
        // Ini memaksa halaman dibuat ulang (refresh) setiap ganti tab.
        child: pages[_selectedIndex], 
      ),
      // -----------------------------------------------

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Practices"),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: "Insights"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}