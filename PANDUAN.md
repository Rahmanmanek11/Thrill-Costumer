# Panduan Aplikasi Customer

## 1. Jalankan patch database (sekali saja)
Supabase → ☰ → SQL Editor → New query → tempel isi `patch-customer.sql` → Run.
Harus muncul "Success. No rows returned".

## 2. Pasang di Vercel (proyek BARU, terpisah dari driver)
1. GitHub → New repository → nama `customer-ojol` → Public.
2. Upload isi folder ini (index.html, config.js, sw.js, manifest.webmanifest, icon.svg) → Commit.
3. Vercel → Add New → Project → pilih `customer-ojol` → Deploy.
4. Buka alamat Vercel di Chrome → ⋮ → Tambahkan ke layar utama.

## 3. Uji coba (butuh 2 akun berbeda)
- Satu browser/HP hanya bisa login 1 akun per alamat web. Pakai HP lain, atau tab Samaran (Incognito).
- Setujui driver dulu (SQL Editor):  `update drivers set approved = true;`
- Driver: login → geser ONLINE → biarkan layar menyala.
- Customer: daftar akun customer → pilih tujuan → Pesan.
- Syarat order masuk ke driver: driver ONLINE, GPS aktif, jenis kendaraan sama (motor/mobil), jarak ≤ 5 km dari titik jemput.

## Catatan
- Pencarian alamat memakai OpenStreetMap Nominatim, rute memakai OSRM demo (gratis, cukup untuk skala kecil;
  jika usaha besar, ganti ke layanan berbayar).
- Tarif dihitung server. Tarif di layar hanya perkiraan dengan rumus yang sama.
- Pembayaran saat ini hanya tunai.
