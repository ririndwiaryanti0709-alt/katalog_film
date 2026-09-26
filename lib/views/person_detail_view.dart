// Import library Flutter untuk widget dan material design
import 'package:flutter/material.dart';
// Import library Provider untuk state management
import 'package:provider/provider.dart';
// Import library CachedNetworkImage untuk loading gambar dengan cache
import 'package:cached_network_image/cached_network_image.dart';
// Import library Shimmer untuk efek loading skeleton
import 'package:shimmer/shimmer.dart';
// Import model Movie
import '../models/movie.dart';
// Import MovieViewModel untuk logika bisnis
import '../viewmodels/movie_viewmodel.dart';
// Import DetailView untuk navigasi
import 'detail_view.dart';

// Kelas PersonDetailView adalah StatelessWidget untuk menampilkan detail pemeran
class PersonDetailView extends StatelessWidget {
  // Constructor dengan parameter person (Map dari data pemeran)
  final Map<String, dynamic> person;

  // Constructor dengan key dan required person
  const PersonDetailView({super.key, required this.person});

  // Override build method untuk membangun UI
  @override
  Widget build(BuildContext context) {
    // Ambil instance MovieViewModel dari Provider tanpa listen
    final viewModel = Provider.of<MovieViewModel>(context, listen: false);
    // Ambil personId dari map person
    final personId = person['id'];

    // Return Scaffold sebagai root widget
    return Scaffold(
      // AppBar dengan title nama pemeran
      appBar: AppBar(
        // Title dengan nama pemeran atau default
        title: Text(person['name'] ?? 'Detail Pemeran'),
        // Background color dari theme
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // Elevation 0 untuk flat design
        elevation: 0,
      ),
      // Body dengan SingleChildScrollView untuk scroll
      body: SingleChildScrollView(
        // Physics bouncing untuk efek scroll
        physics: const BouncingScrollPhysics(),
        // Column untuk layout vertikal
        child: Column(
          // Cross axis alignment center
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Spasi vertikal
            const SizedBox(height: 20),
            // Center widget untuk profile picture
            Center(
              child: ClipRRect(
                // Border radius circular 100 untuk bentuk lingkaran
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  // Image URL dari profile_path atau placeholder
                  imageUrl: person['profile_path'] != null
                      ? 'https://image.tmdb.org/t/p/w300${person['profile_path']}'
                      : 'https://via.placeholder.com/300x300?text=No+Image',
                  // Width 150
                  width: 150,
                  // Height 150
                  height: 150,
                  // Fit cover
                  fit: BoxFit.cover,
                  // Placeholder dengan Shimmer effect
                  placeholder: (context, url) => Shimmer.fromColors(
                    // Base color abu-abu terang
                    baseColor: Colors.grey.shade300,
                    // Highlight color abu-abu lebih terang
                    highlightColor: Colors.grey.shade100,
                    // Child container putih
                    child: Container(
                      width: 150,
                      height: 150,
                      color: Colors.white,
                    ),
                  ),
                  // Error widget dengan icon person
                  errorWidget: (context, url, error) => Container(
                    width: 150,
                    height: 150,
                    // Background abu-abu transparan
                    color: Colors.grey.withOpacity(0.3),
                    // Child icon person
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            // Spasi vertikal
            const SizedBox(height: 16),
            // Text untuk nama pemeran
            Text(
              // Text nama atau empty string
              person['name'] ?? '',
              // Style dengan font size 24 dan bold
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Spasi vertikal
            const SizedBox(height: 24),

            // FutureBuilder untuk detail pemeran
            FutureBuilder<Map<String, dynamic>?>(
              // Future getPersonDetails dari viewModel
              future: viewModel.getPersonDetails(personId),
              builder: (context, snapshot) {
                // Jika connection state waiting, show loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Ambil data details
                final details = snapshot.data;
                // Jika details null, return empty widget
                if (details == null) return const SizedBox.shrink();

                // Return Padding dengan Column
                return Padding(
                  // Padding horizontal 20
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    // Cross axis alignment start
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Jika birthday ada, tampilkan
                      if (details['birthday'] != null)
                        Padding(
                          // Padding bottom 8
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Lahir: ${details['birthday']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      // Jika place_of_birth ada, tampilkan
                      if (details['place_of_birth'] != null)
                        Padding(
                          // Padding bottom 16
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Tempat Lahir: ${details['place_of_birth']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      // Text header Biografi
                      const Text(
                        'Biografi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Spasi vertikal
                      const SizedBox(height: 12),
                      // Text biografi
                      Text(
                        // Jika biography ada dan tidak empty, tampilkan, else default
                        details['biography']?.isNotEmpty == true
                            ? details['biography']
                            : 'Biografi tidak tersedia.',
                        style: TextStyle(
                          // Font size 15
                          fontSize: 15,
                          // Height 1.5 untuk line spacing
                          height: 1.5,
                          // Color dengan opacity 0.8
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Spasi vertikal
            const SizedBox(height: 32),
            // Padding untuk header Film Lainnya
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                // Alignment center left
                alignment: Alignment.centerLeft,
                child: Text(
                  'Film Lainnya',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Spasi vertikal
            const SizedBox(height: 16),

            // FutureBuilder untuk film pemeran
            FutureBuilder<List<Movie>>(
              // Future getPersonMovies dari viewModel
              future: viewModel.getPersonMovies(personId),
              builder: (context, snapshot) {
                // Jika waiting, show loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Jika tidak ada data atau empty, show message
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Tidak ada data film.'),
                  );
                }

                // Ambil list movies
                final movies = snapshot.data!;
                // Return SizedBox dengan height 250
                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    // Scroll direction horizontal
                    scrollDirection: Axis.horizontal,
                    // Physics bouncing
                    physics: const BouncingScrollPhysics(),
                    // Padding horizontal 16
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // Item count movies length
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      // Ambil movie dari list
                      final movie = movies[index];
                      // Buat hero tag unik
                      final heroTag = 'person_${personId}_movie_${movie.id}';

                      // Return GestureDetector untuk tap
                      return GestureDetector(
                        // On tap navigasi ke DetailView
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailView(movie: movie, heroTag: heroTag),
                            ),
                          );
                        },
                        // Container dengan width 140
                        child: Container(
                          width: 140,
                          // Margin right 12
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            // Cross axis alignment start
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ClipRRect untuk poster
                              ClipRRect(
                                // Border radius 12
                                borderRadius: BorderRadius.circular(12),
                                child: Hero(
                                  // Tag hero
                                  tag: heroTag,
                                  child: CachedNetworkImage(
                                    // Image URL poster
                                    imageUrl: movie.posterUrl,
                                    // Height 200
                                    height: 200,
                                    // Width 140
                                    width: 140,
                                    // Fit cover
                                    fit: BoxFit.cover,
                                    // Placeholder container abu-abu
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                    // Error widget dengan icon movie
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: Colors.grey.withOpacity(0.2),
                                          child: const Icon(Icons.movie),
                                        ),
                                  ),
                                ),
                              ),
                              // Spasi vertikal
                              const SizedBox(height: 8),
                              // Text judul film
                              Text(
                                movie.title,
                                // Max lines 1
                                maxLines: 1,
                                // Overflow ellipsis
                                overflow: TextOverflow.ellipsis,
                                // Style bold font size 14
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
            ),
            // Spasi vertikal
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
