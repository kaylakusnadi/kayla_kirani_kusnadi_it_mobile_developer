# Borwita Technical Test - IT Mobile Developer 🚀

**Kandidat:** Kayla Kirani Kusnadi  
**Posisi:** IT Mobile Developer (Flutter) - Head Office Sidoarjo  
**Aplikasi:** Storemart (Sales Catalog App)

---

## 📖 Deskripsi Proyek
Proyek ini adalah aplikasi katalog produk *mobile* yang dikembangkan sebagai bagian dari tes teknis untuk posisi IT Mobile Developer di PT Borwita Citra Prima. Aplikasi ini dirancang untuk mensimulasikan sistem manajemen produk dan pemesanan (*cart*) bagi *sales canvaser* lapangan dengan menitikberatkan pada performa, skalabilitas, dan kebersihan struktur kode.

## ✨ Fitur Utama (Sesuai Kualifikasi)
Aplikasi ini telah mengimplementasikan seluruh kualifikasi yang diminta, meliputi:
- **Arsitektur Standar Industri:** Menggunakan **Clean Architecture** untuk memisahkan logika bisnis (Domain), pengambilan data (Data), dan antarmuka pengguna (Presentation) secara tegas (*Separation of Concern*).
- **State Management BLoC:** Mengimplementasikan **flutter_bloc** untuk menangani *state* antarmuka (Loading, Success, Error, Empty) secara reaktif.
- **Integrasi REST API:** Mengambil data katalog produk dari *server* publik secara *asynchronous* dengan penanganan *Error Handling* yang aman.
- **Pagination / Lazy Loading:** Mengambil data produk secara bertahap saat pengguna men-*scroll* layar ke bawah untuk menjaga performa memori (mencegah *lag* pada data besar).
- **Local Storage (SQLite & SharedPreferences):** - **SQLite:** Digunakan untuk menyimpan data Keranjang Belanja (*Cart*) agar persisten meski aplikasi ditutup tanpa memerlukan koneksi internet.
  - **SharedPreferences:** Digunakan untuk menyimpan sesi masuk (*Login Session*).
- **UI/UX Interaktif:** Dilengkapi navigasi yang intuitif (*Main Navigation/Bottom NavBar*), halaman detail produk, dan desain yang responsif.

---

## 🛠️ Teknologi & *Package* yang Digunakan
- **Framework:** Flutter (Versi 3.x) & Dart
- **State Management:** `flutter_bloc`, `equatable`
- **Networking:** `dio` / `http`
- **Local Database:** `sqflite`, `shared_preferences`

---

## 📂 Struktur Direktori (Clean Architecture)
Kode diatur menggunakan pendekatan *Feature-Based Clean Architecture* untuk memudahkan *maintenance* dan kolaborasi tim:

```text
lib/
 ┣ core/
 ┃ ┗ database_helper.dart      # Konfigurasi dan inisialisasi SQLite
 ┣ features/
 ┃ ┗ storemart/
 ┃   ┣ data/                   # API calls, Models (JSON Parsing), Local Data Sources
 ┃   ┣ domain/                 # Entities (Aturan bisnis inti)
 ┃   ┗ presentation/           
 ┃     ┣ bloc/                 # Event, State, dan logika BLoC
 ┃     ┗ screens/              # UI (Login, Product List, Detail, Cart, Profile)
 ┗ main.dart                   # Entry point aplikasi
