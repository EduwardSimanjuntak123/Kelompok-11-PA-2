DOKUMENTASI API

✅ AUTHENTIKASI & OTP
POST /login                            : Login user
POST /send-otp                         : Mengirim OTP ke email
POST /verify-otp                       : Verifikasi OTP untuk login
POST /request-reset-password-otp       : Request OTP untuk reset password (butuh login)
POST /verify-reset-password-otp        : Verifikasi OTP untuk reset password
POST /reset-password                   : Reset password dengan login
POST /change-password                  : Ganti password menggunakan OTP

✅ BOOKING & REVIEW (Public)
GET /bookings/motor/:idmotor           : Melihat semua booking untuk motor tertentu
GET /reviews/motor/:id                 : Melihat review untuk motor tertentu
GET /reviews/vendor/:id                : Melihat review untuk vendor tertentu

✅ NOTIFIKASI (WebSocket & API)
GET    /ws/notifikasi                         : WebSocket notifikasi real-time
PUT    /notifications/:notification_id/status : Update status notifikasi
GET    /notifications                         : Mendapatkan notifikasi user yang login
DELETE /notifications/:notification_id        : Menghapus notifikasi tertentu

✅ MOTOR WEBSOCKET
GET /ws/motor                         : WebSocket untuk update motor

✅ CHAT / PESAN (User & Vendor)
GET    /ws/chat                       : WebSocket untuk chatting
POST   /chat/message                  : Mengirim pesan baru
GET    /chat/messages                 : Mengambil semua pesan dalam satu room
POST   /chat/room                     : Mendapatkan atau membuat chat room
GET    /chat/rooms                    : Mendapatkan semua chat room milik user
PUT    /chat/messages/:id/read        : Tandai pesan sebagai sudah dibaca
POST   /chat/mark-all-read            : Tandai semua pesan sebagai sudah dibaca
GET    /chat/unread                   : Mendapatkan jumlah pesan yang belum dibaca
DELETE /chat/room/:id                 : Menghapus chat room
GET    /chat/search                   : Mencari pesan dalam semua chat

✅ REKOMENDASI LOKASI
GET /location-recommendations          : Mendapatkan semua rekomendasi lokasi
GET /location-recommendations/:id      : Mendapatkan detail rekomendasi lokasi tertentu

✅ ADMIN ROUTES
GET    /admin/vendors                          : Melihat semua vendor
GET    /admin/transactions                     : Melihat semua transaksi
GET    /admin/users                            : Melihat semua pengguna
GET    /admin/profile                          : Melihat profil admin
PUT    /admin/profile/edit                     : Mengedit profil admin
PUT    /admin/activate-vendor/:id              : Mengaktifkan vendor
PUT    /admin/deactivate-vendor/:id            : Menonaktifkan vendor
GET    /admin/CustomerandVendor                : Mendapatkan data gabungan customer dan vendor
POST   /admin/location-recommendations         : Menambahkan rekomendasi lokasi
PUT    /admin/location-recommendations/:id     : Mengedit rekomendasi lokasi
DELETE /admin/location-recommendations/:id     : Menghapus rekomendasi lokasi
GET    /admin/vendor/:id/detail                : Melihat detail lengkap vendor

✅ CUSTOMER ROUTES
POST /customer/register                        : Registrasi sebagai customer
POST /customer/cancel-registration             : Membatalkan pendaftaran
GET  /customer/motors                          : Melihat semua motor
GET  /customer/motors/vendor/:vendor_id        : Melihat motor berdasarkan vendor

POST   /customer/bookings                      : Membuat booking baru
GET    /customer/bookings                      : Melihat semua booking customer
GET    /customer/profile                       : Melihat profil customer
POST   /customer/review/:id                    : Membuat review untuk vendor/motor
GET    /customer/extensions                    : Melihat permintaan perpanjangan
GET    /customer/bookings/:booking_id/extensions : Lihat semua perpanjangan untuk 1 booking
PUT    /customer/bookings/:id/cancel           : Membatalkan booking
POST   /customer/bookings/:id/extend           : Meminta perpanjangan booking
GET    /customer/transactions                  : Melihat riwayat transaksi customer
PUT    /customer/profile                       : Mengedit profil customer
PUT    /customer/change-password               : Mengubah password customer

✅ KECAMATAN ROUTES
GET /kecamatan/                                : Melihat semua kecamatan
GET /kecamatan/:id                             : Melihat detail kecamatan berdasarkan ID
POST   /kecamatan/                             : Menambahkan kecamatan baru
PUT    /kecamatan/:id                          : Mengedit kecamatan
DELETE /kecamatan/:id                          : Menghapus kecamatan

✅ MOTOR ROUTES
GET /motor/                                    : Melihat semua motor
GET /motor/:id                                 : Melihat detail motor
GET    /motor/vendor/                          : Melihat semua motor milik vendor
GET    /motor/vendor/:id                       : Melihat detail motor milik vendor
POST   /motor/vendor/                          : Menambahkan motor baru
PUT    /motor/vendor/:id                       : Mengedit motor
DELETE /motor/vendor/:id                       : Menghapus motor

✅ TRANSACTIONS ROUTES
GET  /transaction/           : Melihat semua transaksi milik vendor
POST /transaction/manual     : Menambahkan transaksi manual oleh vendor

✅ VENDOR ROUTES
GET  /vendor/:id                         : Melihat detail vendor berdasarkan ID
GET  /vendor/                            : Melihat daftar semua vendor
POST /vendor/register                    : Registrasi sebagai vendor
POST /vendor/cancel-registration         : Membatalkan pendaftaran
GET    /vendor/profile                   : Melihat profil vendor
PUT    /vendor/profile/edit              : Mengedit profil vendor
GET    /vendor/reviews                   : Melihat review untuk vendor
POST   /vendor/review/:id/reply          : Membalas review tertentu
POST   /vendor/manual/bookings           : Membuat booking manual
GET    /vendor/extensions                : Melihat permintaan perpanjangan booking
PUT    /vendor/extensions/:id/approve    : Menyetujui perpanjangan booking
PUT    /vendor/extensions/:id/reject     : Menolak perpanjangan booking
GET  /vendor/bookings                   : Melihat semua booking vendor
GET  /vendor/bookings/:id               : Melihat detail booking tertentu
PUT  /vendor/bookings/:id/confirm       : Mengonfirmasi booking
PUT  /vendor/bookings/:id/reject        : Menolak booking
PUT  /vendor/bookings/transit/:id       : Mengubah status booking menjadi "Transit"
PUT  /vendor/bookings/inuse/:id         : Mengubah status booking menjadi "Sedang digunakan"
PUT  /vendor/bookings/complete/:id      : Menyelesaikan booking



