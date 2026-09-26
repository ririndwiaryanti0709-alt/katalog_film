// Import library sqflite untuk SQLite database
import 'package:sqflite/sqflite.dart';
// Import library path untuk manipulasi path file
import 'package:path/path.dart';
// Import model Movie untuk konversi data
import '../models/movie.dart';

// Kelas DbService bertanggung jawab untuk semua operasi database lokal (SQLite)
// Mengelola favorites dan watchlist film
class DbService {
  // Variabel static untuk menyimpan instance database (singleton pattern)
  static Database? _database;

  // Getter untuk mendapatkan instance database
  // Menggunakan lazy initialization, hanya inisialisasi saat pertama kali dipanggil
  Future<Database> get database async {
    // Jika _database sudah ada, kembalikan langsung
    if (_database != null) return _database!;
    // Jika belum ada, inisialisasi database
    _database = await _initDB('movies.db');
    // Kembalikan instance database
    return _database!;
  }

  // Method private untuk inisialisasi database
  // Parameter filePath adalah nama file database
  Future<Database> _initDB(String filePath) async {
    // Mendapatkan path direktori database dari sistem
    final dbPath = await getDatabasesPath();
    // Menggabungkan path direktori dengan nama file
    final path = join(dbPath, filePath);

    // Membuka database dengan konfigurasi
    return await openDatabase(
      // Path lengkap ke file database
      path,
      // Versi database untuk migration
      version: 2,
      // Callback saat database pertama kali dibuat
      onCreate: _createDB,
      // Callback saat database di-upgrade
      onUpgrade: _upgradeDB,
    );
  }

  // Method private untuk membuat tabel database saat pertama kali dibuat
  // Parameter db adalah instance database, version adalah versi
  Future _createDB(Database db, int version) async {
    // Eksekusi SQL untuk membuat tabel favorites
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        posterPath TEXT,
        voteAverage REAL
      )
    ''');

    // Eksekusi SQL untuk membuat tabel watchlist
    await db.execute('''
      CREATE TABLE watchlist (
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        posterPath TEXT,
        voteAverage REAL
      )
    ''');
  }

  // Method private untuk upgrade database saat versi berubah
  // Parameter db, oldVersion, newVersion
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Jika versi lama kurang dari 2, tambahkan tabel watchlist
    if (oldVersion < 2) {
      // Eksekusi SQL untuk membuat tabel watchlist
      await db.execute('''
        CREATE TABLE watchlist (
          id INTEGER PRIMARY KEY,
          title TEXT,
          overview TEXT,
          posterPath TEXT,
          voteAverage REAL
        )
      ''');
    }
  }

  // Method untuk menambahkan film ke favorites
  // Parameter movie adalah objek Movie yang akan ditambahkan
  Future<void> addFavorite(Movie movie) async {
    // Mendapatkan instance database
    final db = await database;
    // Insert data ke tabel favorites, replace jika konflik (ID sama)
    await db.insert(
      'favorites',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method untuk menghapus film dari favorites berdasarkan ID
  // Parameter id adalah ID film yang akan dihapus
  Future<void> removeFavorite(int id) async {
    // Mendapatkan instance database
    final db = await database;
    // Delete dari tabel favorites berdasarkan ID
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  // Method untuk mendapatkan semua film di favorites
  // Mengembalikan List<Movie>
  Future<List<Movie>> getFavorites() async {
    // Mendapatkan instance database
    final db = await database;
    // Query semua data dari tabel favorites
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    // Map setiap Map ke objek Movie
    return maps.map((map) => Movie.fromMap(map)).toList();
  }

  // Method untuk mengecek apakah film ada di favorites
  // Parameter id adalah ID film
  // Mengembalikan bool: true jika ada, false jika tidak
  Future<bool> isFavorite(int id) async {
    // Mendapatkan instance database
    final db = await database;
    // Query tabel favorites dengan kondisi ID
    final maps = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    // Kembalikan true jika ada hasil, false jika kosong
    return maps.isNotEmpty;
  }

  // Method untuk menambahkan film ke watchlist
  // Parameter movie adalah objek Movie yang akan ditambahkan
  Future<void> addWatchlist(Movie movie) async {
    // Mendapatkan instance database
    final db = await database;
    // Insert data ke tabel watchlist, replace jika konflik
    await db.insert(
      'watchlist',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method untuk menghapus film dari watchlist berdasarkan ID
  // Parameter id adalah ID film yang akan dihapus
  Future<void> removeWatchlist(int id) async {
    // Mendapatkan instance database
    final db = await database;
    // Delete dari tabel watchlist berdasarkan ID
    await db.delete('watchlist', where: 'id = ?', whereArgs: [id]);
  }

  // Method untuk mendapatkan semua film di watchlist
  // Mengembalikan List<Movie>
  Future<List<Movie>> getWatchlist() async {
    // Mendapatkan instance database
    final db = await database;
    // Query semua data dari tabel watchlist
    final List<Map<String, dynamic>> maps = await db.query('watchlist');
    // Map setiap Map ke objek Movie
    return maps.map((map) => Movie.fromMap(map)).toList();
  }

  // Method untuk mengecek apakah film ada di watchlist
  // Parameter id adalah ID film
  // Mengembalikan bool: true jika ada, false jika tidak
  Future<bool> isWatchlist(int id) async {
    // Mendapatkan instance database
    final db = await database;
    // Query tabel watchlist dengan kondisi ID
    final maps = await db.query('watchlist', where: 'id = ?', whereArgs: [id]);
    // Kembalikan true jika ada hasil, false jika kosong
    return maps.isNotEmpty;
  }
}
