// Kelas Movie merepresentasikan model data untuk sebuah film
// Kelas ini menyimpan informasi dasar tentang film seperti ID, judul, sinopsis, dll.
class Movie {
  // Properti final untuk ID film (unik identifier dari API)
  final int id;
  // Properti final untuk judul film
  final String title;
  // Properti final untuk sinopsis atau deskripsi film
  final String overview;
  // Properti final untuk path poster film (relatif dari TMDB)
  final String posterPath;
  // Properti final untuk rating rata-rata film (dalam bentuk double)
  final double voteAverage;

  // Konstruktor untuk membuat objek Movie dengan parameter yang diperlukan
  // Semua parameter adalah required karena data ini penting untuk film
  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  // Factory constructor untuk membuat Movie dari data JSON
  // Digunakan saat parsing response dari API TMDB
  factory Movie.fromJson(Map<String, dynamic> json) {
    // Mengembalikan objek Movie baru dengan data dari JSON
    return Movie(
      // Mengambil ID dari JSON, default 0 jika null
      id: json['id'] ?? 0,
      // Mengambil judul dari JSON, default 'Tanpa Judul' jika null
      title: json['title'] ?? 'Tanpa Judul',
      // Mengambil overview dari JSON, default 'Tidak ada sinopsis' jika null
      overview: json['overview'] ?? 'Tidak ada sinopsis',
      // Mengambil poster_path dari JSON, default string kosong jika null
      posterPath: json['poster_path'] ?? '',
      // Mengambil vote_average dari JSON, konversi ke double, default 0.0 jika null
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
    );
  }

  // Method untuk mengkonversi objek Movie ke Map (untuk penyimpanan database)
  // Mengembalikan Map<String, dynamic> yang berisi semua properti
  Map<String, dynamic> toMap() {
    // Mengembalikan map dengan key-value pairs
    return {
      // Key 'id' dengan value id
      'id': id,
      // Key 'title' dengan value title
      'title': title,
      // Key 'overview' dengan value overview
      'overview': overview,
      // Key 'posterPath' dengan value posterPath
      'posterPath': posterPath,
      // Key 'voteAverage' dengan value voteAverage
      'voteAverage': voteAverage,
    };
  }

  // Factory constructor untuk membuat Movie dari Map (dari database)
  // Digunakan saat mengambil data dari SQLite atau penyimpanan lokal
  factory Movie.fromMap(Map<String, dynamic> map) {
    // Mengembalikan objek Movie baru dengan data dari Map
    return Movie(
      // Mengambil id dari map (diasumsikan selalu ada)
      id: map['id'],
      // Mengambil title dari map
      title: map['title'],
      // Mengambil overview dari map
      overview: map['overview'],
      // Mengambil posterPath dari map
      posterPath: map['posterPath'],
      // Mengambil voteAverage dari map
      voteAverage: map['voteAverage'],
    );
  }

  // Getter untuk mendapatkan URL lengkap poster film
  // Mengembalikan String URL yang bisa digunakan untuk menampilkan gambar
  String get posterUrl {
    // Jika posterPath kosong, kembalikan URL placeholder
    if (posterPath.isEmpty) {
      // URL placeholder dengan teks "Tidak Ada Gambar"
      return 'https://via.placeholder.com/500x750?text=Tidak+Ada+Gambar';
    }
    // Jika posterPath sudah berupa URL lengkap (dimulai dengan http), kembalikan apa adanya
    if (posterPath.startsWith('http')) {
      // Kembalikan posterPath langsung
      return posterPath;
    }
    // Jika posterPath adalah path relatif, gabungkan dengan base URL TMDB
    // Menggunakan image.tmdb.org/t/p/w500 untuk ukuran 500px width
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}
