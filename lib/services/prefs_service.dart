// Import library SharedPreferences untuk penyimpanan key-value sederhana
import 'package:shared_preferences/shared_preferences.dart';

// Kelas PrefsService bertanggung jawab untuk mengelola preferensi pengguna
// Menggunakan SharedPreferences untuk penyimpanan lokal persistent
class PrefsService {
  // Konstanta untuk key penyimpanan mode tema
  static const String _themeKey = 'isDarkMode';

  // Method untuk menyimpan mode tema (true untuk dark, false untuk light)
  // Parameter isDark adalah boolean yang menunjukkan apakah mode gelap aktif
  Future<void> saveThemeMode(bool isDark) async {
    // Mendapatkan instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Menyimpan boolean dengan key _themeKey
    await prefs.setBool(_themeKey, isDark);
  }

  // Method untuk mendapatkan mode tema yang tersimpan
  // Mengembalikan bool: true jika dark mode, false jika light mode
  Future<bool> getThemeMode() async {
    // Mendapatkan instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Mengambil boolean dengan key _themeKey, default false jika belum ada
    return prefs.getBool(_themeKey) ?? false; // Default false (Light mode)
  }
}
