// Import library Flutter untuk widget dan material design
import 'package:flutter/material.dart';
// Import library Provider untuk state management
import 'package:provider/provider.dart';
// Import library CachedNetworkImage untuk loading gambar dengan cache
import 'package:cached_network_image/cached_network_image.dart';
// Import library Shimmer untuk efek skeleton loading
import 'package:shimmer/shimmer.dart';
// Import MovieViewModel untuk logika bisnis film
import '../viewmodels/movie_viewmodel.dart';
// Import ThemeViewModel untuk logika tema
import '../viewmodels/theme_viewmodel.dart';
// Import DetailView untuk navigasi
import 'detail_view.dart';
// Import MovieSearchDelegate untuk search
import 'movie_search_delegate.dart';

// Kelas HomeView adalah StatelessWidget yang menampilkan halaman utama dengan grid film populer
class HomeView extends StatelessWidget {
  // Konstruktor dengan key opsional
  const HomeView({super.key});

  // Override method build untuk membangun UI
  @override
  Widget build(BuildContext context) {
    // Mengambil state tema aktif (dark/light) menggunakan Provider
    final themeVM = Provider.of<ThemeViewModel>(context);

    // Mengembalikan Scaffold sebagai root widget halaman
    return Scaffold(
      // AppBar dengan judul dan actions
      appBar: AppBar(
        // Judul app bar
        title: const Text(
          'Sedang Tren',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Actions di kanan app bar
        actions: [
          // IconButton untuk search
          IconButton(
            // Ikon search
            icon: const Icon(Icons.search_rounded),
            // On pressed untuk show search delegate
            onPressed: () {
              showSearch(context: context, delegate: MovieSearchDelegate());
            },
          ),
          // IconButton untuk toggle tema
          IconButton(
            // Ikon berdasarkan mode tema saat ini
            icon: Icon(
              themeVM.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            // On pressed untuk toggle tema
            onPressed: () => themeVM.toggleTheme(),
          ),
        ],
      ),
      // Consumer digunakan untuk mendengarkan state data dari MovieViewModel. Akan re-build UI secara cerdas saat data berubah (misal animasi loading, list film dll).
      body: Consumer<MovieViewModel>(
        // Builder function
        builder: (context, viewModel, child) {
          // Variabel untuk content yang akan ditampilkan
          Widget content;
          // Kondisi 1: Saat sedang mengambil data API dan belum ada data sama sekali (loading).
          // Tampilkan kerangka skeleton (Shimmer effect) sebagai UI yang cantik saat memuat.
          if (viewModel.state == ViewState.loading &&
              viewModel.movies.isEmpty) {
            // GridView dengan shimmer effect
            content = GridView.builder(
              // Padding horizontal dan vertikal
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              // Grid delegate dengan 2 kolom, aspect ratio 0.65
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              // Item count 6 untuk skeleton
              itemCount: 6,
              // Item builder untuk shimmer
              itemBuilder: (context, index) => Shimmer.fromColors(
                // Base color abu-abu
                baseColor: Colors.grey.shade300,
                // Highlight color lebih terang
                highlightColor: Colors.grey.shade100,
                // Child container dengan border radius
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
          } else if (viewModel.state == ViewState.error &&
              viewModel.movies.isEmpty) {
            // Jika error dan tidak ada data, tampilkan error message
            content = Center(child: Text('Oops: ${viewModel.errorMessage}'));
          } else if (viewModel.movies.isEmpty) {
            // Jika kosong, tampilkan pesan tidak ada film
            content = const Center(child: Text('Tidak ada film.'));
          } else {
            // Kondisi Utama: Data film tersedia
            // RefreshIndicator membungkus layout list untuk memungkinkan "tarik ke bawah untuk muat ulang" (Pull-to-refresh)
            content = RefreshIndicator(
              // On refresh untuk fetch ulang movies
              onRefresh: () => viewModel.fetchMovies(),
              // NotificationListener digunakan untuk melacak posisi scroll (Infinite Scrolling)
              child: NotificationListener<ScrollNotification>(
                // On notification untuk cek scroll position
                onNotification: (ScrollNotification scrollInfo) {
                  // Jika scroll mencapai dekat bottom, load more
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 50) {
                    viewModel.loadMorePopularMovies();
                  }
                  // Return false untuk allow notification propagate
                  return false;
                },
                child: GridView.builder(
                  // Physics always scrollable dengan bouncing
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  // Padding
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  // Grid delegate
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  // Item count termasuk loading items jika fetching more
                  itemCount:
                      viewModel.movies.length +
                      (viewModel.isFetchingMorePopular ? 2 : 0),
                  // Item builder
                  itemBuilder: (context, index) {
                    // Jika index >= panjang movies, tampilkan shimmer loading
                    if (index >= viewModel.movies.length) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    }

                    // Ambil movie dari list
                    final movie = viewModel.movies[index];
                    // Buat hero tag unik
                    final heroTag = 'home_poster_${movie.id}';
                    // GestureDetector untuk handle tap
                    return GestureDetector(
                      // On tap untuk navigasi ke detail
                      onTap: () {
                        // Navigasi ke halaman Detail ketika poster film ditekan, membawa object movie dan heroTag
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailView(movie: movie, heroTag: heroTag),
                          ),
                        );
                      },
                      child: Container(
                        // Decoration dengan border radius dan shadow
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          // Border radius
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            // Stack untuk overlay
                            fit: StackFit.expand,
                            children: [
                              // Hero berguna agar elemen (misal gambar) bisa beterbangan (animasi transisi) dengan halus ke halaman selanjutnya
                              Hero(
                                // Tag hero
                                tag: heroTag,
                                child: CachedNetworkImage(
                                  // URL poster
                                  imageUrl: movie.posterUrl,
                                  // Fit cover
                                  fit: BoxFit.cover,
                                  // Placeholder
                                  placeholder: (context, url) => Container(
                                    color: Theme.of(context).cardColor,
                                  ),
                                  // Error widget
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                              // Tombol efek gradasi hitam di bagian bawah poster agar teks terlihat jelas
                              Positioned(
                                // Posisi bottom
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  // Tinggi 120
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      // Gradient dari transparan ke hitam
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.9),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  // Padding
                                  padding: const EdgeInsets.all(12),
                                  // Alignment bottom left
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    // Judul film
                                    movie.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    // Max lines 2, overflow ellipsis
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              // Rating badge di top right
                              Positioned(
                                // Posisi top right
                                top: 8,
                                right: 8,
                                child: Container(
                                  // Padding
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    // Background hitam transparan
                                    color: Colors.black.withOpacity(0.7),
                                    // Border radius
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    // Main axis size min
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Ikon star
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      // Spasi
                                      const SizedBox(width: 4),
                                      Text(
                                        // Rating dengan 1 desimal
                                        movie.voteAverage.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          // Return Column dengan genre chips dan content
          return Column(
            // Alignment start
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal ListView untuk daftar kategori (Genre Chips) agar user bisa memfilter film dengan mudah
              if (viewModel.genres.isNotEmpty)
                SizedBox(
                  // Tinggi 50
                  height: 50,
                  child: ListView.builder(
                    // Scroll direction horizontal
                    scrollDirection: Axis.horizontal,
                    // Physics bouncing
                    physics: const BouncingScrollPhysics(),
                    // Padding
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    // Item count berdasarkan genres
                    itemCount: viewModel.genres.length,
                    // Item builder untuk genre chips
                    itemBuilder: (context, index) {
                      // Ambil genre
                      final genre = viewModel.genres[index];
                      // Cek apakah selected
                      final isSelected =
                          viewModel.selectedGenreId == genre['id'];
                      return Padding(
                        // Padding right
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          // Label text genre name
                          label: Text(genre['name']),
                          // Selected state
                          selected: isSelected,
                          // On selected untuk set genre
                          onSelected: (selected) {
                            viewModel.setGenre(genre['id']);
                          },
                          // Show checkmark false
                          showCheckmark: false,
                          // Selected color
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          // Label style berdasarkan selected
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                          // Shape rounded
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Expanded memaksa layout grid view film menggunakan sisa ruang yang ada di layar
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}
