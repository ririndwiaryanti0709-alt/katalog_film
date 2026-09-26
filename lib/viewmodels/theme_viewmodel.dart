// Import library Flutter untuk ChangeNotifier
import 'package:flutter/material.dart';
// Import PrefsService untuk penyimpanan preferensi tema
import '../services/prefs_service.dart';

// Kelas ThemeViewModel mengelola state tema aplikasi (light/dark mode)
// Extends ChangeNotifier untuk notify listeners saat tema berubah
class ThemeViewModel extends ChangeNotifier {
  // Instance PrefsService untuk menyimpan/mengambil preferensi tema
  final PrefsService _prefsService = PrefsService();
  // Variabel private untuk menyimpan status dark mode
  bool _isDarkMode = false;

  // Getter untuk mendapatkan status dark mode
  bool get isDarkMode => _isDarkMode;

  // Konstruktor: load tema saat ViewModel dibuat
  ThemeViewModel() {
    // Panggil method private untuk load tema dari penyimpanan
    _loadTheme();
  }

  // Method private untuk load tema dari SharedPreferences
  Future<void> _loadTheme() async {
    // Ambil status tema dari PrefsService
    _isDarkMode = await _prefsService.getThemeMode();
    // Notify listeners untuk update UI
    notifyListeners();
  }

  // Method untuk toggle tema (light ke dark atau sebaliknya)
  Future<void> toggleTheme() async {
    // Toggle nilai _isDarkMode
    _isDarkMode = !_isDarkMode;
    // Simpan perubahan ke SharedPreferences
    await _prefsService.saveThemeMode(_isDarkMode);
    // Notify listeners untuk update UI
    notifyListeners();
  }
}
