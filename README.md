# 🧠 MoodQ - Mental Health & Wellness App

MoodQ adalah aplikasi mobile yang dirancang untuk membantu pengguna memantau kesehatan mental, mengelola stres, dan meningkatkan kesejahteraan emosional melalui mood tracking, praktik mindfulness, dan analisis insight yang mendalam.

## 📋 Daftar Isi
- [Tentang Aplikasi](#tentang-aplikasi)
- [Teknologi yang Digunakan](#teknologi-yang-digunakan)
- [Fitur-Fitur](#fitur-fitur)
- [Instalasi](#instalasi)
- [Struktur Project](#struktur-project)
- [Kontribusi](#kontribusi)

---

## 📱 Tentang Aplikasi

MoodQ adalah solusi komprehensif untuk manajemen kesehatan mental dengan fitur:
- **Mood Tracking**: Catat mood dan intensitas emosi setiap hari
- **Analisis Insight**: Visualisasi tren mood dalam bentuk grafik dan statistik
- **Praktik Mindfulness**: Latihan pernapasan dan teknik relaksasi
- **Tes Psikologi**: DASS-21 untuk mengukur tingkat stress, anxiety, dan depression
- **Jurnal Digital**: Tulis catatan dan refleksi pribadi
- **Notifikasi**: Reminder harian untuk check-in mood
- **Manajemen Profil**: Kelola akun dan preferensi notifikasi

---

## 🛠️ Teknologi yang Digunakan

### Frontend Framework
- **Flutter** (Dart) - Framework UI untuk aplikasi mobile cross-platform

### State Management & Local Storage
- **Shared Preferences** - Penyimpanan data lokal untuk preferensi pengguna
- **ChangeNotifier** - State management untuk real-time UI updates

### HTTP & Networking
- **HTTP Package** - Komunikasi dengan backend API

### UI & Visualization
- **FL Chart** - Library grafik untuk visualisasi data mood
- **Material Design 3** - Design system modern

### Data & Utilities
- **Intl** - Internationalization dan formatting tanggal
- **CSV** - Export/import data dalam format CSV
- **Timezone** - Manajemen zona waktu untuk reminder

### Local Notifications
- **Flutter Local Notifications** - Notifikasi reminder harian
- **Timezone** - Penjadwalan notifikasi per zona waktu

### File Management
- **Path Provider** - Akses direktori lokal untuk file storage

### Sharing
- **Share Plus** - Berbagi data dan file dengan aplikasi lain

### Development Tools
- **Flutter Launcher Icons** - Konfigurasi icon aplikasi untuk Android/iOS

---

## ✨ Fitur-Fitur

### 🔐 Authentication & Security
- ✅ **Register/Sign Up** - Pendaftaran akun baru dengan validasi
- ✅ **Login** - Masuk dengan email dan password
- ✅ **Forgot Password** - Reset password via email
- ✅ **Change Password** - Ubah password untuk pengguna yang sudah login
- ✅ **Session Management** - Manajemen session pengguna yang aman

### 🎯 Mood Tracking
- ✅ **Daily Check-In** - Catat mood dengan 5 level (Excellent, Good, Neutral, Bad, Terrible)
- ✅ **Intensity Slider** - Atur intensitas emosi dari 1-10
- ✅ **Mood Notes** - Tambahkan catatan terkait mood
- ✅ **Mood History** - Lihat riwayat mood yang telah dicatat
- ✅ **Quick Edit/Delete** - Edit atau hapus mood entry sebelumnya

### 📊 Insight & Analytics
- ✅ **Mood Analytics** - Lihat statistik mood:
  - Average Intensity per mood
  - Total entries per mood
  - Dominant mood (mood yang paling sering)
  - Streak tracking (konsistensi check-in)
- ✅ **Interactive Charts** - Grafik real-time dengan:
  - Line chart untuk trend mood
  - Daily delta tracking
  - Multiple period views (All, Week, Month, Year)
- ✅ **Period Filtering** - Filter data berdasarkan timeframe

### 🧘 Mindfulness & Wellness Practices
- ✅ **Box Breathing** - Teknik pernapasan 4-4-4-4 untuk stress relief
- ✅ **4-7-8 Breathing** - Teknik untuk kualitas tidur lebih baik
- ✅ **Gratitude Practice** - Refleksi rasa syukur 3 menit
- ✅ **5-Senses Grounding** - Teknik grounding menggunakan 5 indera
- ✅ **Body Scan** - Relaksasi dari kepala hingga kaki (10 menit)
- ✅ **Practice Duration Logging** - Catat durasi latihan untuk tracking

### 📋 DASS-21 Assessment
- ✅ **Standardized Test** - Tes DASS-21 (Depression, Anxiety, Stress Scale)
- ✅ **21 Questions** - Pertanyaan terstandar untuk assessment
- ✅ **Auto-Categorization** - Hasil otomatis dalam kategori:
  - Normal (Score ≤ 14)
  - Moderate Stress (Score 15-25)
  - Severe Stress (Score > 25)
- ✅ **Smart Recommendations** - Saran latihan berdasarkan hasil tes
- ✅ **Result History** - Simpan dan lihat history hasil tes

### 📔 Digital Journal
- ✅ **Journal Entry** - Tulis jurnal pribadi
- ✅ **Entry Timestamps** - Waktu otomatis untuk setiap entry
- ✅ **View Journal Entries** - Lihat semua catatan jurnal
- ✅ **Mood-Linked Notes** - Hubungkan jurnal dengan mood entries

### 🔔 Smart Notifications
- ✅ **Daily Reminders** - Reminder check-in mood harian
- ✅ **Customizable Schedule** - Atur jam dan menit reminder
- ✅ **Reminder Types** - Pilih jenis reminder:
  - Mood check-in reminders
  - Practice reminders
  - Journal reminders
- ✅ **Persistent Settings** - Preferensi tersimpan di local storage
- ✅ **Toggle On/Off** - Aktifkan/nonaktifkan notifikasi kapan saja

### 👤 User Profile Management
- ✅ **Profile View** - Lihat informasi profil pengguna
- ✅ **Edit Profile** - Update data profil
- ✅ **Preference Settings** - Kelola preferensi aplikasi
- ✅ **Notification Settings** - Customize notifikasi
- ✅ **Data Management** - Lihat statistik penggunaan

### 🎓 Onboarding
- ✅ **Interactive Onboarding** - Tutorial untuk pengguna baru
- ✅ **Feature Introduction** - Pengenalan fitur aplikasi
- ✅ **Permission Requests** - Minta izin notifikasi
- ✅ **Skip Option** - Lewati onboarding jika sudah familiar

### 📤 Data Export
- ✅ **CSV Export** - Export mood data dalam format CSV
- ✅ **Share Feature** - Bagikan data dengan aplikasi lain

---

## 🚀 Coming Soon (Fitur Mendatang)

- 🔄 **Sync Cloud** - Sinkronisasi data ke cloud storage
- 🤖 **AI Insights** - Analisis AI untuk rekomendasi personal
- 👥 **Social Sharing** - Bagikan progress dengan teman (private)
- 🎵 **Meditation Audio** - Panduan audio untuk meditasi
- 🎮 **Gamification** - Achievement badges dan streak rewards
- 📊 **Advanced Analytics** - Predictive analysis untuk mood patterns
- 🌙 **Sleep Tracking** - Integrasi tracking kualitas tidur
- 💬 **Community Forum** - Diskusi dan support komunitas
- 🎨 **Customization** - Theme dan personalisasi UI
- 🔐 **Biometric Login** - Login dengan fingerprint/face ID
- 📱 **Web Dashboard** - Dashboard web untuk analisis detail
- 🌐 **Multi-Language** - Support bahasa internasional

---

## 💾 Instalasi

### Prerequisites
- Flutter SDK (versi 3.9.2 atau lebih baru)
- Dart SDK
- Android Studio atau Xcode (untuk emulator)

### Langkah-langkah
1. **Clone Repository**
   ```bash
   git clone https://github.com/yourusername/moodq.git
   cd moodq
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Launcher Icons**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Run Application**
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d web
   ```

---

## 📁 Struktur Project

```
lib/
├── main.dart                 # Entry point aplikasi
├── theme.dart               # Tema dan styling global
│
├── controllers/             # Business logic & state management
│   ├── auth_controller.dart
│   ├── mood_controller.dart
│   ├── insight_controller.dart
│   ├── practice_controller.dart
│   ├── journal_controller.dart
│   ├── profile_controller.dart
│   ├── login_controller.dart
│   ├── register_controller.dart
│   └── onboarding_controller.dart
│
├── models/                  # Data models
│   ├── mood_model.dart
│   ├── practice_model.dart
│   ├── journal_model.dart
│   ├── user_model.dart
│   ├── profile_model.dart
│   └── onboarding_model.dart
│
├── repositories/            # Data access layer
│   ├── mood_repository.dart
│   ├── notification_service.dart
│   └── session_service.dart
│
└── views/                   # UI Pages
    ├── welcome_page.dart
    ├── onboarding_page.dart
    ├── login_page.dart
    ├── register_page.dart
    ├── forgot_password_page.dart
    ├── change_password_page.dart
    ├── home_page.dart
    ├── mood_page.dart
    ├── insight_page.dart
    ├── practice_page.dart
    ├── box_breath.dart (Breathing exercise UI)
    ├── jurnal_page.dart
    ├── profile_page.dart
    └── welcome_page.dart
```

---

## 🔄 Architecture Pattern

MoodQ menggunakan **MVC (Model-View-Controller)** pattern dengan pemisahan yang jelas:

- **Models** - Data structures & API responses
- **Controllers** - Business logic & state management
- **Views** - UI components & pages
- **Repositories** - Data access & API communication

---

## 🔌 API Integration

Aplikasi terhubung dengan backend API untuk:
- Autentikasi (login, register, password reset)
- Penyimpanan mood data
- Pengambilan insights & statistik
- Logging practice sessions
- DASS-21 result storage

---

## 🎨 Design Features

- **Dark Theme** - Material Design 3 dengan dark mode
- **Responsive UI** - Adaptif untuk berbagai ukuran layar
- **Smooth Animations** - Transisi yang mulus antar halaman
- **Icon Integration** - Material icons untuk visual clarity
- **Color Psychology** - Warna dipilih untuk wellness experience

---

## 📞 Support & Contact

Untuk pertanyaan atau feedback:
- 📧 Email: [your-email@example.com]
- 🐛 Issues: [GitHub Issues Link]
- 💬 Discussions: [GitHub Discussions Link]

---

## 📄 Lisensi

Project ini dilisensikan di bawah MIT License - lihat file `LICENSE` untuk detailnya.

---

## 👏 Kontribusi

Kontribusi sangat diterima! Untuk berkontribusi:

1. Fork repository ini
2. Buat branch feature (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [DASS-21 Scale Info](https://www.dass21.net/)
- [Mindfulness Techniques](https://www.mindful.org/)

---

**MoodQ** - *Jaga Kesehatan Mental Anda, Satu Mood Pada Satu Waktu* 🧠💚

---

*Last Updated: January 2026*
*Version: 0.1.0*
