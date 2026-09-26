// Import library Flutter untuk widget dan material design
import 'package:flutter/material.dart';
// Import library Provider untuk state management
import 'package:provider/provider.dart';
// Import library CachedNetworkImage untuk loading gambar dengan cache
import 'package:cached_network_image/cached_network_image.dart';
// Import MovieViewModel untuk logika bisnis
import '../viewmodels/movie_viewmodel.dart';
// Import DetailView untuk navigasi
import 'detail_view.dart';

// Kelas WatchlistView adalah StatelessWidget untuk menampilkan daftar watchlist
class WatchlistView extends StatelessWidget {
  // Constructor default
  const WatchlistView({super.key});

  // Override build method untuk membangun UI
  @override
  Widget build(BuildContext context) {
    // Return Scaffold sebagai root widget
    return Scaffold(
      // AppBar dengan title center
      appBar: AppBar(
        // Title dengan style bold
        title: const Text(
          'Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Center title true
        centerTitle: true,
      ),
      // Body dengan Consumer untuk mendengarkan perubahan state
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          // Jika watchlist kosong, show empty state
          if (viewModel.watchlistMovies.isEmpty) {
            // Return Center dengan Column untuk empty state
            return Center(
              child: Column(
                // Main axis alignment center
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon bookmark border abu-abu
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 16),
                  // Text belum ada watchlist
                  Text(
                    'Belum ada Watchlist',
                    // Style font size 18 abu-abu bold
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 8),
                  // Text instruksi
                  Text(
                    'Tambahkan film ke daftar tontonan!',
                    // Style abu-abu
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          // Return ListView separated untuk daftar watchlist
          return ListView.separated(
            // Physics bouncing
            physics: const BouncingScrollPhysics(),
            // Padding all 16
            padding: const EdgeInsets.all(16),
            // Item count berdasarkan watchlist length
            itemCount: viewModel.watchlistMovies.length,
            // Separator SizedBox height 16
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              // Ambil movie dari watchlist
              final movie = viewModel.watchlistMovies[index];
              // Buat hero tag unik
              final heroTag = 'watch_poster_${movie.id}';
              // Return InkWell untuk tap effect
              return InkWell(
                // Border radius 16
                borderRadius: BorderRadius.circular(16),
                // On tap navigasi ke DetailView
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailView(movie: movie, heroTag: heroTag),
                    ),
                  ).then((_) {
                    // After returning, refresh watchlist
                    viewModel.loadWatchlist();
                  });
                },
                // Container dengan height 160
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    // Color dari theme cardColor
                    color: Theme.of(context).cardColor,
                    // Border radius 16
                    borderRadius: BorderRadius.circular(16),
                    // Box shadow untuk elevation
                    boxShadow: [
                      BoxShadow(
                        // Color hitam opacity 0.05
                        color: Colors.black.withOpacity(0.05),
                        // Blur radius 10
                        blurRadius: 10,
                        // Offset 0,5
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  // Row untuk layout horizontal
                  child: Row(
                    children: [
                      // Hero widget untuk animasi
                      Hero(
                        // Tag hero
                        tag: heroTag,
                        child: ClipRRect(
                          // Border radius only topLeft bottomLeft
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            // Image URL poster
                            imageUrl: movie.posterUrl,
                            // Width 100
                            width: 100,
                            // Height double infinity
                            height: double.infinity,
                            // Fit cover
                            fit: BoxFit.cover,
                            // Placeholder container abu-abu
                            placeholder: (context, url) =>
                                Container(color: Colors.grey.shade300),
                            // Error widget icon broken image
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      // Expanded untuk content tengah
                      Expanded(
                        child: Padding(
                          // Padding all 12
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            // Cross axis alignment start
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // Main axis alignment center
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Text judul film
                              Text(
                                movie.title,
                                // Style bold font size 18
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                // Max lines 2
                                maxLines: 2,
                                // Overflow ellipsis
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Spasi vertikal
                              const SizedBox(height: 8),
                              // Row untuk rating
                              Row(
                                children: [
                                  // Icon star amber
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  // Spasi horizontal
                                  const SizedBox(width: 4),
                                  // Text vote average
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    // Style bold font size 16
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              // Spasi vertikal
                              const SizedBox(height: 8),
                              // Text overview
                              Text(
                                movie.overview,
                                // Max lines 2
                                maxLines: 2,
                                // Overflow ellipsis
                                overflow: TextOverflow.ellipsis,
                                // Style abu-abu font size 12
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // IconButton untuk remove dari watchlist
                      IconButton(
                        // Icon bookmark remove blue
                        icon: const Icon(
                          Icons.bookmark_remove_rounded,
                          color: Colors.blue,
                        ),
                        // On pressed toggle watchlist
                        onPressed: () {
                          viewModel.toggleWatchlist(movie);
                          // Show snackbar konfirmasi
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${movie.title} dihapus dari Watchlist',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
