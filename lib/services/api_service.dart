// Import library dart:convert untuk encoding/decoding JSON
import 'dart:convert';
// Import library http untuk melakukan HTTP requests
import 'package:http/http.dart' as http;
// Import model Movie untuk parsing data film
import '../models/movie.dart';

// Kelas ApiService bertanggung jawab untuk semua interaksi dengan API TMDB (The Movie Database)
// Kelas ini menyediakan method untuk mengambil data film, genre, pencarian, dll.
class ApiService {
  // Konstanta untuk API key TMDB (harus dijaga kerahasiaannya)
  static const String _apiKey = '32878f87e5047bd6d3233c665bce16b6';
  // Konstanta untuk base URL API TMDB
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Method async untuk mengambil daftar film populer
  // Parameter page untuk pagination, default 1
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Menggunakan language=en-US agar judul dan genre tetap dalam bahasa aslinya
      // Melakukan HTTP GET request ke endpoint movie/popular
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US&page=$page&include_adult=false',
        ),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array results dari data
        final List results = data['results'];
        // Map setiap item ke Movie object, lalu filter konten dewasa
        return _filterAdultContent(
          results.map((e) => Movie.fromJson(e)).toList(),
        );
      } else {
        // Jika gagal, kembalikan data mock
        return _getMockPopularMovies();
      }
    } catch (e) {
      // Jika exception, kembalikan data mock
      return _getMockPopularMovies();
    }
  }

  // Method async untuk mengambil daftar film dengan rating tertinggi
  // Parameter page untuk pagination, default 1
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint movie/top_rated
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/top_rated?api_key=$_apiKey&language=en-US&page=$page&include_adult=false',
        ),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array results dari data
        final List results = data['results'];
        // Map setiap item ke Movie object, lalu filter konten dewasa
        return _filterAdultContent(
          results.map((e) => Movie.fromJson(e)).toList(),
        );
      } else {
        // Jika gagal, kembalikan data mock
        return _getMockTopRatedMovies();
      }
    } catch (e) {
      // Jika exception, kembalikan data mock
      return _getMockTopRatedMovies();
    }
  }

  // Method async untuk mengambil daftar genre film
  // Mengembalikan List<Map<String, dynamic>> berisi data genre
  Future<List<Map<String, dynamic>>> getGenres() async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint genre/movie/list
      final response = await http.get(
        Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US'),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array genres dari data
        final List genres = data['genres'];
        // Cast ke List<Map<String, dynamic>>
        return genres.cast<Map<String, dynamic>>();
      }
      // Jika gagal, kembalikan list kosong
      return [];
    } catch (e) {
      // Jika exception, kembalikan list kosong
      return [];
    }
  }

  // Method async untuk mengambil film berdasarkan genre
  // Parameter genreId untuk ID genre, page untuk pagination
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint discover/movie dengan filter genre
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&language=en-US&page=$page&with_genres=$genreId&include_adult=false',
        ),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array results dari data
        final List results = data['results'];
        // Map setiap item ke Movie object, lalu filter konten dewasa
        return _filterAdultContent(
          results.map((e) => Movie.fromJson(e)).toList(),
        );
      } else {
        // Jika gagal, kembalikan list kosong
        return [];
      }
    } catch (e) {
      // Jika exception, kembalikan list kosong
      return [];
    }
  }

  // Method async untuk mencari film berdasarkan query
  // Parameter query untuk kata kunci pencarian, page untuk pagination
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint search/movie
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=$query&page=$page&include_adult=false',
        ),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array results dari data
        final List results = data['results'];
        // Map setiap item ke Movie object, lalu filter konten dewasa
        return _filterAdultContent(
          results.map((e) => Movie.fromJson(e)).toList(),
        );
      } else {
        // Jika gagal, kembalikan list kosong
        return [];
      }
    } catch (e) {
      // Jika exception, kembalikan list kosong
      return [];
    }
  }

  // Method async untuk mengambil key trailer YouTube dari film
  // Parameter movieId untuk ID film
  // Mengembalikan String key YouTube atau null jika tidak ada
  Future<String?> getMovieTrailer(int movieId) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint movie/{id}/videos
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=en-US',
        ),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array results dari data
        final List results = data['results'];
        // Jika ada results, cari trailer YouTube
        if (results.isNotEmpty) {
          // Cari video dengan type 'Trailer' dan site 'YouTube', jika tidak ada ambil yang pertama
          final trailer = results.firstWhere(
            (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
            orElse: () => results.first,
          );
          // Kembalikan key YouTube
          return trailer['key'];
        }
      }
      // Jika tidak ada trailer, kembalikan null
      return null;
    } catch (e) {
      // Jika exception, kembalikan null
      return null;
    }
  }

  // Method async untuk mengambil cast (pemeran) dari film
  // Parameter movieId untuk ID film
  // Mengembalikan List<Map<String, dynamic>> berisi data cast
  Future<List<Map<String, dynamic>>> getMovieCast(int movieId) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint movie/{id}/credits
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey&language=en-US',
        ),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array cast dari data
        final List cast = data['cast'];
        // Cast ke List<Map<String, dynamic>>
        return cast.cast<Map<String, dynamic>>();
      }
      // Jika gagal, kembalikan list kosong
      return [];
    } catch (e) {
      // Jika exception, kembalikan list kosong
      return [];
    }
  }

  // Method async untuk mengambil overview film dalam bahasa Indonesia
  // Parameter movieId untuk ID film, fallbackOverview sebagai cadangan
  // Mengembalikan String overview dalam bahasa Indonesia atau fallback
  Future<String> getMovieOverviewInIndonesian(
    int movieId,
    String fallbackOverview,
  ) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint movie/{id} dengan language=id-ID
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=id-ID'),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil overview dari data
        final overview = data['overview'];
        // Jika overview ada dan tidak kosong, kembalikan
        if (overview != null && overview.toString().trim().isNotEmpty) {
          // Konversi ke String dan kembalikan
          return overview.toString();
        }
      }
      // Jika tidak ada, kembalikan fallback
      return fallbackOverview;
    } catch (e) {
      // Jika exception, kembalikan fallback
      return fallbackOverview;
    }
  }

  // Method async untuk mengambil film serupa
  // Parameter movieId untuk ID film
  // Mengembalikan List<Movie> film serupa
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint movie/{id}/similar
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/$movieId/similar?api_key=$_apiKey&language=en-US&page=1&include_adult=false',
        ),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array results dari data
        final List results = data['results'];
        // Map setiap item ke Movie object, lalu filter konten dewasa
        return _filterAdultContent(
          results.map((e) => Movie.fromJson(e)).toList(),
        );
      }
      // Jika gagal, kembalikan list kosong
      return [];
    } catch (e) {
      // Jika exception, kembalikan list kosong
      return [];
    }
  }

  // Method async untuk mengambil detail orang (aktor/direktor)
  // Parameter personId untuk ID orang
  // Mengembalikan Map<String, dynamic> detail orang atau null
  Future<Map<String, dynamic>?> getPersonDetails(int personId) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint person/{id}
      final response = await http.get(
        Uri.parse('$_baseUrl/person/$personId?api_key=$_apiKey&language=en-US'),
      );
      // Jika status code 200 (OK), decode dan kembalikan
      if (response.statusCode == 200) {
        // Decode JSON dan kembalikan Map
        return json.decode(response.body);
      }
      // Jika gagal, kembalikan null
      return null;
    } catch (e) {
      // Jika exception, kembalikan null
      return null;
    }
  }

  // Method async untuk mengambil film yang dibintangi oleh orang tertentu
  // Parameter personId untuk ID orang
  // Mengembalikan List<Movie> film yang dibintangi
  Future<List<Movie>> getPersonMovies(int personId) async {
    // Menggunakan try-catch untuk menangani error
    try {
      // Melakukan HTTP GET request ke endpoint person/{id}/movie_credits
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey&language=en-US',
        ),
      );
      // Jika status code 200 (OK), parse response
      if (response.statusCode == 200) {
        // Decode JSON response body menjadi Map
        final data = json.decode(response.body);
        // Ambil array cast dari data (film yang dibintangi)
        final List results = data['cast'];
        // Map setiap item ke Movie object, lalu filter konten dewasa
        return _filterAdultContent(
          results.map((e) => Movie.fromJson(e)).toList(),
        );
      }
      // Jika gagal, kembalikan list kosong
      return [];
    } catch (e) {
      // Jika exception, kembalikan list kosong
      return [];
    }
  }

  // Method private untuk memfilter konten dewasa dari daftar film
  // Filter ekstra di sisi aplikasi untuk memblokir film yang tidak ditandai dewasa oleh TMDB (seperti dokumenter)
  List<Movie> _filterAdultContent(List<Movie> movies) {
    // Blacklist kata-kata yang menunjukkan konten dewasa (lebih agresif)
    final blacklist = [
      'porn',
      'sex',
      'erotic',
      'kamasutra',
      'nympho',
      'lust',
      'desire',
      'seduction',
      '18+',
      'nsfw',
      'sensual',
      'playboy',
      'kinky',
      'bdsm',
      'fetish',
      'incest',
      'stepmom',
      'stepbro',
      'stepdad',
      'stepsis',
      'escort',
      'brothel',
      'prostitute',
      'kamasutra',
      'orgasm',
      'nudity',
      'naked',
      'melena',
      'malena',
      'malèna',
      'hot',
      'balinsasayaw',
      "les exploits d'un jeune don juan",
      "l'infermiera di notte",
      'rita',
      'nefeli',
      "je m'appelle agneta",
      'tayuan',
    ];

    // Blacklist ID film yang sering lolos dari filter (seperti dokumenter "After Porn Ends")
    final blockedIds = [
      447200, // After Porn Ends 2
      392044, // After Porn Ends 3
      117565, // After Porn Ends
      10874, // Malèna
      // Tambahkan ID lain di sini jika ditemukan
    ];

    // Filter movies menggunakan where
    return movies.where((movie) {
      // Jika ID film ada di blockedIds, exclude
      if (blockedIds.contains(movie.id)) return false;

      // Konversi title dan overview ke lowercase untuk pencarian case-insensitive
      final title = movie.title.toLowerCase();
      final overview = movie.overview.toLowerCase();

      // Loop melalui setiap kata di blacklist
      for (final word in blacklist) {
        // Jika title atau overview mengandung kata blacklist, exclude
        if (title.contains(word) || overview.contains(word)) {
          return false;
        }
      }
      // Jika tidak ada kata blacklist, include
      return true;
    }).toList(); // Konversi hasil where ke List
  }

  // Method private untuk mendapatkan data mock film populer (fallback saat API gagal)
  List<Movie> _getMockPopularMovies() {
    // Mengembalikan list Movie dengan data dummy
    return [
      Movie(
        id: 693134,
        title: "Dune: Part Two",
        overview: "Paul Atreides bersatu...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Dune+Part+Two",
        voteAverage: 8.3,
      ),
      Movie(
        id: 1011985,
        title: "Kung Fu Panda 4",
        overview: "Po bersiap...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Kung+Fu+Panda+4",
        voteAverage: 7.1,
      ),
      Movie(
        id: 823464,
        title: "Godzilla x Kong",
        overview: "Setelah pertarungan...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Godzilla+x+Kong",
        voteAverage: 7.2,
      ),
      Movie(
        id: 359410,
        title: "Road House",
        overview: "Mantan petarung UFC...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Road+House",
        voteAverage: 7.0,
      ),
      Movie(
        id: 1096197,
        title: "No Way Up",
        overview: "Karakter-karakter...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=No+Way+Up",
        voteAverage: 6.3,
      ),
      Movie(
        id: 787699,
        title: "Wonka",
        overview: "Willy Wonka...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Wonka",
        voteAverage: 7.2,
      ),
      Movie(
        id: 1016084,
        title: "Madame Web",
        overview: "Dipaksa untuk menghadapi...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Madame+Web",
        voteAverage: 5.6,
      ),
      Movie(
        id: 609681,
        title: "The Marvels",
        overview: "Carol Danvers...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Marvels",
        voteAverage: 6.2,
      ),
      Movie(
        id: 866398,
        title: "The Beekeeper",
        overview: "Kampanye balas...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Beekeeper",
        voteAverage: 7.5,
      ),
      Movie(
        id: 1072790,
        title: "Anyone But You",
        overview: "Setelah kencan...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Anyone+But+You",
        voteAverage: 7.1,
      ),
    ];
  }

  // Method private untuk mendapatkan data mock film top rated (fallback saat API gagal)
  List<Movie> _getMockTopRatedMovies() {
    // Mengembalikan list Movie dengan data dummy film klasik
    return [
      Movie(
        id: 238,
        title: "The Godfather",
        overview: "Mencakup tahun 1945...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Godfather",
        voteAverage: 8.7,
      ),
      Movie(
        id: 278,
        title: "The Shawshank Redemption",
        overview: "Dijebak pada tahun...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Shawshank+Redemption",
        voteAverage: 8.7,
      ),
      Movie(
        id: 240,
        title: "The Godfather Part II",
        overview: "Dalam kisah lanjutan...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Godfather+Part+II",
        voteAverage: 8.6,
      ),
      Movie(
        id: 424,
        title: "Schindler's List",
        overview: "Kisah nyata tentang...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Schindler's+List",
        voteAverage: 8.6,
      ),
      Movie(
        id: 19404,
        title: "Dilwale Dulhania Le Jayenge",
        overview: "Raj adalah pria kaya...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=DDLJ",
        voteAverage: 8.5,
      ),
      Movie(
        id: 129,
        title: "Spirited Away",
        overview: "Seorang gadis muda...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Spirited+Away",
        voteAverage: 8.5,
      ),
      Movie(
        id: 389,
        title: "12 Angry Men",
        overview: "Sidang pengadilan...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=12+Angry+Men",
        voteAverage: 8.5,
      ),
      Movie(
        id: 372058,
        title: "Your Name.",
        overview: "Dua anak SMA...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Your+Name",
        voteAverage: 8.5,
      ),
      Movie(
        id: 496243,
        title: "Parasite",
        overview: "Semuanya menganggur...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Parasite",
        voteAverage: 8.5,
      ),
      Movie(
        id: 155,
        title: "The Dark Knight",
        overview: "Batman meningkatkan...",
        posterPath:
            "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Dark+Knight",
        voteAverage: 8.5,
      ),
    ];
  }
}
