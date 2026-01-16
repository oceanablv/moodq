import 'package:flutter/material.dart';
import '../theme.dart';
import '../controllers/mood_controller.dart';

class MoodPopup extends StatefulWidget {
  const MoodPopup({super.key});

  @override
  State<MoodPopup> createState() => _MoodPopupState();
}

class _MoodPopupState extends State<MoodPopup> {
  final MoodController _controller = MoodController();
  
  // Controller untuk Input Teks (Notes)
  final TextEditingController _noteController = TextEditingController();
  
  // State untuk form
  double _intensity = 5.0;
  String _selectedLabel = "Neutral";
  int _selectedIndex = 2; 
  
  // Tambahan: Status Loading agar tombol tidak bisa dipencet 2x
  bool _isSaving = false; 

  final List<Map<String, dynamic>> _moods = [
    {"label": "Terrible", "emoji": "😢", "color": Colors.red},
    {"label": "Bad", "emoji": "😕", "color": Colors.orange},
    {"label": "Neutral", "emoji": "😐", "color": Colors.yellow},
    {"label": "Good", "emoji": "😊", "color": Colors.lightGreen},
    {"label": "Excellent", "emoji": "🤩", "color": Colors.green},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    // Cegah double click
    if (_isSaving) return;

    setState(() {
      _isSaving = true; // Mulai loading
    });

    // Kirim data ke Controller
    // Use raw method to get server message for debugging and UI feedback
    final res = await _controller.addMoodRaw(
      _selectedLabel,
      _intensity,
      _noteController.text,
    );
    bool success = res['success'] == true;
    String serverMsg = res['message']?.toString() ?? '';

    if (!mounted) return;

    setState(() {
      _isSaving = false; // Selesai loading
    });

    if (success) {
      Navigator.pop(context, true); // Tutup popup dan refresh home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(serverMsg.isNotEmpty ? serverMsg : "Gagal menyimpan mood. Cek koneksi server."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, 
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B), 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              // Title
              const Text(
                "How are you feeling?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Emoji Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_moods.length, (index) {
                  bool isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                        _selectedLabel = _moods[index]['label'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? _moods[index]['color'].withOpacity(0.2) 
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected 
                            ? Border.all(color: _moods[index]['color'], width: 2) 
                            : null,
                      ),
                      child: Text(
                        _moods[index]['emoji'],
                        style: TextStyle(fontSize: isSelected ? 32 : 24),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              Text(
                _selectedLabel,
                style: TextStyle(
                  color: _moods[_selectedIndex]['color'],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Slider Intensity
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Intensity", style: TextStyle(color: Colors.grey)),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.white,
                  overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                ),
                child: Slider(
                  value: _intensity,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: _intensity.round().toString(),
                  onChanged: (value) {
                    setState(() => _intensity = value);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Field Notes
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Note (Optional)", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white), 
                maxLines: 3, 
                decoration: InputDecoration(
                  hintText: "Why do you feel this way?",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.black12, 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveMood, // Disable saat loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Tampilkan loading spinner jika sedang menyimpan
                      child: _isSaving 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                            )
                          : const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}