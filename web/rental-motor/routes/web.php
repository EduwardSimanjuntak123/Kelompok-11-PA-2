<?php

use App\Http\Controllers\AdminController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\KelolaBookingController;
use App\Http\Controllers\MotorController;
use App\Http\Controllers\nonaktifController;
use App\Http\Controllers\TransaksiController;
use App\Http\Controllers\ulasanController;
use App\Http\Controllers\VendorController;
use App\Http\Controllers\KecamatanController;
use App\Http\Controllers\TitikLokasiController;
use App\Http\Controllers\PerpanjanganSewaController;
use App\Http\Middleware\CheckAuth;
use App\Http\Middleware\RoleMiddleware;

// Halaman utama
Route::get('/', function () {
    return view('welcome');
});

// Grup route untuk tamu (belum login)
Route::middleware('guest')->group(function () {
    Route::view('/login', 'login')->name('login');
    Route::post('/login', [AuthController::class, 'login'])->name('login.post');
});

// Grup route untuk user yang sudah login
Route::middleware([CheckAuth::class])->group(function () {
    Route::get('/logout', [AuthController::class, 'logout'])->name('logout');

    // Route berdasarkan role admin
    Route::middleware(RoleMiddleware::class . ':admin')->group(function () {
        Route::get('/admin', function () {
            return view('admin.admin');
        })->name('admin');
        Route::get('/admin/vendors', [nonaktifController::class, 'index'])->name('admin.nonaktif');
        Route::post('/admin/deactivate/{id}', [nonaktifController::class, 'deactivate'])->name('vendor.deactivate');
        Route::put('/admin/activate-vendor/{id}', [nonaktifController::class, 'activate'])->name('vendor.activate');
        Route::put('/admin/profile/edit', [AdminController::class, 'updateProfile'])->name('admin.update');
        Route::get('/admin/profile/{id}', [AdminController::class, 'profile'])->name('admin.profile');
        Route::view('/nonaktif', 'nonaktif')->name('nonaktif');
        Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
        // Daftar kecamatan (index di /admin/kecamatan)
        Route::get('/admin/kecamatan', [KecamatanController::class, 'index'])
            ->name('admin.kecamatan');

        // Modal Tambah → menyimpan
        Route::post('/kecamatan', [KecamatanController::class, 'store'])
            ->name('kecamatan.store');

        // Modal Edit → form sudah di-handle di index lewat JS
// Update data kecamatan
        Route::put('/kecamatan/{id}', [KecamatanController::class, 'update'])
            ->name('kecamatan.update');

        // Hapus kecamatan
        Route::delete('/kecamatan/{id}', [KecamatanController::class, 'destroy'])
            ->name('kecamatan.destroy');

        // Daftar kecamatan (index di /admin/titiklokasi)
        Route::get('/admin/titiklokasi', [TitikLokasiController::class, 'index'])
            ->name('admin.titiklokasi');

        Route::post('/admin/titiklokasi/{id_kecamatan}', [TitikLokasiController::class, 'store'])
            ->name('titiklokasi.store');

        Route::put('admin/titiklokasi/{id}', [TitikLokasiController::class, 'update'])->name('titiklokasi.update');

        Route::delete('/admin/titiklokasi/{id}', [TitikLokasiController::class, 'destroy']);

    });

    // Route untuk vendor (penjual motor)
    Route::middleware([RoleMiddleware::class . ':vendor'])->prefix('vendor')->group(function () {
        // Dashboard Vendor
        Route::get('/dashboard/{id?}', [VendorController::class, 'dashboard'])->name('vendor.dashboard');

        // Kelola Motor
        Route::get('/motor', [MotorController::class, 'index'])->name('vendor.motor');
        Route::get('/transaksi', [TransaksiController::class, 'index'])->name('vendor.transaksi'); // Menampilkan daftar motor
        Route::get('/transaksi/export', [\App\Http\Controllers\TransaksiController::class, 'exportExcel'])->name('vendor.transactions.export');
        Route::post('/transaksi/add', [TransaksiController::class, 'addTransactionManual'])->name('vendor.transaksi.store');
        // Menampilkan daftar motor
        Route::post('/motor', [MotorController::class, 'store'])->name('motor.store');  // Menambah motor baru
        Route::get('/motor/{id}/edit', [MotorController::class, 'edit'])->name('motor.edit'); // Edit motor
        Route::put('/motor/{id}', [MotorController::class, 'update'])->name('motor.update'); // Update motor
        Route::delete('/motor/{id}', [MotorController::class, 'destroy'])->name('motor.destroy');  // Hapus motor

        // Vendor Profile
        Route::get('/profile/{id}', [VendorController::class, 'profile'])->name('vendor.profile'); // Melihat profil vendor
        Route::put('/profile/edit', [VendorController::class, 'updateProfile'])->name('vendor.profile.edit');
        // Cetak Laporan
        Route::view('/cetak', 'cetak')->name('cetak'); // Halaman cetak laporan

        // Kelola Booking
        Route::get('/bookings/{id}', [KelolaBookingController::class, 'index'])->name('vendor.kelola');
        Route::get('/reviewss/{id}', [ulasanController::class, 'index'])->name('vendor.ulasan');
        Route::post('/review/{id}/reply', [ulasanController::class, 'submitReply'])->name('reviews.submitReply');

        Route::post('/booking/add', [KelolaBookingController::class, 'addManualBooking'])
            ->name('vendor.manual.booking.store');
        Route::put('/bookings/{id}/confirm', [KelolaBookingController::class, 'confirm'])->name('vendor.booking.confirm');
        Route::put('/bookings/{id}/reject', [KelolaBookingController::class, 'rejectBooking'])->name('vendor.booking.reject');
        Route::put('/bookings/{id}/complete', [KelolaBookingController::class, 'complete'])->name('vendor.booking.complete');


        // Halaman Tambahan
        Route::view('/harga', 'harga')->name('harga');
        Route::view('/ulasan', 'ulasan')->name('ulasan');
        Route::view('/input', 'input')->name('input');

        // Index (parameter id bersifat optional)
        Route::get('/perpanjangansewa/{id?}', [PerpanjanganSewaController::class, 'index'])
            ->name('vendor.perpanjangansewa');

        // Setujui perpanjangan
        Route::post('/vendor/extensions/{extension_id}/approve', [PerpanjanganSewaController::class, 'approveExtension'])
            ->name('vendor.approveExtension');

        // Tolak perpanjangan
        Route::post('/vendor/extensions/{extension_id}/reject', [PerpanjanganSewaController::class, 'rejectExtension'])
            ->name('vendor.rejectExtension');




    });

});
