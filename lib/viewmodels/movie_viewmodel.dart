// Import library Flutter untuk ChangeNotifier dan state management
import 'package:flutter/material.dart';
// Import SharedPreferences untuk penyimpanan pencarian terbaru
import 'package:shared_preferences/shared_preferences.dart';
// Import translator untuk terjemahan teks
import 'package:translator/translator.dart';
// Import model Movie
import '../models/movie.dart';
// Import ApiService untuk API calls
import '../services/api_service.dart';
// Import DbService untuk database operations
import '../services/db_service.dart';

// Enum untuk merepresentasikan state loading aplikasi
enum ViewState { loading, success, error }

// Kelas MovieViewModel adalah ViewModel utama yang mengelola state aplikasi
// Extends ChangeNotifier untuk notify listeners saat state berubah
class MovieViewModel extends ChangeNotifier {
  // Instance ApiService untuk interaksi dengan API TMDB
  final ApiService _apiService = ApiService();
  // Instance DbService untuk operasi database lokal
  final DbService _dbService = DbService();
  // Instance GoogleTranslator untuk terjemahan overview film
  final GoogleTranslator _translator = GoogleTranslator();
  // Cache untuk menyimpan terjemahan overview yang sudah dilakukan
  final Map<String, String> _translatedOverviewsCache = {};

  // State untuk loading film populer
  ViewState _state = ViewState.loading;
  ViewState get state => _state;

  // State untuk loading film top rated
  ViewState _topRatedState = ViewState.loading;
  ViewState get topRatedState => _topRatedState;

  // List untuk menyimpan film populer
  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  // List untuk menyimpan film top rated
  List<Movie> _topRatedMovies = [];
  List<Movie> get topRatedMovies => _topRatedMovies;

  // List untuk menyimpan film favorit
  List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => _favoriteMovies;

  // List untuk menyimpan film watchlist
  List<Movie> _watchlistMovies = [];
  List<Movie> get watchlistMovies => _watchlistMovies;

  // List untuk menyimpan hasil pencarian
  List<Movie> _searchResults = [];
  List<Movie> get searchResults => _searchResults;

  // State untuk loading pencarian
  ViewState _searchState = ViewState.success; // Initial state isn't loading
  ViewState get searchState => _searchState;

  // List untuk menyimpan pencarian terbaru
  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  // Counter halaman untuk pagination film populer
  int _popularPage = 1;
  // Counter halaman untuk pagination film top rated
  int _topRatedPage = 1;

  // List untuk menyimpan genre film
  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> get genres => _genres;

  // ID genre yang sedang dipilih untuk filter
  int? _selectedGenreId;
  int? get selectedGenreId => _selectedGenreId;

  // Flag untuk menunjukkan apakah sedang loading more film populer
  bool _isFetchingMorePopular = false;
  bool get isFetchingMorePopular => _isFetchingMorePopular;

  // Flag untuk menunjukkan apakah sedang loading more film top rated
  bool _isFetchingMoreTopRated = false;
  bool get isFetchingMoreTopRated => _isFetchingMoreTopRated;

  // Pesan error untuk ditampilkan ke user
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Konstruktor: inisialisasi data saat ViewModel dibuat
  MovieViewModel() {
    // Fetch genres dari API
    fetchGenres();
    // Fetch film populer
    fetchMovies();
    // Fetch film top rated
    fetchTopRatedMovies();
    // Load favorites dari database
    loadFavorites();
    // Load watchlist dari database
    loadWatchlist();
    // Load recent searches dari SharedPreferences
    loadRecentSearches();
  }

  // Method untuk load recent searches dari SharedPreferences
  Future<void> loadRecentSearches() async {
    // Mendapatkan instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Mengambil list string recent_searches, default empty list
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    // Notify listeners untuk update UI
    notifyListeners();
  }

  // Method untuk menambahkan query ke recent searches
  Future<void> addRecentSearch(String query) async {
    // Trim whitespace dari query
    final trimmed = query.trim();
    // Jika kosong, return
    if (trimmed.isEmpty) return;

    // Hapus query yang sama jika sudah ada
    _recentSearches.remove(trimmed);
    // Insert di posisi pertama
    _recentSearches.insert(0, trimmed);
    // Batasi maksimal 10 recent searches
    if (_recentSearches.length > 10) {
      // Hapus yang terakhir
      _recentSearches.removeLast();
    }

    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    // Notify listeners
    notifyListeners();
  }

  // Method untuk menghapus query dari recent searches
  Future<void> removeRecentSearch(String query) async {
    // Hapus query dari list
    _recentSearches.remove(query);
    // Simpan perubahan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    // Notify listeners
    notifyListeners();
  }

  // Method untuk clear semua recent searches
  Future<void> clearRecentSearches() async {
    // Clear list
    _recentSearches.clear();
    // Hapus dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    // Notify listeners
    notifyListeners();
  }

  // Method untuk fetch genres dari API
  Future<void> fetchGenres() async {
    // Panggil API untuk get genres
    _genres = await _apiService.getGenres();
    // Notify listeners
    notifyListeners();
  }

  // Method untuk set genre yang dipilih (toggle jika sama)
  void setGenre(int? genreId) {
    // Jika genreId sama dengan yang sudah dipilih, set ke null (unselect)
    if (_selectedGenreId == genreId) {
      _selectedGenreId = null;
    } else {
      // Set genre baru
      _selectedGenreId = genreId;
    }
    // Fetch ulang movies dengan genre filter
    fetchMovies();
  }

  // Method untuk fetch movies (populer atau berdasarkan genre)
  Future<void> fetchMovies() async {
    // Set state ke loading
    _state = ViewState.loading;
    // Reset page ke 1
    _popularPage = 1;
    // Notify listeners
    notifyListeners();

    // Try-catch untuk error handling
    try {
      // Jika ada genre yang dipilih, fetch by genre
      if (_selectedGenreId != null) {
        _movies = await _apiService.getMoviesByGenre(
          _selectedGenreId!,
          page: _popularPage,
        );
      } else {
        // Jika tidak, fetch popular movies
        _movies = await _apiService.getPopularMovies(page: _popularPage);
      }
      // Set state ke success
      _state = ViewState.success;
    } catch (e) {
      // Set error message dan state ke error
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    // Notify listeners
    notifyListeners();
  }

  // Method untuk load more popular movies (pagination)
  Future<void> loadMorePopularMovies() async {
    // Jika sedang fetching atau state bukan success, return
    if (_isFetchingMorePopular || _state != ViewState.success) return;

    // Set flag fetching ke true
    _isFetchingMorePopular = true;
    // Notify listeners
    notifyListeners();

    // Try-catch
    try {
      // Increment page
      _popularPage++;
      // Declare variabel untuk new movies
      List<Movie> newMovies;
      // Jika ada genre, fetch by genre
      if (_selectedGenreId != null) {
        newMovies = await _apiService.getMoviesByGenre(
          _selectedGenreId!,
          page: _popularPage,
        );
      } else {
        // Fetch popular
        newMovies = await _apiService.getPopularMovies(page: _popularPage);
      }
      // Add new movies ke list existing
      _movies.addAll(newMovies);
    } catch (e) {
      // Handle error (implicitly, bisa show snackbar di view)
    } finally {
      // Set flag ke false
      _isFetchingMorePopular = false;
      // Notify listeners
      notifyListeners();
    }
  }

  // Method untuk fetch top rated movies
  Future<void> fetchTopRatedMovies() async {
    // Set state ke loading
    _topRatedState = ViewState.loading;
    // Reset page ke 1
    _topRatedPage = 1;
    // Notify listeners
    notifyListeners();

    // Try-catch
    try {
      // Fetch top rated movies
      _topRatedMovies = await _apiService.getTopRatedMovies(
        page: _topRatedPage,
      );
      // Set state ke success
      _topRatedState = ViewState.success;
    } catch (e) {
      // Set error message dan state ke error
      _errorMessage = e.toString();
      _topRatedState = ViewState.error;
    }
    // Notify listeners
    notifyListeners();
  }

  // Method untuk load more top rated movies
  Future<void> loadMoreTopRatedMovies() async {
    // Jika sedang fetching atau state bukan success, return
    if (_isFetchingMoreTopRated || _topRatedState != ViewState.success) return;

    // Set flag ke true
    _isFetchingMoreTopRated = true;
    // Notify listeners
    notifyListeners();

    // Try-catch
    try {
      // Increment page
      _topRatedPage++;
      // Fetch new movies
      final newMovies = await _apiService.getTopRatedMovies(
        page: _topRatedPage,
      );
      // Add ke list existing
      _topRatedMovies.addAll(newMovies);
    } catch (e) {
      // Error handling
    } finally {
      // Set flag ke false
      _isFetchingMoreTopRated = false;
      // Notify listeners
      notifyListeners();
    }
  }

  // Method untuk search movies
  Future<void> searchMovies(String query, {bool saveToHistory = false}) async {
    // Jika query kosong setelah trim, clear results dan return
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchState = ViewState.success;
      notifyListeners();
      return;
    }

    // Set state ke loading
    _searchState = ViewState.loading;
    // Notify listeners
    notifyListeners();

    // Try-catch
    try {
      // Search movies via API
      _searchResults = await _apiService.searchMovies(query);
      // Set state ke success
      _searchState = ViewState.success;
      // Jika saveToHistory true dan ada results, add ke recent searches
      if (saveToHistory && _searchResults.isNotEmpty) {
        addRecentSearch(query);
      }
    } catch (e) {
      // Set error message dan state ke error
      _errorMessage = e.toString();
      _searchState = ViewState.error;
    }
    // Notify listeners
    notifyListeners();
  }

  // Method untuk load favorites dari database
  Future<void> loadFavorites() async {
    // Get favorites dari DB
    _favoriteMovies = await _dbService.getFavorites();
    // Notify listeners
    notifyListeners();
  }

  // Method untuk toggle favorite status film
  Future<void> toggleFavorite(Movie movie) async {
    // Cek apakah sudah favorite
    final isFav = await _dbService.isFavorite(movie.id);
    // Jika ya, remove; jika tidak, add
    if (isFav) {
      await _dbService.removeFavorite(movie.id);
    } else {
      await _dbService.addFavorite(movie);
    }
    // Reload favorites
    await loadFavorites();
  }

  // Method untuk cek apakah film adalah favorite
  Future<bool> isFavorite(int id) async {
    // Delegate ke DB service
    return await _dbService.isFavorite(id);
  }

  // Method untuk load watchlist dari database
  Future<void> loadWatchlist() async {
    // Get watchlist dari DB
    _watchlistMovies = await _dbService.getWatchlist();
    // Notify listeners
    notifyListeners();
  }

  // Method untuk toggle watchlist status film
  Future<void> toggleWatchlist(Movie movie) async {
    // Cek apakah sudah di watchlist
    final isWatchlist = await _dbService.isWatchlist(movie.id);
    // Jika ya, remove; jika tidak, add
    if (isWatchlist) {
      await _dbService.removeWatchlist(movie.id);
    } else {
      await _dbService.addWatchlist(movie);
    }
    // Reload watchlist
    await loadWatchlist();
  }

  // Method untuk cek apakah film ada di watchlist
  Future<bool> isWatchlist(int id) async {
    // Delegate ke DB service
    return await _dbService.isWatchlist(id);
  }

  // Method untuk get trailer key dari film
  Future<String?> getMovieTrailer(int id) async {
    // Delegate ke API service
    return await _apiService.getMovieTrailer(id);
  }

  // Method untuk get cast dari film
  Future<List<Map<String, dynamic>>> getMovieCast(int id) async {
    // Delegate ke API service
    return await _apiService.getMovieCast(id);
  }

  // Method untuk get overview yang sudah diterjemahkan ke bahasa Indonesia
  Future<String> getTranslatedOverview(
    int movieId,
    String fallbackOverview,
  ) async {
    // Coba ambil dari TMDB bahasa Indonesia terlebih dahulu
    final tmdbIndo = await _apiService.getMovieOverviewInIndonesian(
      movieId,
      fallbackOverview,
    );

    // Jika TMDB punya terjemahan (teks berbeda, asumsi TMDB mengembalikan teks Inggris jika gagal)
    if (tmdbIndo != fallbackOverview && tmdbIndo.trim().isNotEmpty) {
      // Kembalikan terjemahan TMDB
      return tmdbIndo;
    }

    // Jika TMDB tidak punya, kita paksa terjemahkan menggunakan Google Translate API
    if (fallbackOverview.isEmpty) return "";

    // Cek cache terlebih dahulu
    if (_translatedOverviewsCache.containsKey(fallbackOverview)) {
      // Kembalikan dari cache
      return _translatedOverviewsCache[fallbackOverview]!;
    }

    // Try-catch untuk translate
    try {
      // Translate ke bahasa Indonesia
      final translation = await _translator.translate(
        fallbackOverview,
        to: 'id',
      );
      // Simpan ke cache
      _translatedOverviewsCache[fallbackOverview] = translation.text;
      // Kembalikan hasil translate
      return translation.text;
    } catch (e) {
      // Jika gagal, kembalikan fallback
      return fallbackOverview;
    }
  }

  // Method untuk get similar movies
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    // Delegate ke API service
    return await _apiService.getSimilarMovies(movieId);
  }

  // Method untuk get person details
  Future<Map<String, dynamic>?> getPersonDetails(int personId) async {
    // Delegate ke API service
    return await _apiService.getPersonDetails(personId);
  }

  // Method untuk get movies dari person tertentu
  Future<List<Movie>> getPersonMovies(int personId) async {
    // Delegate ke API service
    return await _apiService.getPersonMovies(personId);
  }
}
