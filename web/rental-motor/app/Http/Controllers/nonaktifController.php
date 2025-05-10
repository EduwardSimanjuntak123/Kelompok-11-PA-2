<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class nonaktifController extends Controller
{
    protected $apiBaseUrl;

    public function __construct()
    {
        $this->apiBaseUrl = config('api.base_url');
    }

    /**
     * Menampilkan daftar vendor
     */
    public function index()
    {
        try {
            $token = session('token');

            if (!$token) {
                return redirect()->route('login')
                    ->with('error', 'Anda harus login terlebih dahulu.');
            }

            // Panggil endpoint API untuk mengambil daftar vendor
            $url = "{$this->apiBaseUrl}/admin/vendors";
            Log::info("Mengirim request ke: " . $url);

            $response = Http::withToken($token)
                ->timeout(10)
                ->get($url);

            Log::info("Response body: " . $response->body());

            // Cek response dan ambil data
            if ($response->successful() && is_array($response->json())) {
                // Map untuk build full URL gambar
                $vendors = collect($response->json())->map(function ($vendor) {
                    // Jika profile_image dimulai dengan http(s)
                    if (isset($vendor['profile_image']) && !preg_match('/^https?:\/\//', $vendor['profile_image'])) {
                        $vendor['profile_image'] = rtrim($this->apiBaseUrl, '/')
                            . '/' . ltrim($vendor['profile_image'], '/');
                    }
                    return $vendor;
                })->toArray();
            } else {
                Log::error("Gagal mengambil data vendor. Status: "
                    . $response->status() . " | Body: " . $response->body());
                $vendors = [];
            }

        } catch (\Exception $e) {
            Log::error('Exception saat mengambil data vendor: ' . $e->getMessage());
            $vendors = [];
        }

        // Kirim ke view
        return view('admin.nonaktif', compact('vendors'));
    }

    /**
     * Mengaktifkan vendor
     */
    public function activate($id)
    {
        $token = session('token');

        if (!$token) {
            return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
        }

        $url = "{$this->apiBaseUrl}/admin/activate-vendor/{$id}";
        Log::info("Mengirim request untuk mengaktifkan vendor ke: " . $url);

        $response = Http::withToken($token)->timeout(10)->put($url);
        Log::info("Response dari activation: " . $response->body());

        if ($response->successful()) {
            return redirect()->back()->with('message', 'Akun vendor berhasil diaktifkan kembali');
        } else {
            return redirect()->back()->with('error', 'Gagal mengaktifkan vendor');
        }
    }

    /**
     * Menonaktifkan vendor
     */
    public function deactivate($id)
    {
        $token = session('token');

        if (!$token) {
            return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
        }

        $url = "{$this->apiBaseUrl}/admin/deactivate-vendor/{$id}";
        Log::info("Mengirim request untuk menonaktifkan vendor ke: " . $url);

        $response = Http::withToken($token)->timeout(10)->put($url);
        Log::info("Response dari deactivation: " . $response->body());

        if ($response->successful()) {
            return redirect()->back()->with('message', 'Akun vendor berhasil dinonaktifkan');
        } else {
            return redirect()->back()->with('error', 'Gagal menonaktifkan vendor');
        }
    }
}
