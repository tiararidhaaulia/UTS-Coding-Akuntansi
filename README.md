# UTS Coding Akuntansi — FEB Universitas Diponegoro

Proyek Ujian Tengah Semester Coding Akuntansi untuk Program Studi S1 Akuntansi, Fakultas Ekonomika dan Bisnis, Universitas Diponegoro.

## Teknologi

* PostgreSQL melalui Supabase
* Node.js dan Express
* HTML, CSS, dan JavaScript
* Supabase RPC untuk penyimpanan voucher

## Fitur

### Soal 1 — Sistem Jurnal

* Tabel akun, header jurnal, dan baris jurnal.
* Primary key dan foreign key dengan `ON DELETE RESTRICT`.
* Validasi nilai debit dan kredit.
* Validasi keseimbangan jurnal sebelum posting.

### Soal 2 — Persediaan

* Trigger untuk memperbarui stok saat pembelian dan penjualan.
* Penolakan transaksi penjualan yang melebihi stok.
* Penguncian baris menggunakan `SELECT FOR UPDATE`.
* Penyesuaian stok berdasarkan hasil hitung fisik.

### Soal 3 — Voucher Kas Keluar

* Form input voucher berbasis web.
* Indikator keseimbangan debit dan kredit.
* Penyimpanan voucher melalui backend Express dan Supabase RPC.
* Perlindungan jurnal berstatus `POSTED` terhadap perubahan dan penghapusan.
* Pencatatan waktu pembuatan dan checksum jurnal.

## Struktur Folder

* `sql/` — skema, fungsi, trigger, dan skrip pengujian SQL.
* `public/` — HTML, CSS, dan JavaScript untuk antarmuka web.
* `docs/` — screenshot pengujian dan dokumentasi.
* `server.js` — backend Express.
* `.env` — konfigurasi rahasia koneksi, tidak untuk dipublikasikan.

## Cara Menjalankan

1. Instal Node.js.
2. Buka folder proyek di terminal.
3. Jalankan `npm install`.
4. Isi `.env` dengan `SUPABASE_URL` dan `SUPABASE_SERVICE_ROLE_KEY` milik proyek Supabase sendiri.
5. Jalankan `node server.js`.
6. Buka `http://localhost:3000` di browser.

## Pengujian

* Voucher kas keluar berhasil disimpan dengan debit dan kredit seimbang.
* Perubahan header jurnal `POSTED` ditolak.
* Perubahan baris jurnal `POSTED` ditolak.
* Trigger persediaan diperiksa melalui PostgreSQL.

## Dokumentasi Bukti

Screenshot hasil pengujian disimpan di folder `docs/`.

## Repository

Tambahkan URL repository GitHub setelah repository dibuat atau diperbarui.

## Catatan Keamanan

File `.env` dan service role key tidak boleh dimasukkan ke repository publik. Untuk penggunaan produksi, diperlukan autentikasi, pembatasan akses, dan pengamanan endpoint backend.
