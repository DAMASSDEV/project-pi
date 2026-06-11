# Spesifikasi Sistem Desain (Design System) - Project-PI

Dokumen ini mendokumentasikan spesifikasi desain visual (palet warna, tipografi, dan komponen UI) berdasarkan sheet desain yang Anda berikan. Dokumen ini menjadi acuan utama dalam pembuatan tema dan widget di Flutter.

---

## 1. Palet Warna (Color Palette)

Aplikasi menggunakan tema **Simple Healthy** dengan skema warna yang ramah kesehatan (medical/nutrition-focused):

| Kategori | Kode Hex | Visual & Penggunaan |
| :--- | :--- | :--- |
| **Primary** | `#108967` | Warna hijau tua (Forest/Emerald Green). Digunakan untuk tombol utama, warna aksen navigasi, dan elemen branding utama. |
| **Secondary** | `#F0FAF7` | Warna hijau pastel sangat muda (Off-white/Teal-white). Digunakan untuk latar belakang kartu (card), kontainer sekunder, dan area konten. |
| **Tertiary** | `#FFA500` | Warna jingga/amber. Digunakan untuk peringatan, indikator gizi tertentu, atau penekanan khusus (highlights). |
| **Neutral** | `#1A1C1E` | Warna arang gelap (Charcoal Black). Digunakan untuk teks utama (body & headline), latar belakang dark mode, dan tombol inverted. |

---

## 2. Tipografi (Typography)

Seluruh teks dalam aplikasi menggunakan font modern **Plus Jakarta Sans** dengan hirarki berikut:

*   **Headline**: Menggunakan font **Plus Jakarta Sans** dengan ukuran besar dan tebal (Bold/Extra Bold) untuk judul halaman, nama makanan yang terdeteksi, dan header utama.
*   **Body**: Menggunakan font **Plus Jakarta Sans** dengan ukuran standar (Regular/Medium) untuk isi konten, deskripsi makanan, dan teks obrolan.
*   **Label**: Menggunakan font **Plus Jakarta Sans** dengan ukuran kecil (Regular) untuk metadata, informasi detail gizi, teks tombol, dan sub-informasi.

---

## 3. Komponen UI & Gaya Visual (UI Components Styling)

### Tombol (Buttons)
1.  **Primary Button**:
    *   Latar belakang solid hijau `#108967`.
    *   Teks warna putih.
    *   Sudut membulat (*border radius* sekitar 8-12).
2.  **Secondary Button**:
    *   Latar belakang solid abu-abu/hijau terang `#F0FAF7` atau sejenisnya.
    *   Teks warna abu-abu gelap/hitam.
3.  **Inverted Button**:
    *   Latar belakang solid arang gelap `#1A1C1E`.
    *   Teks warna putih.
4.  **Outlined Button**:
    *   Latar belakang transparan.
    *   Border tipis dengan teks warna gelap/neutral.

### Bidang Input & Pencarian (Search Input)
*   Kotak pencarian berbentuk membulat (*border radius* sekitar 12-16) dengan warna dasar abu-abu/hijau muda sangat tipis.
*   Dilengkapi ikon pencarian (kaca pembesar) di sisi kiri sebagai ikon pembuka.

### Navigasi Bawah (Bottom Navigation Bar)
*   Desain melayang (*floating*) atau berjarak (*padding*) dari tepi layar bawah dengan latar belakang kontainer terang `#F0FAF7` dan sudut membulat lebar.
*   Ikon aktif (Home) diletakkan di dalam kontainer lingkaran hijau `#108967` dengan ikon warna putih di dalamnya.
*   Ikon non-aktif berwarna abu-abu/neutral gelap.

### Indikator & Badge Gizi
*   Menggunakan penanda kecil membulat untuk mewakili status gizi atau kategori makanan:
    *   Hijau (`#108967`) untuk gizi seimbang / kalori rendah.
    *   Kuning/Oranye (`#FFA500`) untuk konsumsi sedang.
    *   Merah (untuk peringatan/kandungan gizi berlebih).
    *   Cokelat/Amber untuk kategori khusus.

---

## 4. Rencana Implementasi di Flutter

Di dalam file kode Dart (misal di `app_theme.dart`), palet warna ini akan diimplementasikan sebagai berikut:

```dart
// Kode konfigurasi warna dasar
static const Color colorPrimary = Color(0xFF108967);
static const Color colorSecondary = Color(0xFFF0FAF7);
static const Color colorTertiary = Color(0xFFFFA500);
static const Color colorNeutral = Color(0xFF1A1C1E);
```

*Catatan: Semua file source code Flutter tidak akan memiliki komentar di dalamnya (Zero Comments), seluruh instruksi visual ini sepenuhnya diambil dari dokumen MD ini.*
