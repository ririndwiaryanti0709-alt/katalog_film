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

// Kelas FavoritesView adalah StatelessWidget yang menampilkan daftar film favorit
class FavoritesView extends StatelessWidget {
  // Konstruktor dengan key opsional
  const FavoritesView({super.key});

  // Override method build untuk membangun UI
  @override
  Widget build(BuildContext context) {
    // Load favorites saat pertama kali build (tanpa listen)
    Provider.of<MovieViewModel>(context, listen: false).loadFavorites();

    // Mengembalikan Scaffold sebagai root widget halaman
    return Scaffold(
      // AppBar dengan judul
      appBar: AppBar(
        title: const Text(
          'Film Favorit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Body menggunakan Consumer untuk mendengarkan perubahan MovieViewModel
      body: Consumer<MovieViewModel>(
        // Builder function
        builder: (context, viewModel, child) {
          // Jika favoriteMovies kosong, tampilkan empty state
          if (viewModel.favoriteMovies.isEmpty) {
            return Center(
              child: Column(
                // Main axis alignment center
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon heart broken dengan opacity
                  Icon(
                    Icons.heart_broken_rounded,
                    size: 80,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  // Spasi vertikal
                  const SizedBox(height: 16),
                  const Text(
                    // Pesan empty state
                    'Belum ada film favorit.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ListView.separated berguna membuat daftar dengan menyisipkan widget (contohnya jarak/SizedBox) di antara tiap item
          return ListView.separated(
            // Physics bouncing untuk efek iOS
            physics:
                const BouncingScrollPhysics(), // Efek membal (bouncing) saat scroll mencapai ujung layar ala iOS
            // Padding di sekitar list
            padding: const EdgeInsets.all(16),
            // Item count berdasarkan panjang favoriteMovies
            itemCount: viewModel.favoriteMovies.length,
            // Separator builder untuk spasi antar item
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            // Item builder untuk setiap item
            itemBuilder: (context, index) {
              // Ambil movie dari list
              final movie = viewModel.favoriteMovies[index];
              // Buat hero tag unik
              final heroTag = 'fav_poster_${movie.id}';
              // InkWell memberi elemen kemampuan untuk di-klik dengan efek riak material (ripple effect)
              return InkWell(
                // Border radius untuk ripple effect
                borderRadius: BorderRadius.circular(16),
                // On tap untuk navigasi ke DetailView
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailView(movie: movie, heroTag: heroTag),
                    ),
                  ).then((_) {
                    // Reload favorites setelah kembali
                    Provider.of<MovieViewModel>(
                      context,
                      listen: false,
                    ).loadFavorites();
                  });
                },
                child: Container(
                  // Tinggi container 120
                  height: 120,
                  decoration: BoxDecoration(
                    // Background color dari theme
                    color: Theme.of(context).cardColor,
                    // Border radius
                    borderRadius: BorderRadius.circular(16),
                    // Memberikan bayangan (shadow) halus dibawah card untuk memberi efek kedalaman/melayang
                    boxShadow: [
                      BoxShadow(
                        // Color shadow dengan opacity
                        color: Colors.black.withOpacity(0.05),
                        // Blur radius
                        blurRadius: 10,
                        // Offset shadow
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Hero widget untuk animasi transisi
                      Hero(
                        // Tag hero
                        tag: heroTag,
                        child: ClipRRect(
                          // Border radius hanya kiri atas dan bawah
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            // URL gambar poster
                            imageUrl: movie.posterUrl,
                            // Lebar 80
                            width: 80,
                            // Tinggi penuh
                            height: double.infinity,
                            // Fit cover
                            fit: BoxFit.cover,
                            // Placeholder saat loading
                            placeholder: (context, url) =>
                                Container(color: Colors.grey.shade300),
                            // Error widget
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      // Expanded untuk mengisi sisa ruang
                      Expanded(
                        child: Padding(
                          // Padding dalam container
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            // Alignment start
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // Main axis center
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                // Judul film
                                movie.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                // Max lines 2
                                maxLines: 2,
                                // Overflow ellipsis
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Spasi vertikal
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Ikon star
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  // Spasi horizontal
                                  const SizedBox(width: 4),
                                  Text(
                                    // Rating dengan format 1 desimal
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // IconButton untuk toggle favorite
                      IconButton(
                        // Ikon favorite
                        icon: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.redAccent,
                        ),
                        // On pressed untuk toggle
                        onPressed: () {
                          viewModel.toggleFavorite(movie);
                        },
                      ),
                      // Spasi horizontal
                      const SizedBox(width: 8),
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
