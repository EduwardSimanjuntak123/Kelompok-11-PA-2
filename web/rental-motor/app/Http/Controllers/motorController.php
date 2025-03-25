<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MotorController extends Controller
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
    public function store(Request $request)
    {
        try {
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');

            // Validasi input
            $validated = $request->validate([
                'name'   => 'required|string|max:255',
                'brand'  => 'required|string|max:255',
                'model'  => 'required|string|max:255',
                'year'   => 'required|integer|min:1900|max:' . date('Y'),
                'color'  => 'required|string|max:255',
                'price'  => 'required|numeric|min:1000',
                'status' => 'required|in:available,booked,unavailable',
                'image'  => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
            ]);

            $multipart = [];
            foreach ($validated as $key => $value) {
                $multipart[] = ['name' => $key, 'contents' => $value];
            }

            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $multipart[] = [
                    'name'     => 'image',
                    'contents' => fopen($image->getPathname(), 'r'),
                    'filename' => $image->getClientOriginalName()
                ];
            }

            $response = Http::withToken($token)->asMultipart()->post("{$this->apiBaseUrl}/motor/vendor", $multipart);

            return $response->successful()
                ? redirect()->back()->with('message', 'Motor berhasil ditambahkan!')->with('type', 'success')
                : redirect()->back()->with('message', 'Gagal menambahkan motor.')->with('type', 'error');
        } catch (\Exception $e) {
            Log::error('Gagal menyimpan motor: ' . $e->getMessage());
            return redirect()->back()->with('message', 'Terjadi kesalahan server.')->with('type', 'error');
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');

            // Validasi input
            $validated = $request->validate([
                'name'   => 'required|string|max:255',
                'brand'  => 'required|string|max:255',
                'model'  => 'required|string|max:255',
                'year'   => 'required|integer|min:1900|max:' . date('Y'),
                'color'  => 'required|string|max:255',
                'price'  => 'required|numeric|min:1000',
                'status' => 'required|in:available,booked,unavailable',
                'image'  => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
            ]);

            $multipart = [];
            foreach ($validated as $key => $value) {
                if ($key !== 'image') {
                    $multipart[] = ['name' => $key, 'contents' => $value];
                }
            }

            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $multipart[] = [
                    'name'     => 'image',
                    'contents' => fopen($image->getPathname(), 'r'),
                    'filename' => $image->getClientOriginalName()
                ];
            }

            $response = Http::withToken($token)->asMultipart()->put("{$this->apiBaseUrl}/motor/vendor/{$id}", $multipart);

            return $response->successful()
                ? redirect()->route('vendor.motor')->with('message', 'Motor berhasil diperbarui!')->with('type', 'success')
                : redirect()->route('vendor.motor')->with('message', 'Gagal memperbarui motor.')->with('type', 'error');
        } catch (\Exception $e) {
            Log::error('Gagal update motor: ' . $e->getMessage());
            return redirect()->route('vendor.motor')->with('message', 'Terjadi kesalahan saat memperbarui motor.')->with('type', 'error');
        }
    }

    public function destroy($id)
    {
        try {
            Log::info("Menghapus motor dengan ID: " . $id);
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
            $response = Http::withToken($token)->delete("{$this->apiBaseUrl}/motor/vendor/{$id}");

            if ($response->successful()) {
                Log::info("Motor berhasil dihapus");
                return redirect()->back()->with('message', 'Motor berhasil dihapus.')->with('type', 'success');
            } else {
                Log::error("Gagal menghapus motor. Status: " . $response->status());
                return redirect()->back()->with('message', 'Gagal menghapus motor.')->with('type', 'error');
            }
        } catch (\Exception $e) {
            Log::error('Kesalahan saat menghapus motor: ' . $e->getMessage());
            return redirect()->back()->with('message', 'Terjadi kesalahan saat menghapus motor.')->with('type', 'error');
        }
    }
}
