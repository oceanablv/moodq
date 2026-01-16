import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart'; // Pastikan file theme.dart ada di project Anda
import '../models/journal_model.dart';
import '../controllers/journal_controller.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  // --- STATE UTAMA ---
  final TextEditingController _searchController = TextEditingController();
  final JournalController _journalController = JournalController();
  
  late Future<List<JournalModel>> _journalsFuture;
  
  String? currentUserId;
  bool isLoadingUser = true;

  // Filter Dummy (Visual Saja)
  final List<String> _filters = [
    "gratitude", "morning", "meditation", "work", "anxiety", "achievement"
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    // Langsung panggil data jurnal saat inisialisasi
    _journalsFuture = _journalController.getJournals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUserId = prefs.getString('id'); 
        isLoadingUser = false;
      });
    }
  }

  void _refreshJournals() {
    setState(() {
      _journalsFuture = _journalController.getJournals();
    });
  }

  // --- BUKA FORM TAMBAH ---
  Future<void> _showAddJournalSheet(BuildContext context) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Menggunakan Widget Terpisah agar Controller aman
      builder: (context) => const AddJournalSheet(),
    );
    
    // Refresh list setelah popup ditutup
    _refreshJournals();
  }

  // --- BUKA FORM EDIT ---
  Future<void> _showEditJournalSheet(BuildContext context, JournalModel journal) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Menggunakan Widget Terpisah agar Controller aman
      builder: (context) => EditJournalSheet(journal: journal),
    );
    
    // Refresh list setelah popup ditutup
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, 
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Journal", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("Your personal space", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                      // Tombol Tambah (+)
                      Container(
                        width: 45, height: 45,
                        decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () => _showAddJournalSheet(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search entries...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true, fillColor: const Color(0xFF151C2F),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((tag) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFF151C2F), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                          child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // LIST JOURNAL
            Expanded(
              child: FutureBuilder<List<JournalModel>>(
                future: _journalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book_outlined, size: 60, color: Colors.grey[700]),
                          const SizedBox(height: 10),
                          const Text("No entries yet.", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  final journals = snapshot.data!;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    itemCount: journals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final journal = journals[index];
                      List<String> parsedTags = [];
                      if (journal.tags != null && journal.tags!.isNotEmpty) {
                        parsedTags = journal.tags!.split(',');
                      }

                      return _buildJournalCard(
                        journalId: journal.id,
                        title: journal.title ?? "Untitled",
                        date: journal.createdAt ?? "",
                        content: journal.content ?? "",
                        tags: parsedTags,
                        isPrivate: journal.isPrivate ?? false,
                        journalModel: journal, // Kirim model lengkap untuk keperluan Edit
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CARD JURNAL ---
  Widget _buildJournalCard({
    int? journalId, 
    required String title, 
    required String date, 
    required String content, 
    required List<String> tags, 
    bool isPrivate = false, 
    JournalModel? journalModel
  }) {
    String displayDate = date.length >= 10 ? date.substring(0, 10) : date;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2F), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul & Icon
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPrivate) ...[
                      const Icon(Icons.lock_outline, size: 16, color: Colors.grey), 
                      const SizedBox(height: 4)
                    ],
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              
              // Tanggal & Tombol Aksi
              Row(
                children: [
                  Text(displayDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 8),
                  
                  // EDIT BUTTON
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white70),
                    onPressed: (isLoadingUser || journalModel == null) 
                        ? null 
                        : () => _showEditJournalSheet(context, journalModel),
                  ),

                  // DELETE BUTTON
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: (isLoadingUser || journalId == null) ? null : () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF151C2F),
                          title: const Text('Delete Journal', style: TextStyle(color: Colors.white)),
                          content: const Text('Are you sure you want to delete this journal?', style: TextStyle(color: Colors.grey)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        bool ok = await _journalController.deleteJournal(journalId);
                        if (ok && mounted) {
                          _refreshJournals();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal deleted'), backgroundColor: Colors.green));
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red));
                        }
                      }
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[400], height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          if (tags.isNotEmpty)
          Wrap(
            spacing: 8, runSpacing: 8,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF2A2A3C), borderRadius: BorderRadius.circular(8)),
                child: Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// CLASS TERPISAH: ADD JOURNAL SHEET (SOLUSI CRASH)
// =========================================================================
class AddJournalSheet extends StatefulWidget {
  const AddJournalSheet({super.key});

  @override
  State<AddJournalSheet> createState() => _AddJournalSheetState();
}

class _AddJournalSheetState extends State<AddJournalSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final JournalController _journalController = JournalController();

  String selectedInspiration = "";
  List<String> selectedTags = ["personal"]; 
  bool isPrivate = true; 
  bool isSaving = false;

  final List<String> availableTags = ["personal", "work", "gratitude", "reflection", "goals"];
  final List<String> inspirationPrompts = [
    "What are three things I'm grateful for today?",
    "How did I grow or learn today?",
    "What challenged me today?",
  ];

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _titleController.text = prefs.getString('journal_draft_title') ?? "";
        _contentController.text = prefs.getString('journal_draft_content') ?? "";
      });
    }
    // Auto-save draft
    _titleController.addListener(() => prefs.setString('journal_draft_title', _titleController.text));
    _contentController.addListener(() => prefs.setString('journal_draft_content', _contentController.text));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi konten dulu!"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => isSaving = true);

    bool success = await _journalController.addJournal(
      _titleController.text.isEmpty ? "Untitled" : _titleController.text,
      _contentController.text,
      selectedTags.join(','),
      isPrivate,
    );

    if (mounted) {
      setState(() => isSaving = false);
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('journal_draft_title');
        prefs.remove('journal_draft_content');
        Navigator.pop(context); // Tutup Sheet
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jurnal Berhasil Disimpan!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0B1221), 
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("New Journal Entry", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inspirasi
                  const Text("Need inspiration?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Column(children: inspirationPrompts.map((prompt) => GestureDetector(
                    onTap: () => setState(() { selectedInspiration = prompt; _contentController.text = "$prompt\n\n"; }),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151C2F),
                        borderRadius: BorderRadius.circular(12),
                        border: selectedInspiration == prompt ? Border.all(color: AppTheme.primaryColor) : null,
                      ),
                      child: Text(prompt, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  )).toList()),
                  const SizedBox(height: 20),

                  // Form Input
                  const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  TextField(controller: _titleController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Title...", hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: const Color(0xFF151C2F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 20),
                  
                  const Text("Content", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  TextField(controller: _contentController, maxLines: 5, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "What's on your mind?", hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: const Color(0xFF151C2F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 20),
                  
                  // Tags
                  const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: availableTags.map((tag) => GestureDetector(
                    onTap: () => setState(() => selectedTags.contains(tag) ? selectedTags.remove(tag) : selectedTags.add(tag)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedTags.contains(tag) ? AppTheme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selectedTags.contains(tag) ? AppTheme.primaryColor : Colors.grey[700]!),
                      ),
                      child: Text(tag, style: TextStyle(color: selectedTags.contains(tag) ? Colors.black : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  )).toList()),
                  const SizedBox(height: 20),
                  
                  // Privacy
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF151C2F), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(isPrivate ? Icons.lock_outline : Icons.public, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(isPrivate ? "Private entry" : "Shareable entry", style: const TextStyle(color: Colors.white)),
                      const Spacer(),
                      Switch(value: isPrivate, onChanged: (val) => setState(() => isPrivate = val), activeThumbColor: AppTheme.primaryColor)
                    ]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Text("Save Entry", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// CLASS TERPISAH: EDIT JOURNAL SHEET (MENCEGAH ERROR SAMA)
// =========================================================================
class EditJournalSheet extends StatefulWidget {
  final JournalModel journal;
  const EditJournalSheet({super.key, required this.journal});

  @override
  State<EditJournalSheet> createState() => _EditJournalSheetState();
}

class _EditJournalSheetState extends State<EditJournalSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final JournalController _journalController = JournalController();

  List<String> selectedTags = [];
  bool isPrivate = true;
  bool isSaving = false;
  final List<String> availableTags = ["personal", "work", "gratitude", "reflection", "goals"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.journal.title ?? "");
    _contentController = TextEditingController(text: widget.journal.content ?? "");
    if (widget.journal.tags != null && widget.journal.tags!.isNotEmpty) {
      selectedTags = widget.journal.tags!.split(',');
    }
    isPrivate = widget.journal.isPrivate ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi konten dulu!"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => isSaving = true);
    
    bool success = await _journalController.updateJournal(
      widget.journal.id!,
      _titleController.text.isEmpty ? "Untitled" : _titleController.text,
      _contentController.text,
      selectedTags.join(','),
      isPrivate,
    );

    if (mounted) {
      setState(() => isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jurnal berhasil diperbarui"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memperbarui"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Color(0xFF0B1221), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Edit Journal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                TextField(controller: _titleController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Title...", hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: const Color(0xFF151C2F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 20),
                const Text("Content", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                TextField(controller: _contentController, maxLines: 5, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "What's on your mind?", hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: const Color(0xFF151C2F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 20),
                const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: availableTags.map((tag) => GestureDetector(
                  onTap: () => setState(() => selectedTags.contains(tag) ? selectedTags.remove(tag) : selectedTags.add(tag)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: selectedTags.contains(tag) ? AppTheme.primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: selectedTags.contains(tag) ? AppTheme.primaryColor : Colors.grey[700]!)),
                    child: Text(tag, style: TextStyle(color: selectedTags.contains(tag) ? Colors.black : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                )).toList()),
                const SizedBox(height: 20),
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF151C2F), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(isPrivate ? Icons.lock_outline : Icons.public, color: Colors.white, size: 20), const SizedBox(width: 12), Text(isPrivate ? "Private entry" : "Shareable entry", style: const TextStyle(color: Colors.white)), const Spacer(), Switch(value: isPrivate, onChanged: (val) => setState(() => isPrivate = val), activeThumbColor: AppTheme.primaryColor)])),
              ]),
            ),
          ),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: isSaving ? null : _handleUpdate, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Text("Update Entry", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))))
        ],
      ),
    );
  }
}