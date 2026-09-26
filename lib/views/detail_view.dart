// Import library Flutter untuk widget dan material design
import 'package:flutter/material.dart';
// Import library Provider untuk state management
import 'package:provider/provider.dart';
// Import library CachedNetworkImage untuk loading gambar dengan cache
import 'package:cached_network_image/cached_network_image.dart';
// Import library url_launcher untuk membuka URL eksternal
import 'package:url_launcher/url_launcher.dart';
// Import model Movie
import '../models/movie.dart';
// Import MovieViewModel untuk logika bisnis
import '../viewmodels/movie_viewmodel.dart';
// Import PersonDetailView untuk navigasi ke detail orang
import 'person_detail_view.dart';

// Kelas DetailView adalah StatelessWidget yang menampilkan detail lengkap dari sebuah film
// Menggunakan CustomScrollView untuk efek scroll yang fleksibel
class DetailView extends StatelessWidget {
  // Properti final untuk objek Movie yang akan ditampilkan
  final Movie movie;
  // Properti final untuk hero tag animasi transisi gambar
  final String heroTag;

  // Konstruktor dengan parameter required
  const DetailView({super.key, required this.movie, required this.heroTag});

  // Override method build untuk membangun UI
  @override
  Widget build(BuildContext context) {
    // Mengembalikan Scaffold sebagai root widget halaman
    return Scaffold(
      // CustomScrollView memungkinkan kita membuat efek scroll layar yang sangat fleksibel
      // Khususnya menyatukan list / view agar punya perilaku scrolling yang unik seperti header menyusut.
      body: CustomScrollView(
        // Physics untuk efek bouncing saat scroll
        physics: const BouncingScrollPhysics(),
        // Slivers adalah widget khusus untuk CustomScrollView
        slivers: [
          // SliverAppBar adalah AppBar (area atas) yang merespons scroll dan mengecil saat di-scroll ke atas
          SliverAppBar(
            // Tinggi expanded AppBar
            expandedHeight: 400.0,
            // Pinned true agar AppBar tetap terlihat saat scroll
            pinned: true,
            // Membuat tombol kembali (back) menjadi sangat jelas dan tidak menyatu dengan gambar
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  // Background semi-transparan hitam
                  color: Colors.black.withOpacity(0.6),
                  // Bentuk lingkaran
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  // Ikon panah kembali
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  // Fungsi untuk kembali ke halaman sebelumnya
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // FlexibleSpaceBar untuk background yang fleksibel
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                // Stack untuk menumpuk widget
                fit: StackFit.expand,
                children: [
                  // Hero menerima animasi masuk gambar dari HomeView
                  Hero(
                    // Tag untuk animasi hero
                    tag: heroTag,
                    child: CachedNetworkImage(
                      // URL gambar poster
                      imageUrl: movie.posterUrl,
                      // Fit gambar cover
                      fit: BoxFit.cover,
                      // Placeholder saat loading
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      // Widget error jika gagal load
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                  // Gradient Overlay for smooth transition
                  Positioned(
                    // Posisi di bawah
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      // Tinggi gradient
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          // Warna gradient dari transparan ke background color
                          colors: [
                            Colors.transparent,
                            Theme.of(context).scaffoldBackgroundColor,
                          ],
                          // Arah gradient dari atas ke bawah
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SliverToBoxAdapter berfungsi menjadi jembatan (adapter) antara scroll view biasa ke model "sliver" (widget yang bukan daftar list).
          SliverToBoxAdapter(
            child: Padding(
              // Padding di sekitar konten
              padding: const EdgeInsets.all(20.0),
              child: Column(
                // Alignment cross axis ke start
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    // Alignment cross axis ke start
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          // Judul film
                          movie.title,
                          style: const TextStyle(
                            // Ukuran font besar
                            fontSize: 28,
                            // Font weight bold
                            fontWeight: FontWeight.bold,
                            // Line height
                            height: 1.2,
                          ),
                        ),
                      ),
                      // Spasi horizontal
                      const SizedBox(width: 16),
                      Consumer<MovieViewModel>(
                        // Builder untuk MovieViewModel
                        builder: (context, viewModel, child) {
                          return Row(
                            children: [
                              // FutureBuilder menunggu status (true/false) apakah film ini ada di Watchlist
                              FutureBuilder<bool>(
                                // Future untuk cek isWatchlist
                                future: viewModel.isWatchlist(movie.id),
                                builder: (context, snapshot) {
                                  // Ambil data atau default false
                                  final isWatchlist = snapshot.data ?? false;
                                  return GestureDetector(
                                    // On tap untuk toggle watchlist
                                    onTap: () {
                                      // Toggle watchlist
                                      viewModel.toggleWatchlist(movie);
                                      // Show snackbar feedback
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          // Pesan berdasarkan status
                                          content: Text(
                                            isWatchlist
                                                ? 'Dihapus dari Watchlist'
                                                : 'Ditambahkan ke Watchlist!',
                                          ),
                                          // Behavior floating
                                          behavior: SnackBarBehavior.floating,
                                          // Shape rounded
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          // Durasi 2 detik
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      // Padding dalam container
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        // Background color berdasarkan status
                                        color: isWatchlist
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        // Shape circle
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        // Ikon berdasarkan status
                                        isWatchlist
                                            ? Icons.bookmark_added_rounded
                                            : Icons.bookmark_add_outlined,
                                        // Color berdasarkan status
                                        color: isWatchlist
                                            ? Colors.blue
                                            : Colors.grey,
                                        // Ukuran ikon
                                        size: 28,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Spasi horizontal
                              const SizedBox(width: 12),
                              FutureBuilder<bool>(
                                // Future untuk cek isFavorite
                                future: viewModel.isFavorite(movie.id),
                                builder: (context, snapshot) {
                                  // Ambil data atau default false
                                  final isFav = snapshot.data ?? false;
                                  return GestureDetector(
                                    // On tap untuk toggle favorite
                                    onTap: () {
                                      // Toggle favorite
                                      viewModel.toggleFavorite(movie);
                                      // Show snackbar feedback
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          // Pesan berdasarkan status
                                          content: Text(
                                            isFav
                                                ? 'Dihapus dari Favorit'
                                                : 'Disimpan ke Favorit!',
                                          ),
                                          // Behavior floating
                                          behavior: SnackBarBehavior.floating,
                                          // Shape rounded
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          // Durasi 2 detik
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      // Padding dalam container
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        // Background color berdasarkan status
                                        color: isFav
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        // Shape circle
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        // Ikon berdasarkan status
                                        isFav
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        // Color berdasarkan status
                                        color: isFav
                                            ? Colors.redAccent
                                            : Colors.grey,
                                        // Ukuran ikon
                                        size: 28,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        // Padding dalam container
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          // Background amber transparan
                          color: Colors.amber.withOpacity(0.2),
                          // Border radius
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Ikon star
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            // Spasi horizontal
                            const SizedBox(width: 4),
                            Text(
                              // Rating dengan format 1 desimal
                              '${movie.voteAverage.toStringAsFixed(1)} / 10',
                              style: const TextStyle(
                                // Font weight bold
                                fontWeight: FontWeight.bold,
                                // Color amber
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Spasi horizontal
                      const SizedBox(width: 12),
                      Container(
                        // Padding dalam container
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          // Background primary color transparan
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          // Border radius
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          // Label 'Populer'
                          'Populer',
                          style: TextStyle(
                            // Font weight bold
                            fontWeight: FontWeight.bold,
                            // Color primary
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 24),
                  Consumer<MovieViewModel>(
                    // Builder untuk MovieViewModel
                    builder: (context, viewModel, child) {
                      // Mengambil trailer key/id youtube secara asinkron dari API
                      return FutureBuilder<String?>(
                        // Future untuk get trailer
                        future: viewModel.getMovieTrailer(movie.id),
                        builder: (context, snapshot) {
                          // Jika masih waiting, show loading
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          // Ambil trailer key
                          final trailerKey = snapshot.data;
                          // Jika null, return empty
                          if (trailerKey == null)
                            return const SizedBox.shrink();

                          return SizedBox(
                            // Lebar penuh
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              // On pressed untuk launch YouTube
                              onPressed: () async {
                                // Menggunakan package url_launcher untuk membuka aplikasi / web browser YouTube
                                final url = Uri.parse(
                                  'https://www.youtube.com/watch?v=$trailerKey',
                                );
                                // Cek bisa launch URL
                                if (await canLaunchUrl(url)) {
                                  // Launch dengan mode external application
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  // Jika tidak bisa, show snackbar error
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Tidak dapat membuka trailer',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              // Ikon play
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                              // Label text
                              label: const Text(
                                'Tonton Trailer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                // Background red accent
                                backgroundColor: Colors.redAccent,
                                // Padding vertikal
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                // Shape rounded
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                // Elevation 0
                                elevation: 0,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 32),
                  const Text(
                    // Judul section Sinopsis
                    'Sinopsis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 12),
                  Consumer<MovieViewModel>(
                    // Builder untuk MovieViewModel
                    builder: (context, viewModel, child) {
                      // Menerjemahkan overview (sinopsis) film secara asinkron (delay sebentar untuk ngambil service terjemahan)
                      return FutureBuilder<String>(
                        // Future untuk get translated overview
                        future: viewModel.getTranslatedOverview(
                          movie.id,
                          movie.overview,
                        ),
                        builder: (context, snapshot) {
                          // Jika waiting, show loading
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return Text(
                            // Data atau fallback
                            snapshot.data ?? movie.overview,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              // Color dengan opacity
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 32),
                  const Text(
                    // Judul section Pemeran
                    'Pemeran (Cast)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 16),
                  Consumer<MovieViewModel>(
                    // Builder untuk MovieViewModel
                    builder: (context, viewModel, child) {
                      // Mengambil data aktor (cast) film secara asinkron menggunakan FutureBuilder
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        // Future untuk get cast
                        future: viewModel.getMovieCast(movie.id),
                        builder: (context, snapshot) {
                          // Jika waiting, show loading
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          // Jika tidak ada data atau kosong
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Data pemeran tidak tersedia.');
                          }

                          // Ambil cast list, batasi 10
                          final castList = snapshot.data!
                              .take(10)
                              .toList(); // Batasi hanya menampilkan 10 aktor

                          return SizedBox(
                            // Tinggi fixed 150
                            height: 150, // Membatasi tinggi ListView ke 150 px
                            child: ListView.builder(
                              // Scroll direction horizontal
                              scrollDirection: Axis
                                  .horizontal, // UI agar scroll aktor bisa ke samping (Kiri - Kanan)
                              // Physics bouncing
                              physics: const BouncingScrollPhysics(),
                              // Item count
                              itemCount: castList.length,
                              itemBuilder: (context, index) {
                                // Ambil cast data
                                final cast = castList[index];
                                // Ambil profile path
                                final profilePath = cast['profile_path'];
                                // Buat image URL atau placeholder
                                final imageUrl = profilePath != null
                                    ? 'https://image.tmdb.org/t/p/w200$profilePath'
                                    : 'https://via.placeholder.com/200x300?text=No+Image';

                                return GestureDetector(
                                  // On tap untuk navigasi ke PersonDetailView
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PersonDetailView(person: cast),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    // Lebar 100
                                    width: 100,
                                    // Margin kanan
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      // Alignment start
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          // Border radius
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            // Image URL
                                            imageUrl: imageUrl,
                                            // Tinggi 100
                                            height: 100,
                                            // Lebar 100
                                            width: 100,
                                            // Fit cover
                                            fit: BoxFit.cover,
                                            // Placeholder
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                ),
                                            // Error widget
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      child: const Icon(
                                                        Icons.person,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        // Spasi vertikal
                                        const SizedBox(height: 8),
                                        Text(
                                          // Nama cast
                                          cast['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          // Max lines 1
                                          maxLines: 1,
                                          // Overflow ellipsis
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          // Karakter yang diperankan
                                          cast['character'] ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            // Color dengan opacity
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withOpacity(0.7),
                                          ),
                                          // Max lines 1
                                          maxLines: 1,
                                          // Overflow ellipsis
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 32),
                  const Text(
                    // Judul section Film Serupa
                    'Film Serupa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 16),
                  Consumer<MovieViewModel>(
                    // Builder untuk MovieViewModel
                    builder: (context, viewModel, child) {
                      return FutureBuilder<List<Movie>>(
                        // Future untuk get similar movies
                        future: viewModel.getSimilarMovies(movie.id),
                        builder: (context, snapshot) {
                          // Jika waiting, show loading
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          // Jika tidak ada data atau kosong
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Tidak ada film serupa.');
                          }

                          // Ambil similar movies
                          final similarMovies = snapshot.data!;
                          return SizedBox(
                            // Tinggi 250
                            height: 250,
                            child: ListView.builder(
                              // Scroll direction horizontal
                              scrollDirection: Axis.horizontal,
                              // Physics bouncing
                              physics: const BouncingScrollPhysics(),
                              // Item count
                              itemCount: similarMovies.length,
                              itemBuilder: (context, index) {
                                // Ambil similar movie
                                final simMovie = similarMovies[index];
                                // Buat hero tag unik
                                final simHeroTag =
                                    'similar_${movie.id}_${simMovie.id}';
                                return GestureDetector(
                                  // On tap untuk navigasi ke DetailView film serupa
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailView(
                                          movie: simMovie,
                                          heroTag: simHeroTag,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    // Lebar 140
                                    width: 140,
                                    // Margin kanan
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      // Alignment start
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          // Border radius
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Hero(
                                            // Hero tag
                                            tag: simHeroTag,
                                            child: CachedNetworkImage(
                                              // Image URL
                                              imageUrl: simMovie.posterUrl,
                                              // Tinggi 200
                                              height: 200,
                                              // Lebar 140
                                              width: 140,
                                              // Fit cover
                                              fit: BoxFit.cover,
                                              // Placeholder
                                              placeholder: (context, url) =>
                                                  Container(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                  ),
                                              // Error widget
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                        child: const Icon(
                                                          Icons.movie,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ),
                                        // Spasi vertikal
                                        const SizedBox(height: 8),
                                        Text(
                                          // Judul film serupa
                                          simMovie.title,
                                          // Max lines 1
                                          maxLines: 1,
                                          // Overflow ellipsis
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Spasi vertikal untuk bottom padding
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
