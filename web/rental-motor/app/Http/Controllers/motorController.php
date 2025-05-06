<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MotorController extends Controller
{
    protected $apiBaseUrl;

    public function __construct()
    {
        $this->apiBaseUrl = config('api.base_url');
    }

    public function index()
    {
        try {
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
            $response = Http::withToken($token)
                ->timeout(10)
                ->get("{$this->apiBaseUrl}/motor/vendor");

            $motors = [];

            if ($response->successful()) {
                $motors = $response->json()['data'] ?? [];

                foreach ($motors as &$motor) {
                    $motor['image_url'] = !empty($motor['image']) && !str_starts_with($motor['image'], 'http')
                        ? $this->apiBaseUrl . ltrim($motor['image'])
                        : $motor['image'];
                }

                // Filter berdasarkan status jika ada
                $statusFilter = request('status');
                if ($statusFilter && $statusFilter !== 'all') {
                    $motors = array_filter($motors, fn($motor) => $motor['status'] === $statusFilter);
                }
            } else {
                Log::error("Gagal mengambil data motor. Status: " . $response->status());
            }
        } catch (\Exception $e) {
            Log::error('Kesalahan saat mengambil data motor: ' . $e->getMessage());
        }

        return view('vendor.motor', compact('motors'));
    }

    public function store(Request $request)
    {
        try {
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');

            // Validasi input
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'brand' => 'required|string|max:255',
                'year' => 'required|integer|min:1900|max:' . date('Y'),
                'color' => 'required|string|max:255',
                'type' => 'required|in:matic,manual,kopling,vespa',
                'description' => 'required|string',
                'platmotor' => 'required|string',
                'price' => 'required|numeric|min:1000',
                'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            ]);

            // Semua field kecuali file image sudah ada di $validated
            $multipart = [];
            foreach ($validated as $key => $value) {
                $multipart[] = ['name' => $key, 'contents' => $value];
            }

            // Jika ada file image, tambahkan
            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $multipart[] = [
                    'name' => 'image',
                    'contents' => fopen($image->getPathname(), 'r'),
                    'filename' => $image->getClientOriginalName(),
                ];
            }

            $response = Http::withToken($token)
                ->asMultipart()
                ->post("{$this->apiBaseUrl}/motor/vendor", $multipart);

            session()->flash('message', $response->successful() ? 'Motor berhasil ditambahkan!' : 'Gagal menambahkan motor.');
            session()->flash('type', $response->successful() ? 'success' : 'error');

            // Redirect kembali dengan status filter yang aktif
            return redirect()->route('vendor.motor', ['status' => request('status')]);
        } catch (\Exception $e) {
            Log::error('Gagal menyimpan motor: ' . $e->getMessage());
            session()->flash('message', 'Terjadi kesalahan server.');
            session()->flash('type', 'error');
            return redirect()->route('vendor.motor', ['status' => request('status')]);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');

            // Validasi input
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'brand' => 'required|string|max:255',
                'year' => 'required|integer|min:1900|max:' . date('Y'),
                'color' => 'required|string|max:255',
                'type' => 'required|in:matic,manual,kopling,vespa',
                'description' => 'required|string',
                'platmotor' => 'required|string',
                'price' => 'required|numeric|min:1000',
                'status' => 'required|in:available,booked,unavailable',
                'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            ]);

            $multipart = [];
            // Tambahkan semua kecuali file image
            foreach ($validated as $key => $value) {
                if ($key !== 'image') {
                    $multipart[] = ['name' => $key, 'contents' => $value];
                }
            }

            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $multipart[] = [
                    'name' => 'image',
                    'contents' => fopen($image->getPathname(), 'r'),
                    'filename' => $image->getClientOriginalName(),
                ];
            }

            $response = Http::withToken($token)
                ->asMultipart()
                ->put("{$this->apiBaseUrl}/motor/vendor/{$id}", $multipart);

            session()->flash('message', $response->successful() ? 'Motor berhasil diperbarui!' : 'Gagal memperbarui motor.');
            session()->flash('type', $response->successful() ? 'success' : 'error');

            // Redirect kembali dengan status filter yang aktif
            return redirect()->route('vendor.motor', ['status' => request('status')]);
        } catch (\Exception $e) {
            Log::error('Gagal update motor: ' . $e->getMessage());
            session()->flash('message', 'Terjadi kesalahan saat memperbarui motor.');
            session()->flash('type', 'error');
            return redirect()->route('vendor.motor', ['status' => request('status')]);
        }
    }

    public function destroy($id)
    {
        try {
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
            $response = Http::withToken($token)
                ->delete("{$this->apiBaseUrl}/motor/vendor/{$id}");

            if ($response->successful()) {
                session()->flash('message', 'Motor berhasil dihapus.');
                session()->flash('type', 'success');
            } else {
                $error = $response->json('error') ?? 'Gagal menghapus motor.';
                session()->flash('message', $error);
                session()->flash('type', 'error');
            }

            // Redirect kembali dengan status filter yang aktif
            return redirect()->route('vendor.motor', ['status' => request('status')]);
        } catch (\Exception $e) {
            Log::error('Kesalahan saat menghapus motor: ' . $e->getMessage());
            session()->flash('message', 'Terjadi kesalahan saat menghapus motor.');
            session()->flash('type', 'error');
            return redirect()->route('vendor.motor', ['status' => request('status')]);
        }
    }
}
