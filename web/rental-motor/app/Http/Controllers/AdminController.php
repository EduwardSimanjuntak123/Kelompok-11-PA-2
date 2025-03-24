<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;

class AdminController extends Controller
{

    public function profile()
    {
        // Ambil token autentikasi dari sesi
        $token = Session::get('token');

        // Pastikan token ada
        if (!$token) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }

        // Panggil API untuk mendapatkan data profil admin
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->get('http://localhost:8080/admin/profile');

        // Periksa apakah respons berhasil
        if ($response->failed()) {
            return redirect()->route('admin')->with('error', 'Gagal mengambil data profil admin.');
        }

        $adminData = $response->json();

        // Kirim data ke view
        return view('admin.profile', compact('adminData'));
    }
}