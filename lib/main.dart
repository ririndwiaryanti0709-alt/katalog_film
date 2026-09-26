// Import library Flutter untuk widget dan material design
import 'package:flutter/material.dart';
// Import library Provider untuk state management
import 'package:provider/provider.dart';
// Import library Google Fonts untuk font Poppins
import 'package:google_fonts/google_fonts.dart';
// Import ViewModel untuk Movie (logika bisnis film)
import 'viewmodels/movie_viewmodel.dart';
// Import ViewModel untuk Theme (logika pengaturan tema)
import 'viewmodels/theme_viewmodel.dart';
// Import layar utama aplikasi
import 'views/main_screen.dart';

// Fungsi utama yang merupakan entry point aplikasi Flutter
// Fungsi ini dipanggil pertama kali saat aplikasi dimulai
void main() {
  // Menjalankan aplikasi dengan widget MultiProvider
  // MultiProvider menyediakan beberapa provider untuk state management
  runApp(
    // MultiProvider untuk menyediakan MovieViewModel dan ThemeViewModel ke seluruh aplikasi
    MultiProvider(
      // Daftar provider yang akan disediakan
      providers: [
        // Provider untuk MovieViewModel, dibuat dengan ChangeNotifierProvider
        // ChangeNotifierProvider mendengarkan perubahan dari MovieViewModel
        ChangeNotifierProvider(create: (_) => MovieViewModel()),
        // Provider untuk ThemeViewModel, dibuat dengan ChangeNotifierProvider
        // ChangeNotifierProvider mendengarkan perubahan dari ThemeViewModel
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      // Child adalah widget utama aplikasi
      child: const MyApp(),
    ),
  );
}

// Kelas MyApp adalah widget utama aplikasi, merupakan StatelessWidget
// StatelessWidget berarti tidak memiliki state internal yang berubah
class MyApp extends StatelessWidget {
  // Konstruktor dengan key opsional untuk identifikasi widget
  const MyApp({super.key});

  // Override method build untuk membangun UI
  // Method ini dipanggil setiap kali widget perlu di-render ulang
  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk mendengarkan perubahan dari ThemeViewModel
    // Consumer akan rebuild widget ketika ThemeViewModel berubah
    return Consumer<ThemeViewModel>(
      // Builder function yang menerima context, themeVM, dan child
      builder: (context, themeVM, child) {
        // Mengembalikan MaterialApp sebagai root widget aplikasi
        // MaterialApp menyediakan navigasi, tema, dan konfigurasi dasar
        return MaterialApp(
          // Judul aplikasi yang muncul di task manager
          title: 'Movie Catalog App',
          // Menonaktifkan banner debug di sudut kanan atas layar
          debugShowCheckedModeBanner: false,
          // Konfigurasi tema terang (light theme)
          theme: ThemeData(
            // Menggunakan Material Design 3
            useMaterial3: true,
            // Skema warna berdasarkan seed color Netflix Red
            colorScheme: ColorScheme.fromSeed(
              // Warna dasar untuk menghasilkan palet warna
              seedColor: const Color(0xFFE50914), // Netflix Red
              // Kecerahan tema: terang
              brightness: Brightness.light,
            ),
            // Tema teks menggunakan font Poppins dari Google Fonts
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.light().textTheme,
            ),
            // Tema AppBar
            appBarTheme: const AppBarTheme(
              // Elevasi AppBar (bayangan)
              elevation: 0,
              // Warna latar belakang AppBar
              backgroundColor: Colors.white,
              // Warna teks dan ikon di AppBar
              foregroundColor: Colors.black,
              // Judul di tengah AppBar
              centerTitle: true,
            ),
            // Warna latar belakang scaffold (layar utama)
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            // Warna kartu
            cardColor: Colors.white,
          ),
          // Konfigurasi tema gelap (dark theme)
          darkTheme: ThemeData(
            // Menggunakan Material Design 3
            useMaterial3: true,
            // Skema warna berdasarkan seed color Netflix Red
            colorScheme: ColorScheme.fromSeed(
              // Warna dasar untuk menghasilkan palet warna
              seedColor: const Color(0xFFE50914),
              // Kecerahan tema: gelap
              brightness: Brightness.dark,
            ),
            // Tema teks menggunakan font Poppins dari Google Fonts
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            // Tema AppBar untuk tema gelap
            appBarTheme: const AppBarTheme(
              // Elevasi AppBar
              elevation: 0,
              // Warna latar belakang AppBar gelap
              backgroundColor: Color(0xFF141414), // Premium Dark
              // Warna teks dan ikon di AppBar
              foregroundColor: Colors.white,
              // Judul di tengah AppBar
              centerTitle: true,
            ),
            // Warna latar belakang scaffold gelap
            scaffoldBackgroundColor: const Color(0xFF141414), // Premium Dark
            // Warna kartu gelap
            cardColor: const Color(0xFF1F1F1F),
          ),
          // Mode tema yang aktif, berdasarkan isDarkMode dari ThemeViewModel
          themeMode: themeVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // Layar utama yang ditampilkan pertama kali
          home: const MainScreen(),
        );
      },
    );
  }
}
