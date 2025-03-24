<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    public function dashboard($id = null)
    {
        // Jika $id tidak ada, coba ambil dari session
        if (!$id) {
            $id = session('user_id');
        }
    
        // Jika masih tidak ada, redirect ke halaman login dengan pesan error
        if (!$id) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }
    
        return view('vendor.dashboard', compact('id'));
    }
    
    
    public function profile()
    {
        // Ambil token autentikasi dari sesi
        $token = Session::get('token');

        // Pastikan token ada, jika tidak ada redirect ke login
        if (!$token) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }

        // Panggil API untuk mendapatkan data profil vendor
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->get('http://localhost:8080/vendor/profile');

        // Periksa apakah respons berhasil
        if ($response->failed()) {
            return redirect()->route('vendor.dashboard')->with('error', 'Gagal mengambil data profil vendor.');
        }

        // Ambil data dalam format JSON
        $vendorData = $response->json();

        // Kirim data ke view vendor.profile
        return view('vendor.profile', compact('vendorData'));
    }
}
