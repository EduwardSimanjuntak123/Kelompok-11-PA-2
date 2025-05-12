 Dokumentasi API:

POST /login : untuk login pengguna
POST /send-otp : untuk mengirimkan otp register dan lupa katasandi
POST /verify-otp : digunkana untuk memferifikasi otp Register
POST /request-reset-password-otp :untuk meminta otp berdasarkan email yang dikirim
POST /verify-reset-password-otp : digunkana untuk memferivikasi otp lupa katasandi
POST /reset-password : digunana 
POST /change-password :

POST /customer/register                         :Registrasi customer
POST /customer/cancel-registration              :Membatalkan konfirmasi otp, menghapus dat regitrasi dari database
GET  /customer/motors                           :Menampilkan semua daftar motor
GET  /customer/motors/vendor/:vendor_id         :digunakan untuk mengambil semua daftar motor berdasrkan vendor yang dipilih
POST /customer/bookings                         :melakukan booking
GET  /customer/bookings                         :mengambil semua daftar booking dari customer
GET  /customer/profile                          :mengambil data profile customer                  
POST /customer/review/:id                       :membuat ulasan dari booking yang complete
GET  /customer/extensions                       :mengambil semua data perpanjngan booking
GET  /customer/bookings/:booking_id/extensions  :mengambil data perpanjangan booking berdasarkan id booking
PUT /customer/bookings/:id/cancel
POST /customer/bookings/:id/extend
GET /customer/transactions
PUT /customer/profile
PUT /customer/change-password




