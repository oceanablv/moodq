import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/journal_model.dart';
import 'auth_controller.dart';

class JournalController {
  
  // Mengatur URL API agar bisa jalan di Android Emulator (10.0.2.2) dan Web/Chrome (localhost)
  static String get baseUrl {
    return AuthController.baseUrl;
  }

  // Helper untuk mengambil ID user yang sedang login dari session
  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  // --- GET JOURNALS ---
  // Mengambil daftar jurnal dari database berdasarkan user_id
  Future<List<JournalModel>> getJournals() async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return [];

      final uri = Uri.parse('$baseUrl/get_journals.php?user_id=$userId');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint('getJournals GET: ${uri.toString()} -> ${response.statusCode}');
      debugPrint('getJournals body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> items = [];
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
          items = decoded['data'];
        } else {
          debugPrint('getJournals: unexpected response format');
        }

        final list = items.map((e) => JournalModel.fromJson(e)).toList();
        // cache raw response
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_journals', response.body);
        } catch (_) {}
        return list;
      }
      return [];
    } catch (e) {
      debugPrint("Error getJournals: $e");
      return [];
    }
  }

  Future<List<JournalModel>> getCachedJournals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_journals');
      if (raw == null) return [];
      final decoded = jsonDecode(raw);
      List<dynamic> items = [];
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) items = decoded['data'];
      else {
        debugPrint('getCachedJournals: unexpected cached format');
        return [];
      }
      return items.map((e) => JournalModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getCachedJournals: $e');
      return [];
    }
  }

  // --- ADD JOURNAL ---
  // Menambah jurnal baru ke database termasuk status is_private
  Future<bool> addJournal(String title, String content, String tags, bool isPrivate) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/add_journal.php'),
        body: {
          'user_id': userId,
          'title': title,
          'content': content,
          'tags': tags,
          // Kirim status private ke PHP (1 = private, 0 = public)
          'is_private': isPrivate ? '1' : '0', 
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint("Error addJournal: $e");
      return false;
    }
  }

  // --- EXPORT DATA KE CSV ---
  // Mengambil data jurnal, mengonversi ke CSV, dan membagikan filenya
 Future<void> exportJournalsToCSV() async {
    try {
      // 1. Ambil data terbaru dari database
      // Pastikan fungsi getJournals() mengembalikan List<JournalModel>
      List<JournalModel> journals = await getJournals(); 
      
      if (journals.isEmpty) {
        debugPrint("Data jurnal kosong, tidak ada yang diexport.");
        return;
      }

      // 2. Susun String CSV secara Manual (Lebih aman tanpa plugin tambahan)
      StringBuffer csvBuffer = StringBuffer();
      
      // Tambahkan Header
      csvBuffer.writeln("ID,Title,Content,Tags,Created At");

      // Tambahkan Data
      for (var j in journals) {
        // Sanitasi data: Hapus enter dan bungkus dengan tanda kutip
        // agar koma di dalam teks tidak merusak format CSV
        String safeTitle = '"${(j.title ?? '').replaceAll('"', '""')}"';
        String safeContent = '"${(j.content ?? '').replaceAll('"', '""')}"';
        String safeTags = '"${(j.tags ?? '').replaceAll('"', '""')}"';
        String safeDate = j.createdAt ?? '';

        csvBuffer.writeln('${j.id},$safeTitle,$safeContent,$safeTags,$safeDate');
      }

      String csvString = csvBuffer.toString();
      String fileName = 'moodq_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      // 3. LOGIKA PENYIMPANAN (CROSS-PLATFORM)
      if (kIsWeb) {
        // --- LOGIKA WEB (Download) ---
        // Di Web, kita buat file langsung dari memori (bytes)
        await Share.shareXFiles(
          [
            XFile.fromData(
              utf8.encode(csvString),
              name: fileName,
              mimeType: 'text/csv',
            ),
          ],
          text: 'My MoodQ Journal Export',
        );
      } else {
        // --- LOGIKA MOBILE (Android/iOS) ---
        // Di HP, simpan ke file sistem dulu baru di-share
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/$fileName";
        final file = File(path);
        
        await file.writeAsString(csvString);

        await Share.shareXFiles(
          [XFile(path)],
          text: 'My MoodQ Journal Export',
        );
      }
      
      debugPrint("Export berhasil!");

    } catch (e) {
      debugPrint("Export Error: $e");
    }
  }

  // --- DELETE JOURNAL ---
  Future<bool> deleteJournal(int journalId) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/delete_journal.php'),
        body: {
          'user_id': userId,
          'journal_id': journalId.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleteJournal: $e');
      return false;
    }
  }

  // --- UPDATE JOURNAL ---
  Future<bool> updateJournal(int journalId, String title, String content, String tags, bool isPrivate) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/update_journal.php'),
        body: {
          'user_id': userId,
          'journal_id': journalId.toString(),
          'title': title,
          'content': content,
          'tags': tags,
          'is_private': isPrivate ? '1' : '0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error updateJournal: $e');
      return false;
    }
  }
}