<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Log;

class VendorController extends Controller
{
    protected $apiBaseUrl = 'http://localhost:8080';

    // Menampilkan profil vendor
    public function profile()
    {
        $token = Session::get('token');
        if (!$token) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }

        // Panggil API untuk mendapatkan data profil vendor
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->get($this->apiBaseUrl . '/vendor/profile');

        if ($response->failed()) {
            return redirect()->route('vendor.dashboard')->with('error', 'Gagal mengambil data profil vendor.');
        }

        // Ambil data user dari respons API
        $data = $response->json();
        // Asumsikan struktur respons mengandung key "user"
        $user = $data['user'] ?? null;
        if (!$user) {
            return redirect()->route('vendor.dashboard')->with('error', 'Data profil vendor tidak lengkap.');
        }

        return view('vendor.profile', compact('user'));
    }
    public function dashboard($id = null)
    {
        // Jika ID tidak diberikan, ambil dari session (user_id)
        if (!$id) {
            $id = session('user_id');
        }

        // Jika ID masih tidak ditemukan, redirect ke halaman login
        if (!$id) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }

        // Opsional: Ambil data dashboard dari API backend vendor
        // Contoh: memanggil endpoint /vendor/dashboard/{id}
        $token = session()->get('token');
        $dashboardData = [];
        if ($token) {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
            ])->get($this->apiBaseUrl . '/vendor/dashboard/' . $id);

            if ($response->successful()) {
                $dashboardData = $response->json();
            }
        }

        // Kembalikan view dashboard dengan data (jika ada) dan ID user
        return view('vendor.dashboard', compact('dashboardData', 'id'));
    }
    // Mengupdate profil vendor dengan data form-data
    public function updateProfile(Request $request)
    {
        try {
            $token = Session::get('token', 'TOKEN_KAMU_DI_SINI');
            $multipart = [];

            // Data User
            if ($name = $request->input('name')) {
                $multipart[] = ['name' => 'name', 'contents' => $name];
            }
            if ($email = $request->input('email')) {
                $multipart[] = ['name' => 'email', 'contents' => $email];
            }
            if ($phone = $request->input('phone')) {
                $multipart[] = ['name' => 'phone', 'contents' => $phone];
            }
            if ($address = $request->input('address')) {
                $multipart[] = ['name' => 'address', 'contents' => $address];
            }
            if ($password = $request->input('password')) {
                // Disarankan untuk meng-hash password, sesuaikan kebutuhan Anda
                $multipart[] = ['name' => 'password', 'contents' => $password];
            }

            // Data Vendor
            if ($shopName = $request->input('shop_name')) {
                $multipart[] = ['name' => 'shop_name', 'contents' => $shopName];
            }
            if ($shopAddress = $request->input('shop_address')) {
                $multipart[] = ['name' => 'shop_address', 'contents' => $shopAddress];
            }
            if ($shopDescription = $request->input('shop_description')) {
                $multipart[] = ['name' => 'shop_description', 'contents' => $shopDescription];
            }
            if ($idKecamatan = $request->input('id_kecamatan')) {
                $multipart[] = ['name' => 'id_kecamatan', 'contents' => $idKecamatan];
            }

            // Tangani file profile_image jika ada
            if ($request->hasFile('profile_image')) {
                $image = $request->file('profile_image');
                $multipart[] = [
                    'name' => 'profile_image',
                    'contents' => fopen($image->getPathname(), 'r'),
                    'filename' => $image->getClientOriginalName()
                ];
            }
            // Tangani file ktp_image jika ada
            if ($request->hasFile('ktp_image')) {
                $file = $request->file('ktp_image');
                $multipart[] = [
                    'name' => 'ktp_image',
                    'contents' => fopen($file->getPathname(), 'r'),
                    'filename' => $file->getClientOriginalName()
                ];
            }

            // Update waktu
            $multipart[] = ['name' => 'updated_at', 'contents' => now()->toDateTimeString()];

            // Kirim request PUT ke API backend vendor
            $response = Http::withToken($token)
                ->asMultipart()
                ->put($this->apiBaseUrl . '/vendor/profile/edit', $multipart);

            if ($response->successful()) {
                return redirect()->back()->with('message', 'Profil vendor berhasil diperbarui')->with('type', 'success');
            }
            Log::error("Gagal memperbarui profil vendor. Status: " . $response->status());
            return redirect()->back()->with('message', 'Gagal memperbarui profil vendor')->with('type', 'error');
        } catch (\Exception $e) {
            Log::error("Terjadi kesalahan saat memperbarui profil vendor: " . $e->getMessage());
            return redirect()->back()->with('message', 'Terjadi kesalahan server')->with('type', 'error');
        }
    }
}
