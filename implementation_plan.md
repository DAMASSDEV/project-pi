# Rencana Setup & Arsitektur Project-PI

## Judul Proyek
**Rancang Bangun Aplikasi Android Deteksi Makanan Khas Bogor dan Estimasi Makronutrien Menggunakan YOLO dengan Pendekatan CRISP-DM**

---

## Rencana Penghentian Animasi Hover Maskot Onboarding

Menghentikan animasi hover/melayang vertikal pada kartu gambar robot di Onboarding Screen agar gambar tetap diam (statis) dan kokoh di posisinya sesuai dengan keinginan pengguna. Animasi mikro lainnya (latar belakang bernapas dan transisi tombol) tetap dipertahankan untuk menyempurnakan interaksi.

### 1. Perubahan Desain Utama (Onboarding)
* **Kartu Robot Statis**: Menghapus `AnimationController` lokal dari kartu robot dan mengembalikan `OnboardingContentCard` menjadi `StatelessWidget` tanpa pergeseran vertikal.
* *Catatan*: Seluruh berkas baru tidak akan memiliki komentar di dalamnya (Zero Comments).

### 2. Berkas yang Diubah
* **`lib/features/onboarding/presentation/widgets/onboarding_content_card.dart` [MODIFY]**: Mengembalikan widget menjadi `StatelessWidget` dan menghapus logic hover vertical translation.

---

## Rencana Verifikasi

### Pengujian Manual
* Menjalankan aplikasi untuk memastikan kartu putih robot di onboarding diam di tempatnya dan tidak bergoyang vertikal.
* Memastikan transisi geseran PageView dan pernapasan oror latar belakang tetap berjalan lancar.
