<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TitikLokasiController extends Controller
{
    protected $apiBaseUrl;

    public function __construct()
    {
        $this->apiBaseUrl = config('api.base_url');
    }

    public function index()
    {
        $kecamatans = [];
        $titiklokasis = [];

        try {
            $token = session('token', 'TOKEN_KAMU_DI_SINI');

            $respKecamatan = Http::withToken($token)
                ->timeout(10)
                ->get("{$this->apiBaseUrl}/kecamatan");

            if ($respKecamatan->successful()) {
                $kecamatans = $respKecamatan->json();
            } else {
                Log::warning("Gagal mengambil kecamatan. Status: {$respKecamatan->status()}");
            }

            $respLokasi = Http::withToken($token)
                ->timeout(10)
                ->get("{$this->apiBaseUrl}/location-recommendations");

            if ($respLokasi->successful()) {
                $titiklokasis = $respLokasi->json();
            } else {
                Log::warning("Gagal mengambil rekomendasi lokasi. Status: {$respLokasi->status()}");
            }

        } catch (\Exception $e) {
            Log::error("Kesalahan saat mengambil data: " . $e->getMessage());
        }

        return view('admin.titiklokasi', compact('kecamatans', 'titiklokasis'));
    }

    public function store(Request $request)
    {
        Log::debug('STORE HIT dengan request:', $request->all());
    
        $data = $request->validate([
            'place'       => 'required|string|max:255',
            'address'     => 'required|string|max:500',
            'district_id' => 'required|integer',
        ]);
    
        try {
            $token = session('token', 'TOKEN_KAMU_DI_SINI');
            $resp = Http::withToken($token)
                ->timeout(10)
                ->post("{$this->apiBaseUrl}/admin/location-recommendations", [
                    'district_id' => (int) $data['district_id'],
                    'place'       => $data['place'],
                    'address'     => $data['address'],
                ]);
    
            if ($resp->successful()) {
                $new = $resp->json(); // asumsi API kembalikan object baru
                Log::info("Berhasil menambahkan rekomendasi lokasi.", $new);
    
                return response()->json([
                    'success'     => true,
                    'newLocation' => $new,
                ], 200);
            }
    
            Log::warning("Gagal menambah rekomendasi lokasi. Status {$resp->status()}", ['body'=>$resp->body()]);
            return response()->json([
                'success' => false,
                'message' => 'API error: ' . $resp->status(),
            ], $resp->status());
    
        } catch (\Exception $e) {
            Log::error("Exception saat menambah rekomendasi lokasi: " . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Exception: ' . $e->getMessage(),
            ], 500);
        }
    }
    
    
    public function update(Request $request, $id)
    {
        // Validasi input
        $data = $request->validate([
            'place'   => 'required|string|max:255',
            'address' => 'required|string|max:500',
        ]);

        $token = session('token', 'TOKEN_KAMU_DI_SINI');
        $url   = "{$this->apiBaseUrl}/admin/location-recommendations/{$id}";

        try {
            $resp = Http::withToken($token)
                ->timeout(10)
                ->put($url, $data);

            Log::info(">> UPDATE REQUEST to API", [
                'url'  => $url,
                'data' => $data,
            ]);
            Log::info("<< RESPONSE from API", [
                'status'   => $resp->status(),
                'body'     => $resp->body(),
                'response' => $resp->json(),
            ]);

            if ($resp->successful()) {
                Log::info("Berhasil mengedit rekomendasi lokasi ID {$id}.");

                // Jika permintaan AJAX / fetch dengan JSON
                if ($request->wantsJson()) {
                    return response()->json(['success' => true], 200);
                }

                // Kalau non-AJAX, redirect biasa
                return redirect()
                    ->route('admin.titiklokasi')
                    ->with('success', 'Rekomendasi berhasil diubah.');
            } else {
                Log::warning("Gagal mengedit rekomendasi lokasi ID {$id}.", [
                    'status'   => $resp->status(),
                    'response' => $resp->body(),
                ]);

                if ($request->wantsJson()) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Gagal mengedit rekomendasi.',
                        'error'   => $resp->body(),
                    ], $resp->status());
                }
            }

        } catch (\Exception $e) {
            Log::error("Exception saat edit rekomendasi lokasi ID {$id}.", [
                'error_message' => $e->getMessage(),
                'trace'         => $e->getTraceAsString(),
                'data_dikirim'  => $data,
            ]);

            if ($request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Exception saat mengedit rekomendasi.',
                    'error'   => $e->getMessage(),
                ], 500);
            }
        }

        // Fallback kalau bukan AJAX
        return redirect()
            ->route('admin.titiklokasi')
            ->with('error', 'Terjadi kesalahan saat mengedit rekomendasi.');
    }

    public function destroy(Request $request, $id)
    {
        $token = session('token', 'TOKEN_KAMU_DI_SINI');
        $url   = "{$this->apiBaseUrl}/admin/location-recommendations/{$id}";
    
        try {
            $resp = Http::withToken($token)
                ->timeout(10)
                ->delete($url);
    
            if ($resp->successful()) {
                // Untuk AJAX/fetch
                if ($request->wantsJson()) {
                    return response()->json(['success' => true], 200);
                }
                // Untuk non-AJAX
                return redirect()
                    ->route('admin.titiklokasi')
                    ->with('success', 'Rekomendasi berhasil dihapus.');
            } else {
                $body = $resp->body();
                if ($request->wantsJson()) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Gagal menghapus rekomendasi.',
                        'error'   => $body
                    ], $resp->status());
                }
            }
        } catch (\Exception $e) {
            if ($request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Exception saat menghapus rekomendasi.',
                    'error'   => $e->getMessage()
                ], 500);
            }
        }
    
        return redirect()
            ->route('admin.titiklokasi')
            ->with('error', 'Terjadi kesalahan saat menghapus rekomendasi.');
    }
    
}
