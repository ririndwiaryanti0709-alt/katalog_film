<p align="center">
  <img src="https://flutter.dev/assets/lockup_flutter_vertical.7e432d07dc23bc4f2c04fbaac8d8670e.png" alt="Flutter Logo" width="100">
</p>

<h1 align="center">Movie Catalog</h1>

<p align="center">
  A modern movie catalog application built with Flutter.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-333333?style=for-the-badge" alt="Platform">
</p>

<p align="center">
  <img src="https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1400&q=80" alt="Movie Catalog Banner" width="900">
</p>

---

## About The Project

**Movie Catalog** adalah aplikasi katalog film yang dibuat menggunakan Flutter.

Project ini dirancang dengan konsep aplikasi streaming modern: pengguna dapat melihat daftar film, mencari film, membuka detail film, dan menjelajahi berbagai informasi yang tersedia.

Project ini terinspirasi dari pola desain aplikasi katalog film dan platform streaming modern seperti Netflix, tetapi dibuat sebagai project mandiri untuk kebutuhan pembelajaran dan pengembangan aplikasi Flutter.

Fokus utama project ini adalah membuat pengalaman browsing film yang sederhana, modern, dan nyaman digunakan.

---

## Overview

**Movie Catalog** adalah aplikasi katalog film modern yang dikembangkan menggunakan framework Flutter. Aplikasi ini memungkinkan pengguna untuk menjelajahi berbagai judul film, mencari film tertentu, melihat detail informasi film, serta menyimpan film ke dalam daftar favorit secara lokal.

Dirancang dengan antarmuka yang bersih (*clean UI*), minimalis, dan intuitif untuk memberikan pengalaman pengguna (*user experience*) yang optimal pada perangkat mobile, web, maupun desktop.

---

## Features

- **Home & Catalog:** Menampilkan koleksi film unggulan, populer, dan rilis terbaru.
- **Movie Detail:** Informasi mendalam tentang film termasuk poster, deskripsi, rating, genre, dan trailer.
- **Search:** Pencarian film berdasarkan judul secara real-time.
- **Favorites:** Fitur untuk menyimpan film favorit ke dalam penyimpanan lokal.
- **Categories:** Pengelompokan film berdasarkan genre/kategori.
- **Shimmer Effect:** Indikator *loading* visual yang halus saat mengambil data.
- **Image Caching:** Pengelolaan gambar yang efisien menggunakan caching data.

---

## Architecture & Project Structure

Proyek ini dibangun menggunakan arsitektur yang terpisah antara tampilan UI, manajemen status, dan layanan data:

```text
lib/
├── models/         # Model data (misal: Movie)
├── providers/      # State management (Provider)
├── screens/        # Halaman aplikasi (Home, Detail, Search, Favorites)
├── services/       # Layanan API & SQLite Database
├── widgets/        # Komponen UI reusable (MovieCard, Shimmer, dll)
└── utils/          # Konstanta dan pembantu (constants, theme)
```

---

## Tech Stack & Dependencies

Proyek ini memanfaatkan package-package Flutter berikut:

| Package | Deskripsi |
| :--- | :--- |
| **`provider`** | State management untuk mengelola status aplikasi secara terstruktur. |
| **`http`** | Melakukan request data dari REST API. |
| **`sqflite`** | Database lokal terstruktur untuk menyimpan daftar favorit. |
| **`shared_preferences`** | Penyimpanan lokal sederhana untuk pengaturan pengguna. |
| **`cached_network_image`** | Memuat dan menyimpan cache gambar poster/backdrop. |
| **`shimmer`** | Menampilkan animasi *loading placeholder*. |
| **`google_fonts`** | Tipografi kustom yang konsisten. |
| **`url_launcher`** | Membuka tautan eksternal seperti trailer film. |
| **`translator`** | Fitur penerjemah konten/deskripsi film. |

---

## User Flow Diagram

```text
                    +--------------------+
                    |     Home Screen    |
                    +---------+----------+
                              |
       +----------------------+----------------------+
       |                      |                      |
       v                      v                      v
+--------------+      +---------------+      +---------------+
| Search Screen|      | Category List |      | Favorites Page|
+-------+------+      +-------+-------+      +-------+-------+
        |                     |                      |
        +---------------------+----------------------+
                              |
                              v
                    +--------------------+
                    | Movie Detail Screen|
                    +---------+----------+
                              |
                   +----------+----------+
                   |                     |
                   v                     v
            [ Add Favorite ]      [ Play Trailer ]
```

---

## Screenshots

| Home | Detail | Search | Favorites |
| :---: | :---: | :---: | :---: |
| *(Image Placeholder)* | *(Image Placeholder)* | *(Image Placeholder)* | *(Image Placeholder)* |

---

## Getting Started

### Prerequisites

Pastikan kamu telah menginstal:
- **Flutter SDK** (Versi >= 3.38.0)
- **Dart SDK** (Versi >= 3.10.1)
- IDE seperti VS Code atau Android Studio

### Installation

1. **Clone repository ini:**
   ```bash
   git clone https://github.com/username/movie-catalog.git
   ```

2. **Masuk ke direktori proyek:**
   ```bash
   cd movie-catalog
   ```

3. **Install dependensi:**
   ```bash
   flutter pub get
   ```

4. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

---

## Code Quality Check

Untuk memastikan kualifikasi sintaksis dan pengkodean yang baik:

```bash
# Analisis kode
flutter analyze

# Jalankan pengujian
flutter test
```

---

## License

Atribusi lisensi proyek dapat disesuaikan dengan kebutuhan pengembangan.
---

# Project Status

**Status:** In Development

Project masih dalam tahap pengembangan dan struktur fitur dapat berubah selama proses development.

---

# Developer

<p align="center">

**Movie Catalog**

Built with Flutter & Dart.

</p>

---

<p align="center">
  <img src="https://flutter.dev/assets/lockup_flutter_vertical.7e432d07dc23bc4f2c04fbaac8d8670e.png" alt="Flutter" width="100">
</p>

<p align="center">
  <strong>Browse. Discover. Save your favorite movies.</strong>
</p>

---
## Getting Started

A new Flutter project.
This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
