<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MotorController extends Controller
{
    protected $apiBaseUrl = 'http://localhost:8080'; // Pastikan API URL sudah benar

    public function index()
    {
        try {
            $token = session('token') ?? 'TOKEN_KAMU_DI_SINI'; // Token dari session atau default
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token
            ])->timeout(10)->get($this->apiBaseUrl . '/motor/vendor'); // Ambil data motor

            $motors = [];

            if ($response->successful()) {
                $motors = $response->json()['data'] ?? []; // Ambil data motor dari response

                // Proses image URL jika ada
                foreach ($motors as &$motor) {
                    if (!empty($motor['image'])) {
                        $motor['image_url'] = str_starts_with($motor['image'], 'http')
                            ? $motor['image']
                            : $this->apiBaseUrl . ltrim($motor['image']);
                    } else {
                        $motor['image_url'] = null;
                    }
                }
            } else {
                Log::error("Gagal mengambil data motor. HTTP Status: " . $response->status());
            }
        } catch (\Exception $e) {
            Log::error('Gagal mengambil data motor: ' . $e->getMessage());
        }

        // Kembalikan data motor ke view
        return view('vendor.motor', ['motors' => $motors]);
    }

    public function store(Request $request)
    {
       
        try {
            $token = session('token') ?? 'TOKEN_KAMU_DI_SINI'; // Ambil token dari session

            // Validasi input data motor
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'brand' => 'required|string|max:255',
                'model' => 'required|string|max:255',
                'year' => 'required|integer|min:1900|max:' . date('Y'),
                'color' => 'required|string|max:255',
                'price' => 'required|numeric|min:1000',
                'status' => 'required|in:available,booked,unavailable',
                'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
            ]);

            $multipart = [];

            foreach ($validated as $key => $value) {
                $multipart[] = [
                    'name' => $key,
                    'contents' => $value
                ];
            }

            // Menangani file gambar jika ada
            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $multipart[] = [
                    'name' => 'image',
                    'contents' => fopen($image->getPathname(), 'r'),
                    'filename' => $image->getClientOriginalName()
                ];
            }

            // Kirim request POST ke API untuk menambah motor
            $response = Http::withToken($token)
                ->asMultipart()
                ->post($this->apiBaseUrl . '/motor/vendor', $multipart);

            // Menangani respons sukses atau gagal
            if ($response->successful()) {
                return redirect()->back()->with('message', 'Motor berhasil ditambahkan!')->with('type', 'success');
            }

            return redirect()->back()->with('message', 'Gagal menambahkan motor.')->with('type', 'error');
        } catch (\Exception $e) {
            Log::error('Gagal menyimpan motor: ' . $e->getMessage());
            return redirect()->back()->with('message', 'Terjadi kesalahan server.')->with('type', 'error');
        }
    }

    // Fungsi update untuk memperbarui motor
    public function update(Request $request, $id)
    {
        // dd(session('token'));
        try {
            $token = session('token') ?? 'TOKEN_KAMU_DI_SINI'; // Ambil token dari session
            dd($token );
            // Validasi input data motor yang diperbarui
            $validatedData = $request->validate([
                'name' => 'required|string|max:255',
                'brand' => 'required|string|max:255',
                'model' => 'required|string|max:255',
                'year' => 'required|integer|min:1900|max:' . date('Y'),
                'color' => 'required|string|max:255',
                'price' => 'required|numeric|min:1000',
                'status' => 'required|in:available,booked,unavailable',
                'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048' // Validasi gambar
            ]);

            $multipart = [];

            // Menambahkan data motor ke dalam multipart kecuali image
            foreach ($validatedData as $key => $value) {
                if ($key !== 'image') {
                    $multipart[] = [
                        'name' => $key,
                        'contents' => $value
                    ];
                }
            }

            // Menangani gambar baru yang di-upload
            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $multipart[] = [
                    'name' => 'image',
                    'contents' => fopen($image->getPathname(), 'r'),
                    'filename' => $image->getClientOriginalName()
                ];
            }

            // Kirim request PUT ke API untuk update data motor
            $response = Http::withToken($token)
                ->asMultipart()
                ->put("{$this->apiBaseUrl}/motor/vendor/{$id}", $multipart);

            if ($response->successful()) {
                return redirect()->route('vendor.motor')->with('message', 'Motor berhasil diperbarui!')->with('type', 'success');
            }

            return redirect()->route('vendor.motor')->with('message', 'Gagal memperbarui motor.')->with('type', 'error');
        } catch (\Exception $e) {
            Log::error('Gagal update motor: ' . $e->getMessage());
            return redirect()->route('vendor.motor')->with('message', 'Terjadi kesalahan saat memperbarui motor.')->with('type', 'error');
        }
    }

    public function edit($id)
    {
        try {
            $token = session('token') ?? 'TOKEN_KAMU_DI_SINI'; // Ambil token dari session

            // Ambil data motor berdasarkan ID
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token
            ])->get("{$this->apiBaseUrl}/motor/vendor/{$id}");

            if ($response->successful()) {
                $motor = $response->json();
                return view('vendor.edit_motor', compact('motor'));
            }

            return redirect()->route('vendor.motor')->with('message', 'Motor tidak ditemukan.')->with('type', 'error');
        } catch (\Exception $e) {
            Log::error('Gagal mengambil data motor: ' . $e->getMessage());
            return redirect()->route('vendor.motor')->with('message', 'Terjadi kesalahan saat mengambil data motor.')->with('type', 'error');
        }
    }



    // Fungsi untuk menghapus motor
    public function destroy($id)
    {
        try {
            $token = session('token') ?? 'TOKEN_KAMU_DI_SINI'; // Ambil token dari session

            $response = Http::withToken($token)->delete("{$this->apiBaseUrl}/motor/vendor/{$id}");

            // Menangani respons sukses atau gagal
            if ($response->successful()) {
                return redirect()->back()->with('message', 'Motor berhasil dihapus.')->with('type', 'success');
            }

            return redirect()->back()->with('message', 'Gagal menghapus motor.')->with('type', 'error');
        } catch (\Exception $e) {
            Log::error('Gagal menghapus motor: ' . $e->getMessage());
            return redirect()->back()->with('message', 'Terjadi kesalahan server.')->with('type', 'error');
        }
    }
}
