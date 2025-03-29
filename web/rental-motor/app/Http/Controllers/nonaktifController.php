<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class nonaktifController extends Controller
{
    private $apiBaseUrl = 'http://localhost:8080'; // Sesuaikan dengan URL backend

    public function index()
    {
        try {
            $token = session('token');

            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
            }

            // Panggil endpoint untuk mendapatkan daftar vendor
            $url = "{$this->apiBaseUrl}/admin/vendors";
            Log::info("Mengirim request ke: " . $url);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token
            ])->timeout(10)->get($url);

            Log::info("Response body: " . $response->body());

            if ($response->successful() && is_array($response->json())) {
                $vendors = $response->json();
            } else {
                Log::error("Gagal mengambil data vendor. HTTP Status: " . $response->status() . " | Response: " . $response->body());
                $vendors = [];
            }
        } catch (\Exception $e) {
            Log::error('Gagal mengambil data vendor: ' . $e->getMessage());
            $vendors = [];
        }

        return view('admin.nonaktif', compact('vendors'));
    }
    public function activate($id)
{
    $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
    if (!$token) {
        return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
    }

    // URL API untuk mengaktifkan vendor
    $url = $this->apiBaseUrl . "/admin/activate-vendor/{$id}";
    Log::info("Mengirim request untuk mengaktifkan vendor ke: " . $url);

    // Kirim request PUT ke API
    $response = Http::withToken($token)
        ->timeout(10)
        ->put($url);

    Log::info("Response dari activation: " . $response->body());

    if ($response->successful()) {
        return redirect()->back()->with('message', 'Akun vendor berhasil diaktifkan kembali');
    } else {
        return redirect()->back()->with('error', 'Gagal mengaktifkan vendor');
    }
}


    public function deactivate($id)
    {
        $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
        if (!$token) {
            return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
        }
        // dd($id);

        // Buat URL endpoint; pastikan endpoint di backend Go sesuai (misalnya: /vendor/deactivate/{id})
        $url = $this->apiBaseUrl . "/admin/deactivate-vendor/{$id}";
        Log::info("Mengirim request untuk menonaktifkan vendor ke: " . $url);

        // Kirim request GET ke API (sesuai kode Go Anda yang menggunakan GET)
        $response = Http::withToken($token)
            ->timeout(10)
            ->put($url);
            // dd($response->body());


        Log::info("Response dari deactivation: " . $response->body());

        if ($response->successful()) {
            return redirect()->back()->with('message', 'Akun vendor berhasil dinonaktifkan');
        } else {
            return redirect()->back()->with('error', 'Gagal menonaktifkan vendor');
        }
    }
}
