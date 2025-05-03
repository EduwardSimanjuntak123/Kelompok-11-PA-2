<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class PerpanjanganSewaController extends Controller
{
    protected $apiBaseUrl;

    public function __construct()
    {
        $this->apiBaseUrl = config('api.base_url');
    }

    /**
     * Tampilkan halaman kelola perpanjangan sewa.
     * @param  \Illuminate\Http\Request  $request
     * @param  int|null  $id  (boleh tetap ada, tapi sebenarnya tidak dipakai)
     */
    public function index(Request $request, $id = null)
    {
        $bookings = [];
        $extens = [];

        try {
            $token = session('token', 'TOKEN_KAMU_DI_SINI');

            // Ambil data bookings
            $bookingResponse = Http::withToken($token)
                ->timeout(10)
                ->get("{$this->apiBaseUrl}/vendor/bookings");
            if ($bookingResponse->successful()) {
                $bookings = $bookingResponse->json();
            } else {
                Log::warning("Gagal booking: {$bookingResponse->status()}");
            }

            // Ambil data extensions
            $extensionResponse = Http::withToken($token)
                ->timeout(10)
                ->get("{$this->apiBaseUrl}/vendor/extensions");
            if ($extensionResponse->successful()) {
                $extens = $extensionResponse->json()['extensions'] ?? [];
            } else {
                Log::warning("Gagal extensions: {$extensionResponse->status()}");
            }
        } catch (\Exception $e) {
            Log::error("Error API: " . $e->getMessage());
        }

        return view('vendor.perpanjangansewa', [
            'bookings' => $bookings,
            'extens' => $extens,
            'apiBaseUrl' => $this->apiBaseUrl,
        ]);
    }

    /**
     * Setujui perpanjangan.
     */
    public function approveExtension($extension_id)
    {
        $token = session('token', 'TOKEN_KAMU_DI_SINI');
        try {
            // Menggunakan endpoint dengan ID di path
            $url = "{$this->apiBaseUrl}/vendor/extensions/{$extension_id}/approve";
            $response = Http::withToken($token)
                ->timeout(10)
                ->put($url);
// dd($response);
            Log::info("Approve Extension API", [
                'url' => $url,
                'status' => $response->status(),
                'response' => $response->body(),
            ]);

            if ($response->successful()) {
                return redirect()->back()->with('success', 'Perpanjangan disetujui!');
            }

            Log::warning("Approve failed", ['status' => $response->status()]);
            return redirect()->back()
                ->with('error', "Gagal menyetujui perpanjangan (status {$response->status()})");

        } catch (\Exception $e) {
            Log::error("Exception approveExtension: " . $e->getMessage());
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan saat menyetujui. Silakan cek log.');
        }
    }

    /**
     * Tolak perpanjangan.
     */
    public function rejectExtension($extension_id)
    {
        $token = session('token', 'TOKEN_KAMU_DI_SINI');

        try {
            $url = "{$this->apiBaseUrl}/vendor/extensions/{$extension_id}/reject";
            $response = Http::withToken($token)
                ->timeout(10)
                ->put($url);

            Log::info("Reject Extension API", [
                'url' => $url,
                'status' => $response->status(),
                'response' => $response->body(),
            ]);

            if ($response->successful()) {
                return redirect()->back()->with('success', 'Perpanjangan ditolak!');
            }

            Log::warning("Reject failed", ['status' => $response->status()]);
            return redirect()->back()
                ->with('error', "Gagal menolak perpanjangan (status {$response->status()})");

        } catch (\Exception $e) {
            Log::error("Exception rejectExtension: " . $e->getMessage());
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan saat menolak. Silakan cek log.');
        }
    }
}
