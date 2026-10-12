# UTS Coding Akuntansi — FEB Universitas Diponegoro

Proyek Ujian Tengah Semester (UTS) Coding Akuntansi untuk Program Studi S1 Akuntansi, Fakultas Ekonomika dan Bisnis, Universitas Diponegoro.

Proyek ini mengimplementasikan sistem jurnal akuntansi, pengelolaan persediaan berbasis database trigger, serta aplikasi web untuk pencatatan Voucher Entri Transaksi Kas Keluar menggunakan PostgreSQL, Supabase, Node.js, dan Express.

## Repository

**GitHub:** https://github.com/tiararidhaaulia/UTS-Coding-Akuntansi

## Teknologi yang Digunakan

* **PostgreSQL** — basis data relasional, constraint, fungsi, dan trigger.
* **Supabase** — layanan PostgreSQL dan RPC untuk penyimpanan voucher.
* **Node.js dan Express** — backend aplikasi web.
* **HTML, CSS, dan JavaScript** — antarmuka pengguna.
* **Gemini Canvas** — bantuan AI dalam pembuatan rancangan antarmuka.
* **NotebookLM** — bantuan penelaahan sumber PSAK 207 tentang Laporan Arus Kas.

## Implementasi Soal

### Soal 1 — Sistem Jurnal Akuntansi

Implementasi mencakup:

* Tabel `chart_of_accounts` untuk menyimpan daftar akun.
* Tabel `journal_headers` untuk menyimpan informasi utama jurnal.
* Tabel `journal_lines` untuk menyimpan rincian debit dan kredit.
* Primary key dan foreign key dengan aturan `ON DELETE RESTRICT`.
* Constraint untuk mencegah nilai debit dan kredit negatif serta mencegah satu baris jurnal memiliki debit dan kredit sekaligus.
* Validasi keseimbangan debit dan kredit sebelum jurnal diubah menjadi `POSTED`.

Pemisahan header dan baris jurnal mendukung normalisasi data serta mengurangi duplikasi informasi. Relasi foreign key menjaga integritas referensial, sedangkan status posting dan perlindungan jurnal membantu mempertahankan jejak audit.

### Soal 2 — Pengelolaan Persediaan

Implementasi mencakup:

* Tabel `inventory_items` untuk menyimpan informasi barang dan jumlah stok.
* Tabel `inventory_transactions` untuk mencatat transaksi persediaan.
* Trigger `trg_update_stock_and_journal()` yang memperbarui stok secara otomatis saat transaksi dimasukkan.
* Transaksi `PURCHASE` menambah stok.
* Transaksi `SALE` mengurangi stok.
* Transaksi penjualan ditolak apabila jumlah yang diminta melebihi stok tersedia.
* Penguncian baris menggunakan `SELECT ... FOR UPDATE` untuk membantu mencegah konflik pembaruan stok secara bersamaan.
* Transaksi `ADJUSTMENT` menetapkan jumlah stok berdasarkan hasil penghitungan fisik.

**Catatan implementasi:** pada versi ini, trigger memperbarui stok persediaan dan belum menghasilkan jurnal akuntansi secara otomatis. Penyesuaian stok menggunakan nilai `qty` sebagai jumlah stok fisik akhir, dan skema saat ini mensyaratkan `qty > 0`.

### Soal 3 — Voucher Entri Transaksi Kas Keluar

Aplikasi web menyediakan form pencatatan voucher kas keluar dengan fitur:

* Input tanggal transaksi, nomor referensi, deskripsi, dan klasifikasi aktivitas arus kas.
* Penambahan baris jurnal secara dinamis.
* Pemilihan akun serta input nilai debit dan kredit.
* Indikator total debit, total kredit, dan selisih secara langsung.
* Tombol penyimpanan yang dinonaktifkan apabila jurnal belum memenuhi validasi keseimbangan.
* Pengiriman data ke backend Express untuk diproses melalui Supabase RPC.
* Validasi ulang di database dan posting jurnal setelah seluruh baris jurnal seimbang.
* Pencatatan waktu pembuatan dan checksum jurnal.
* Perlindungan header dan baris jurnal berstatus `POSTED` terhadap perubahan maupun penghapusan.

Jurnal yang telah berstatus `POSTED` tidak boleh diedit atau dihapus melalui operasi biasa. Koreksi transaksi yang telah diposting direncanakan menggunakan mekanisme jurnal pembalik (*reversal*).

## Struktur Folder

```text
UTS-Coding-Akuntansi/
├── docs/
│   ├── erd_database.png
│   ├── verifikasi_psak_207.md
│   └── bukti pengujian dan dokumentasi lainnya
├── public/
│   ├── index.html
│   ├── style.css
│   └── app.js
├── sql/
│   ├── 01_schema.sql
│   ├── 02_journal_validation.sql
│   ├── 03_inventory_schema.sql
│   ├── 04_inventory_trigger.sql
│   ├── 05_inventory_test.sql
│   ├── 06_audit_and_voucher_rpc.sql
│   └── 07_posted_journal_protection.sql
├── server.js
├── package.json
├── package-lock.json
├── .gitignore
└── README.md
```

File `.env` disimpan secara lokal dan tidak disertakan dalam repository publik.

## Cara Menjalankan Aplikasi

### Prasyarat

* Node.js dan npm sudah terpasang.
* Proyek Supabase dengan skema dan fungsi SQL yang diperlukan sudah disiapkan.

### Langkah menjalankan

1. Clone repository dan masuk ke folder proyek:

   ```bash
   git clone https://github.com/tiararidhaaulia/UTS-Coding-Akuntansi.git
   cd UTS-Coding-Akuntansi
   ```

2. Instal dependensi:

   ```bash
   npm install
   ```

3. Buat file `.env` di direktori utama proyek dan isi dengan kredensial Supabase milik sendiri:

   ```env
   SUPABASE_URL=URL_PROYEK_SUPABASE
   SUPABASE_SERVICE_ROLE_KEY=SERVICE_ROLE_KEY_SUPABASE
   ```

   Ganti nilai contoh tersebut dengan kredensial yang benar. Jangan pernah memasukkan nilai rahasia ke repository publik.

4. Pastikan skema, fungsi, RPC, dan trigger SQL yang dibutuhkan sudah diterapkan di database Supabase sesuai urutan file SQL dan kondisi database.

5. Jalankan backend:

   ```bash
   node server.js
   ```

6. Buka aplikasi melalui browser:

   http://localhost:3000

## Pengujian

Pengujian yang telah dilakukan pada lingkungan pengembangan meliputi:

* Pembuatan dan validasi struktur tabel jurnal.
* Validasi keseimbangan debit dan kredit sebelum posting.
* Pengujian trigger persediaan untuk pembelian, penjualan, dan penolakan penjualan yang melebihi stok.
* Pengujian penyimpanan voucher kas keluar dengan debit dan kredit seimbang.
* Pengujian penolakan perubahan header jurnal berstatus `POSTED`.
* Pengujian penolakan perubahan baris jurnal berstatus `POSTED`.
* Pemeriksaan trigger persediaan melalui PostgreSQL.
* Dokumentasi hasil pengujian dalam bentuk screenshot pada folder `docs/`.

Hasil pengujian tersebut berlaku untuk skenario yang telah dijalankan pada lingkungan pengembangan dan tidak dengan sendirinya membuktikan seluruh kemungkinan kasus telah diuji.

## Dokumentasi dan Verifikasi PSAK 207

Dokumentasi proyek tersedia di folder `docs/`, termasuk ERD database, bukti penggunaan Gemini Canvas, bukti pengujian voucher, bukti perlindungan jurnal `POSTED`, serta catatan verifikasi melalui NotebookLM.

Penelaahan sumber PSAK 207 tentang Laporan Arus Kas digunakan untuk memeriksa klasifikasi arus kas ke dalam aktivitas operasi, investasi, dan pendanaan.

Berdasarkan hasil penelaahan sumber yang didokumentasikan, klasifikasi aktivitas arus kas merupakan pokok bahasan PSAK 207. Sementara itu, validasi debit dan kredit, perlindungan jurnal `POSTED`, serta checksum merupakan kontrol teknis dan desain aplikasi; hasil penelaahan tersebut tidak menyatakan bahwa semua kontrol itu diwajibkan secara langsung oleh sumber PSAK 207 yang digunakan.

## Catatan Keamanan

* File `.env` dan `SUPABASE_SERVICE_ROLE_KEY` tidak boleh diunggah ke repository publik.
* Service role key memiliki hak akses tinggi dan hanya digunakan pada backend tepercaya.
* Aplikasi ini merupakan proyek akademik dan belum dimaksudkan untuk langsung digunakan dalam lingkungan produksi.
* Penggunaan produksi memerlukan autentikasi, otorisasi, pembatasan akses endpoint, konfigurasi Row Level Security yang sesuai, serta pengelolaan rahasia yang aman.

## Tujuan Proyek

Proyek ini bertujuan menerapkan konsep basis data relasional, integritas data, trigger, validasi transaksi, pengendalian persediaan, dan pengembangan aplikasi akuntansi berbasis web sebagai bagian dari UTS Coding Akuntansi.
