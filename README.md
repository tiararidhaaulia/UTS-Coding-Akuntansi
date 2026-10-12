# UTS Coding Akuntansi — FEB Universitas Diponegoro

Proyek Ujian Tengah Semester (UTS) Coding Akuntansi untuk Program Studi S1 Akuntansi, Fakultas Ekonomika dan Bisnis, Universitas Diponegoro.

Proyek ini mengimplementasikan sistem jurnal akuntansi, pengelolaan persediaan menggunakan database trigger, serta aplikasi web Voucher Entri Transaksi Kas Keluar berbasis PostgreSQL, Supabase, Node.js, dan Express.

## Repository

**GitHub:** https://github.com/tiararidhaaulia/UTS-Coding-Akuntansi

## Teknologi

* PostgreSQL melalui Supabase
* Node.js dan Express
* HTML, CSS, dan JavaScript
* Supabase RPC untuk penyimpanan voucher
* Gemini Canvas untuk membantu perancangan antarmuka
* NotebookLM untuk menelaah sumber PSAK 207 tentang Laporan Arus Kas

## Implementasi Soal

### Soal 1 — Sistem Jurnal Akuntansi

* Tabel `chart_of_accounts` untuk daftar akun.
* Tabel `journal_headers` untuk informasi utama jurnal.
* Tabel `journal_lines` untuk rincian debit dan kredit.
* Primary key dan foreign key dengan aturan `ON DELETE RESTRICT`.
* Constraint untuk mencegah nilai debit dan kredit negatif.
* Validasi agar satu baris jurnal tidak memiliki debit dan kredit sekaligus.
* Validasi keseimbangan debit dan kredit sebelum jurnal diposting.

Pemisahan header dan baris jurnal mendukung normalisasi data. Foreign key menjaga integritas referensial, sedangkan status posting membantu mempertahankan jejak audit.

### Soal 2 — Pengelolaan Persediaan

* Tabel `inventory_items` untuk data barang dan jumlah stok.
* Tabel `inventory_transactions` untuk transaksi persediaan.
* Trigger `trg_update_stock_and_journal()` untuk memperbarui stok saat transaksi dimasukkan.
* Transaksi `PURCHASE` menambah stok.
* Transaksi `SALE` mengurangi stok.
* Penjualan ditolak apabila stok tidak mencukupi.
* Penguncian baris dengan `SELECT ... FOR UPDATE` untuk membantu mencegah konflik pembaruan stok secara bersamaan.
* Transaksi `ADJUSTMENT` menetapkan stok berdasarkan hasil penghitungan fisik.

**Catatan:** pada implementasi ini, trigger memperbarui jumlah stok dan belum menghasilkan jurnal akuntansi persediaan secara otomatis. Penyesuaian stok menggunakan `qty` sebagai jumlah stok fisik akhir. Skema saat ini mensyaratkan `qty > 0`.

### Soal 3 — Voucher Entri Transaksi Kas Keluar

* Form voucher berbasis web.
* Input tanggal, nomor referensi, deskripsi, klasifikasi aktivitas arus kas, dan rincian jurnal.
* Penambahan baris jurnal secara dinamis.
* Indikator total debit, total kredit, dan selisih secara langsung.
* Tombol simpan dinonaktifkan apabila jurnal belum memenuhi validasi keseimbangan.
* Backend Express mengirim data ke Supabase RPC.
* Database memvalidasi rincian jurnal dan keseimbangan sebelum posting.
* Pencatatan waktu pembuatan dan checksum jurnal.
* Perlindungan header dan baris jurnal berstatus `POSTED` terhadap perubahan dan penghapusan.

Jurnal berstatus `POSTED` tidak boleh diedit atau dihapus melalui operasi biasa. Koreksi jurnal yang telah diposting direncanakan menggunakan mekanisme jurnal pembalik (*reversal*).

## Struktur Folder

```text
UTS-Coding-Akuntansi/
├── docs/
│   ├── bukti_gemini_canvas 1.png
│   ├── bukti_gemini_canvas 2.png
│   ├── bukti_prompt_gemini.png
│   ├── bukti_proteksi_baris.png
│   ├── bukti_proteksi_header.png
│   ├── bukti_proteksi_header_kk005.png
│   ├── bukti_verifikasi_notebooklm.png
│   ├── bukti_voucher_berhasil 1.png
│   ├── bukti_voucher_berhasil 2.png
│   ├── bukti_voucher_kk_uts_005 1.png
│   ├── bukti_voucher_kk_uts_005 2.png
│   ├── erd_database.png
│   └── verifikasi_psak_207.md
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

File `.env` disimpan secara lokal dan tidak disertakan dalam repository publik. Folder `node_modules/` juga tidak disertakan karena dependensi dapat dipasang kembali menggunakan npm.

## Cara Menjalankan Aplikasi

### Prasyarat

* Node.js dan npm sudah terpasang.
* Proyek Supabase sudah tersedia.
* Skema, fungsi, RPC, dan trigger SQL yang dibutuhkan sudah diterapkan pada database Supabase.

### Langkah menjalankan

1. Clone repository:

   ```bash
   git clone https://github.com/tiararidhaaulia/UTS-Coding-Akuntansi.git
   cd UTS-Coding-Akuntansi
   ```

2. Instal dependensi:

   ```bash
   npm install
   ```

3. Buat file `.env` di folder utama proyek dan isi menggunakan kredensial Supabase milik sendiri:

   ```env
   SUPABASE_URL=URL_PROYEK_SUPABASE
   SUPABASE_SERVICE_ROLE_KEY=SERVICE_ROLE_KEY_SUPABASE
   ```

   Ganti nilai contoh dengan kredensial yang benar. Jangan memasukkan nilai rahasia ke repository publik.

4. Terapkan file SQL sesuai kebutuhan dan urutan implementasi pada folder `sql/`.

5. Jalankan backend:

   ```bash
   node server.js
   ```

6. Buka aplikasi di browser:

   http://localhost:3000

## Pengujian

Pengujian yang telah dilakukan pada lingkungan pengembangan meliputi:

* Pembuatan struktur tabel dan constraint jurnal.
* Validasi keseimbangan debit dan kredit sebelum posting.
* Pengujian trigger persediaan untuk pembelian dan penjualan.
* Penolakan penjualan ketika stok tidak mencukupi.
* Penyimpanan voucher kas keluar dengan debit dan kredit seimbang.
* Penolakan perubahan header jurnal berstatus `POSTED`.
* Penolakan perubahan baris jurnal berstatus `POSTED`.
* Pemeriksaan trigger persediaan melalui PostgreSQL.

Screenshot pengujian dan dokumentasi terkait tersedia di folder `docs/`. Hasil pengujian mencerminkan skenario yang telah dijalankan dan tidak menyatakan bahwa seluruh kemungkinan kasus telah diuji.

## Dokumentasi dan Verifikasi PSAK 207

Dokumentasi proyek mencakup:

* `docs/erd_database.png` — diagram relasi database.
* `docs/bukti_gemini_canvas 1.png` dan `docs/bukti_gemini_canvas 2.png` — bukti penggunaan Gemini Canvas.
* `docs/bukti_prompt_gemini.png` — dokumentasi prompt Gemini.
* `docs/bukti_voucher_berhasil 1.png` dan `docs/bukti_voucher_berhasil 2.png` — bukti pengujian voucher.
* `docs/bukti_voucher_kk_uts_005 1.png` dan `docs/bukti_voucher_kk_uts_005 2.png` — bukti voucher KK-UTS-005.
* `docs/bukti_proteksi_header.png` dan `docs/bukti_proteksi_header_kk005.png` — bukti perlindungan header jurnal.
* `docs/bukti_proteksi_baris.png` — bukti perlindungan baris jurnal.
* `docs/bukti_verifikasi_notebooklm.png` dan `docs/verifikasi_psak_207.md` — bukti dan catatan verifikasi sumber PSAK 207.

Penelaahan sumber PSAK 207 digunakan untuk memeriksa klasifikasi arus kas ke dalam aktivitas operasi, investasi, dan pendanaan. Berdasarkan hasil penelaahan yang didokumentasikan, klasifikasi aktivitas arus kas merupakan pokok bahasan PSAK 207. Validasi debit-kredit, perlindungan jurnal `POSTED`, dan checksum merupakan kontrol teknis aplikasi; sumber yang ditelaah tidak secara langsung mengonfirmasi bahwa seluruh kontrol tersebut diwajibkan oleh PSAK 207.

## Catatan Keamanan

* Jangan mengunggah file `.env` atau `SUPABASE_SERVICE_ROLE_KEY` ke repository publik.
* Service role key memiliki hak akses tinggi dan hanya boleh digunakan pada backend tepercaya.
* Aplikasi ini dibuat untuk keperluan akademik dan belum ditujukan untuk penggunaan produksi.
* Penggunaan produksi memerlukan autentikasi, otorisasi, pembatasan akses endpoint, konfigurasi Row Level Security yang tepat, serta pengelolaan rahasia yang aman.

## Tujuan Proyek

Proyek ini bertujuan menerapkan konsep basis data relasional, integritas data, trigger, validasi transaksi, pengendalian persediaan, dan pengembangan aplikasi akuntansi berbasis web sebagai bagian dari UTS Coding Akuntansi.
