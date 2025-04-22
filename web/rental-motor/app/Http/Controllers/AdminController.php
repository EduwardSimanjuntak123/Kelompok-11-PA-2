<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Log;

class AdminController extends Controller
{
    protected $apiBaseUrl;

    public function __construct()
    {
        $this->apiBaseUrl = config('api.base_url');
    }
    public function dashboard()
    {
        $token = session()->get('token');

        if (!$token) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }

        $response = Http::withToken($token)->get("{$this->apiBaseUrl}/admin/CustomerandVendor");

        if ($response->failed()) {
            Log::error('Gagal fetch data dari API /admin/CustomerandVendor', [
                'status' => $response->status(),
                'body' => $response->body()
            ]);
        }

        $labels = [];
        $vendorCounts = [];
        $customerCounts = [];

        // Inisialisasi 5 bulan: 2 bulan sebelum, bulan sekarang, 2 bulan sesudah
        $now = \Carbon\Carbon::now();
        $range = [];

        for ($i = -2; $i <= 2; $i++) {
            $month = $now->copy()->addMonths($i)->translatedFormat('F Y'); // Contoh: April 2025
            $range[$month] = ['vendor' => 0, 'customer' => 0];
        }

        if ($response->successful()) {
            $users = $response->json();

            foreach ($users as $user) {
                if (!isset($user['created_at'], $user['role']))
                    continue;

                $createdMonth = \Carbon\Carbon::parse($user['created_at'])->translatedFormat('F Y');

                // Hanya proses jika bulan ada dalam range
                if (array_key_exists($createdMonth, $range)) {
                    $role = $user['role'];
                    if ($role === 'vendor') {
                        $range[$createdMonth]['vendor']++;
                    } elseif ($role === 'customer') {
                        $range[$createdMonth]['customer']++;
                    }
                }
            }

            // Siapkan data untuk Chart.js
            $labels = array_keys($range);
            $vendorCounts = array_column($range, 'vendor');
            $customerCounts = array_column($range, 'customer');
        }

        return view('admin.admin', [
            'labels' => $labels,
            'vendorCounts' => $vendorCounts,
            'customerCounts' => $customerCounts,
        ]);
    }




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
        ])->get($this->apiBaseUrl . '/admin/profile');

        // Periksa apakah respons berhasil
        if ($response->failed()) {
            return redirect()->route('admin')->with('error', 'Gagal mengambil data profil admin.');
        }

        $adminData = $response->json();

        // Kirim data ke view
        return view('admin.profile', compact('adminData'));
    }


    public function updateProfile(Request $request)
    {
        try {
            // Ambil token dari session
            $token = session()->get('token');
            if (!$token) {
                return redirect()->route('login')->with('message', 'Anda harus login terlebih dahulu.')->with('type', 'error');
            }
            $multipart = [];
            // Ambil data input jika tersedia
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
                $multipart[] = ['name' => 'password', 'contents' => $password];
            }
            if ($status = $request->input('status')) {
                $multipart[] = ['name' => 'status', 'contents' => $status];
            }
            if ($role = $request->input('role')) {
                $multipart[] = ['name' => 'role', 'contents' => $role];
            }

            // Tangani upload foto profil
            if ($request->hasFile('profile_image')) {
                $image = $request->file('profile_image');
                $multipart[] = [
                    'name' => 'profile_image',
                    'contents' => fopen($image->getPathname(), 'r'),
                    'filename' => $image->getClientOriginalName()
                ];
            }

            // Kirim PUT request ke API Golang
            $response = Http::withToken($token)
                ->asMultipart()
                ->put("{$this->apiBaseUrl}/admin/profile/edit", $multipart);

            // Jika berhasil
            if ($response->successful()) {
                return redirect()->back()->with('message', 'Profil berhasil diperbarui')->with('type', 'success');
            }

            // Jika gagal tapi bukan exception
            Log::error("Gagal memperbarui profil. Status: " . $response->status());
            return redirect()->back()->with('message', 'Gagal memperbarui profil')->with('type', 'error');
        } catch (\Exception $e) {
            Log::error("Terjadi kesalahan saat memperbarui profil: " . $e->getMessage());
            return redirect()->back()->with('message', 'Terjadi kesalahan server')->with('type', 'error');
        }
    }
    public function kelolaKecamatan()
    {
        // Logika ambil data kecamatan, kalau mau.
        return view('admin.kecamatan'); // Misal ini file view-nya.
    }

}
