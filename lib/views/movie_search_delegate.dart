// Import library Flutter untuk widget dan material design
import 'package:flutter/material.dart';
// Import library Provider untuk state management
import 'package:provider/provider.dart';
// Import library CachedNetworkImage untuk loading gambar dengan cache
import 'package:cached_network_image/cached_network_image.dart';
// Import model Movie
import '../models/movie.dart';
// Import MovieViewModel untuk logika bisnis
import '../viewmodels/movie_viewmodel.dart';
// Import DetailView untuk navigasi
import 'detail_view.dart';

// Kelas MovieSearchDelegate extends SearchDelegate untuk implementasi search functionality
class MovieSearchDelegate extends SearchDelegate<Movie?> {
  // Override searchFieldLabel untuk label search field
  @override
  String get searchFieldLabel => 'Cari film...';

  // Override buildActions untuk actions di app bar search
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // Jika query tidak kosong, tampilkan clear button
      if (query.isNotEmpty)
        IconButton(
          // Ikon clear
          icon: const Icon(Icons.clear),
          // On pressed untuk clear query
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  // Override buildLeading untuk leading widget (back button)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      // Ikon back
      icon: const Icon(Icons.arrow_back),
      // On pressed untuk close search
      onPressed: () => close(context, null),
    );
  }

  // Override buildResults untuk menampilkan hasil search saat submit
  @override
  Widget buildResults(BuildContext context) {
    // When user submits the search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Panggil search movies dengan save to history
      Provider.of<MovieViewModel>(
        context,
        listen: false,
      ).searchMovies(query, saveToHistory: true);
    });

    // Consumer untuk mendengarkan perubahan search state
    return Consumer<MovieViewModel>(
      builder: (context, viewModel, child) {
        // Jika loading, show progress indicator
        if (viewModel.searchState == ViewState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.searchState == ViewState.error) {
          // Jika error, show error message
          return Center(child: Text('Oops: ${viewModel.errorMessage}'));
        } else if (viewModel.searchResults.isEmpty) {
          // Jika kosong, show not found message
          return Center(child: Text('Tidak ditemukan film untuk "$query".'));
        }

        // ListView untuk hasil search
        return ListView.builder(
          // Physics bouncing
          physics: const BouncingScrollPhysics(),
          // Item count berdasarkan search results
          itemCount: viewModel.searchResults.length,
          itemBuilder: (context, index) {
            // Ambil movie dari results
            final movie = viewModel.searchResults[index];
            // Buat hero tag unik
            final heroTag = 'search_poster_${movie.id}';
            return ListTile(
              // Leading dengan hero image
              leading: Hero(
                tag: heroTag,
                child: ClipRRect(
                  // Border radius
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    // Image URL
                    imageUrl: movie.posterUrl,
                    // Width 50
                    width: 50,
                    // Fit cover
                    fit: BoxFit.cover,
                    // Placeholder
                    placeholder: (context, url) =>
                        Container(width: 50, color: Colors.grey[300]),
                    // Error widget
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              ),
              // Title dengan judul film
              title: Text(
                movie.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // Subtitle dengan rating
              subtitle: Row(
                children: [
                  // Ikon star
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  // Spasi
                  const SizedBox(width: 4),
                  // Text rating
                  Text(movie.voteAverage.toStringAsFixed(1)),
                ],
              ),
              // On tap untuk navigasi ke detail
              onTap: () {
                // Add to recent search
                Provider.of<MovieViewModel>(
                  context,
                  listen: false,
                ).addRecentSearch(movie.title);
                // Navigate to detail
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailView(movie: movie, heroTag: heroTag),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Override buildSuggestions untuk menampilkan suggestions saat typing
  @override
  Widget buildSuggestions(BuildContext context) {
    // Jika query kosong, tampilkan recent searches
    if (query.isEmpty) {
      return Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          // Ambil recent searches
          final recentSearches = viewModel.recentSearches;
          // Jika kosong, show empty state
          if (recentSearches.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon search
                  Icon(Icons.search, size: 64, color: Colors.grey),
                  // Spasi
                  SizedBox(height: 16),
                  // Text instruction
                  Text(
                    'Ketik judul film untuk mencari.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Column untuk header dan list
          return Column(
            // Alignment start
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                // Padding
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  // Main axis space between
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text header
                    const Text(
                      'Pencarian Terakhir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // TextButton untuk clear all
                    TextButton(
                      onPressed: () => viewModel.clearRecentSearches(),
                      child: const Text(
                        'Hapus Semua',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded untuk list
              Expanded(
                child: ListView.builder(
                  // Physics bouncing
                  physics: const BouncingScrollPhysics(),
                  // Item count
                  itemCount: recentSearches.length,
                  itemBuilder: (context, index) {
                    // Ambil recent query
                    final recentQuery = recentSearches[index];
                    return ListTile(
                      // Leading icon history
                      leading: const Icon(Icons.history, color: Colors.grey),
                      // Title dengan query
                      title: Text(recentQuery),
                      // Trailing icon button untuk remove
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            viewModel.removeRecentSearch(recentQuery),
                      ),
                      // On tap untuk set query dan show results
                      onTap: () {
                        query = recentQuery;
                        showResults(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }

    // Call search API as user types (debounce could be added in ViewModel)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Panggil search movies tanpa save to history
      Provider.of<MovieViewModel>(context, listen: false).searchMovies(query);
    });

    // Consumer untuk suggestions
    return Consumer<MovieViewModel>(
      builder: (context, viewModel, child) {
        // Jika loading, show progress
        if (viewModel.searchState == ViewState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ListView untuk suggestions
        return ListView.builder(
          // Physics bouncing
          physics: const BouncingScrollPhysics(),
          // Item count
          itemCount: viewModel.searchResults.length,
          itemBuilder: (context, index) {
            // Ambil movie
            final movie = viewModel.searchResults[index];
            // Buat hero tag unik
            final heroTag = 'search_sugg_poster_${movie.id}';
            return ListTile(
              // Leading dengan hero image
              leading: Hero(
                tag: heroTag,
                child: ClipRRect(
                  // Border radius
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    // Image URL
                    imageUrl: movie.posterUrl,
                    // Width 50
                    width: 50,
                    // Height 75
                    height: 75,
                    // Fit cover
                    fit: BoxFit.cover,
                    // Placeholder
                    placeholder: (context, url) => Container(
                      width: 50,
                      height: 75,
                      color: Colors.grey[300],
                    ),
                    // Error widget
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              ),
              // Title judul film
              title: Text(movie.title),
              // Subtitle rating
              subtitle: Text(movie.voteAverage.toStringAsFixed(1)),
              // On tap untuk navigasi
              onTap: () {
                // Add to recent search
                Provider.of<MovieViewModel>(
                  context,
                  listen: false,
                ).addRecentSearch(movie.title);
                // Navigate to detail
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailView(movie: movie, heroTag: heroTag),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
