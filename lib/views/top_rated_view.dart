// Import library Flutter untuk widget dan material design
import 'package:flutter/material.dart';
// Import library Provider untuk state management
import 'package:provider/provider.dart';
// Import library CachedNetworkImage untuk loading gambar dengan cache
import 'package:cached_network_image/cached_network_image.dart';
// Import library Shimmer untuk efek loading skeleton
import 'package:shimmer/shimmer.dart';
// Import MovieViewModel untuk logika bisnis
import '../viewmodels/movie_viewmodel.dart';
// Import DetailView untuk navigasi
import 'detail_view.dart';

// Kelas TopRatedView adalah StatelessWidget untuk menampilkan film rating tertinggi
class TopRatedView extends StatelessWidget {
  // Constructor default
  const TopRatedView({super.key});

  // Override build method untuk membangun UI
  @override
  Widget build(BuildContext context) {
    // Return Scaffold sebagai root widget
    return Scaffold(
      // AppBar dengan title
      appBar: AppBar(
        // Title dengan style bold
        title: const Text(
          'Rating Tertinggi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Body dengan Consumer untuk mendengarkan perubahan state
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          // Jika loading dan list kosong, show shimmer loading
          if (viewModel.topRatedState == ViewState.loading &&
              viewModel.topRatedMovies.isEmpty) {
            return ListView.separated(
              // Padding all 16
              padding: const EdgeInsets.all(16),
              // Item count 5 untuk skeleton
              itemCount: 5,
              // Separator dengan SizedBox height 16
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => Shimmer.fromColors(
                // Base color abu-abu terang
                baseColor: Colors.grey.shade300,
                // Highlight color abu-abu lebih terang
                highlightColor: Colors.grey.shade100,
                // Child container dengan height 165 dan border radius 16
                child: Container(
                  height: 165,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
            // Jika error dan list kosong, show error message
          } else if (viewModel.topRatedState == ViewState.error &&
              viewModel.topRatedMovies.isEmpty) {
            return Center(child: Text('Oops: ${viewModel.errorMessage}'));
            // Jika list kosong, show empty message
          } else if (viewModel.topRatedMovies.isEmpty) {
            return const Center(child: Text('Tidak ada film.'));
          }

          // Return RefreshIndicator untuk pull-to-refresh
          return RefreshIndicator(
            // On refresh panggil fetchTopRatedMovies
            onRefresh: () => viewModel.fetchTopRatedMovies(),
            child: NotificationListener<ScrollNotification>(
              // On notification untuk infinite scroll
              onNotification: (ScrollNotification scrollInfo) {
                // Jika pixels >= maxScrollExtent - 50, load more
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 50) {
                  viewModel.loadMoreTopRatedMovies();
                }
                // Return false untuk continue listening
                return false;
              },
              child: ListView.separated(
                // Physics AlwaysScrollable dengan Bouncing
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // Padding all 16
                padding: const EdgeInsets.all(16),
                // Item count dengan tambahan 1 jika fetching more
                itemCount:
                    viewModel.topRatedMovies.length +
                    (viewModel.isFetchingMoreTopRated ? 1 : 0),
                // Separator SizedBox height 16
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  // Jika index >= length, show shimmer loading
                  if (index >= viewModel.topRatedMovies.length) {
                    return Shimmer.fromColors(
                      // Base color abu-abu terang
                      baseColor: Colors.grey.shade300,
                      // Highlight color abu-abu lebih terang
                      highlightColor: Colors.grey.shade100,
                      // Child container height 165 border radius 16
                      child: Container(
                        height: 165,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }

                  // Ambil movie dari list
                  final movie = viewModel.topRatedMovies[index];
                  // Buat hero tag unik
                  final heroTag = 'top_rated_poster_${movie.id}';
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
                      );
                    },
                    // Container dengan height 165
                    child: Container(
                      height: 165,
                      decoration: BoxDecoration(
                        // Color dari theme cardColor
                        color: Theme.of(context).cardColor,
                        // Border radius 16
                        borderRadius: BorderRadius.circular(16),
                        // Box shadow untuk elevation effect
                        boxShadow: [
                          BoxShadow(
                            // Color hitam dengan opacity 0.05
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
                              // Border radius only topLeft dan bottomLeft
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
                          // Expanded untuk content kanan
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
