<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
class TransaksiController extends Controller
{

    protected $apiBaseUrl = 'http://localhost:8080'; // Pastikan API URL benar

    public function index()
    {
        // Node (1): Mulai fungsi index()
        try {
            // Node (2): Ambil token dari session
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI'); 
            
            // Node (3): Kirim permintaan API dengan token dan timeout 10 detik
            $response = Http::withToken($token)->timeout(10)->get("{$this->apiBaseUrl}/motor/vendor");
    
            // Node (4): Cek apakah respons API berhasil
            if ($response->successful()) {
                // Node (5): Ambil data dari response API dan simpan ke variabel $motors
                $motors = $response->json()['data'] ?? [];
                
                // Node (7): Iterasi setiap elemen dalam $motors untuk memproses data motor
                foreach ($motors as &$motor) {
                    // Memperbaiki URL gambar jika perlu
                    $motor['image_url'] = !empty($motor['image']) && !str_starts_with($motor['image'], 'http')
                        ? $this->apiBaseUrl . ltrim($motor['image'])
                        : $motor['image'];
                }
            } else {
                // Node (6): Jika respons tidak berhasil, log error dan set $motors ke array kosong
                Log::error("Gagal mengambil data motor. Status: " . $response->status());
                $motors = [];
            }
        } catch (\Exception $e) {
            // Node (8): Tangkap exception, log error, dan set $motors ke array kosong
            Log::error('Kesalahan saat mengambil data motor: ' . $e->getMessage());
            $motors = [];
        }
        // Node (9): Kembalikan view dengan data $motors
        return view('vendor.motor', compact('motors'));
        // Node (10): Selesai fungsi index()
    }
}
