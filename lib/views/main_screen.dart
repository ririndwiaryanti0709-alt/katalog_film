// Import library Flutter untuk widget dan material design
import 'package:flutter/material.dart';
// Import HomeView untuk tab home
import 'home_view.dart';
// Import TopRatedView untuk tab top rated
import 'top_rated_view.dart';
// Import FavoritesView untuk tab favorites
import 'favorites_view.dart';
// Import WatchlistView untuk tab watchlist
import 'watchlist_view.dart';

// Kelas MainScreen adalah StatefulWidget yang menampilkan layar utama dengan bottom navigation
class MainScreen extends StatefulWidget {
  // Konstruktor dengan key opsional
  const MainScreen({super.key});

  // Override createState untuk membuat state
  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Kelas _MainScreenState adalah State untuk MainScreen
class _MainScreenState extends State<MainScreen> {
  // Menyimpan indeks tab navigasi yang saat ini dipilih (default: 0 = HomeView)
  int _selectedIndex = 0;

  // Daftar halaman atau layar yang ditampilkan berdasarkan tab yang dipilih
  final List<Widget> _screens = [
    // Screen 0: HomeView
    const HomeView(),
    // Screen 1: TopRatedView
    const TopRatedView(),
    // Screen 2: FavoritesView
    const FavoritesView(),
    // Screen 3: WatchlistView
    const WatchlistView(),
  ];

  // Override method build untuk membangun UI
  Widget build(BuildContext context) {
    // Mengembalikan Scaffold sebagai root widget
    return Scaffold(
      // IndexedStack menumpuk halaman dan hanya menampilkan yang aktif (index).
      // Keuntungannya: state (kondisi) layar tetap terjaga dan tidak dimuat ulang (re-build) terus menerus saat pindah tab.
      body: IndexedStack(
        // Index berdasarkan _selectedIndex
        index: _selectedIndex,
        // Children adalah list screens
        children: _screens,
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              // Color shadow dengan opacity
              color: Colors.black.withOpacity(0.05),
              // Blur radius
              blurRadius: 20,
              // Offset ke atas
              offset: const Offset(0, -5),
            ),
          ],
        ),
        // BottomNavigationBar adalah UI menu navigasi di bagian bawah layar
        child: BottomNavigationBar(
          // Current index
          currentIndex: _selectedIndex,
          // On tap untuk change index
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          // Elevation 0
          elevation: 0,
          // Background color dari theme
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // Selected item color Netflix red
          selectedItemColor: const Color(0xFFE50914),
          // Unselected item color grey
          unselectedItemColor: Colors.grey,
          // Show selected labels
          showSelectedLabels: true,
          // Show unselected labels
          showUnselectedLabels: true,
          // Selected label style
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          // Type fixed
          type: BottomNavigationBarType.fixed,
          // Items untuk bottom navigation
          items: const [
            BottomNavigationBarItem(
              // Icon untuk tab Tren
              icon: Icon(Icons.movie_filter_outlined),
              // Active icon
              activeIcon: Icon(Icons.movie_filter_rounded),
              // Label
              label: 'Tren',
            ),
            BottomNavigationBarItem(
              // Icon untuk tab Terbaik
              icon: Icon(Icons.star_border_rounded),
              // Active icon
              activeIcon: Icon(Icons.star_rounded),
              // Label
              label: 'Terbaik',
            ),
            BottomNavigationBarItem(
              // Icon untuk tab Favorit
              icon: Icon(Icons.favorite_border_rounded),
              // Active icon
              activeIcon: Icon(Icons.favorite_rounded),
              // Label
              label: 'Favorit',
            ),
            BottomNavigationBarItem(
              // Icon untuk tab Watchlist
              icon: Icon(Icons.bookmark_border_rounded),
              // Active icon
              activeIcon: Icon(Icons.bookmark_rounded),
              // Label
              label: 'Watchlist',
            ),
          ],
        ),
      ),
    );
  }
}
