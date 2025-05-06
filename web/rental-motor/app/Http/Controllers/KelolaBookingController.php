<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Pagination\Paginator;

class KelolaBookingController extends Controller
{
    public function index(Request $request, $id)
    {
        try {
            $token = session('token');
            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
            }

            // Ambil semua booking
            $urlBookings = config('api.base_url') . '/vendor/bookings';
            Log::info("Mengirim request booking ke: " . $urlBookings);
            $responseBookings = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token
            ])->timeout(10)->get($urlBookings, [
                        'vendor_id' => $id
                    ]);
            Log::info("Response booking: " . $responseBookings->body());
            $bookings = ($responseBookings->successful() && is_array($responseBookings->json()))
                ? $responseBookings->json()
                : [];

            // Ambil semua motor
            $urlMotors = config('api.base_url') . '/motor/vendor';
            Log::info("Mengirim request motor ke: " . $urlMotors);
            $responseMotors = Http::withToken($token)->timeout(10)->get($urlMotors);
            Log::info("Response motor: " . $responseMotors->body());
            $motors = $responseMotors->successful()
                ? (isset($responseMotors->json()['data']) ? $responseMotors->json()['data'] : $responseMotors->json())
                : [];

        } catch (\Exception $e) {
            Log::error('Gagal mengambil data booking atau motor: ' . $e->getMessage());
            $bookings = [];
            $motors = [];
        }

        // START: FILTER BERDASARKAN STATUS
        $collection = collect($bookings);

        if ($request->has('status') && $request->status != 'all') {
            $status = $request->status;
            $collection = $collection->filter(function ($item) use ($status) {
                return isset($item['status']) && $item['status'] == $status;
            })->values(); // reindex ulang
        }
        // END: FILTER

        // START: URUTKAN status 'menunggu_konfirmasi' di atas, lalu berdasarkan start_date terbaru
        // START: URUTKAN berdasarkan created_at desc (terbaru di atas)
        $collection = $collection->sortByDesc(function ($item) {
            return isset($item['created_at']) ? Carbon::parse($item['created_at']) : Carbon::now();
        })->values();

        // END: URUTKAN

        // START: MANUAL PAGINATION
        $perPage = 5;
        $currentPage = Paginator::resolveCurrentPage('page');
        $currentItems = $collection
            ->forPage($currentPage, $perPage)
            ->values();

        $paginatedBookings = new LengthAwarePaginator(
            $currentItems,
            $collection->count(),
            $perPage,
            $currentPage,
            [
                'path' => Paginator::resolveCurrentPath(),
                'pageName' => 'page',
            ]
        );
        // END: MANUAL PAGINATION

        return view('vendor.kelola', [
            'bookings' => $paginatedBookings,
            'motors' => $motors,
        ]);
    }

    public function confirm($id)
    {
        try {
            $token = session('token');

            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login untuk melakukan aksi ini.');
            }

            $url = config('api.base_url') . '/bookings/{$id}/confirm';

            Log::info("Mengirim request konfirmasi booking ke: {$url}");

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'Accept' => 'application/json',
                'Content-Type' => 'application/json'
            ])->timeout(10)->post($url, []);

            if ($response->successful()) {
                Log::info("Booking ID {$id} berhasil dikonfirmasi.");
                return redirect()->back()->with('success', 'Booking berhasil disetujui.');
            } else {
                Log::error("Gagal mengkonfirmasi booking ID {$id}. Status: " . $response->status() . " | Response: " . $response->body());
                return redirect()->back()->with('error', 'Gagal menyetujui pemesanan. Silakan coba lagi.');
            }
        } catch (\Exception $e) {
            Log::error("Terjadi kesalahan saat mengkonfirmasi booking ID {$id}: " . $e->getMessage());
            return redirect()->back()->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }

    public function rejectBooking($id)
    {
        try {
            $token = session('token');

            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login untuk melakukan aksi ini.');
            }

            $url = config('api.base_url') . 'bookings/{$id}/reject';

            Log::info("Mengirim request penolakan booking ke: {$url}");

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'Accept' => 'application/json',
                'Content-Type' => 'application/json'
            ])->timeout(10)->post($url, []);

            if ($response->successful()) {
                Log::info("Booking ID {$id} berhasil ditolak.");
                return redirect()->back()->with('success', 'Booking berhasil ditolak.');
            } else {
                Log::error("Gagal menolak booking ID {$id}. Status: " . $response->status() . " | Response: " . $response->body());
                return redirect()->back()->with('error', 'Gagal menolak pemesanan. Silakan coba lagi.');
            }
        } catch (\Exception $e) {
            Log::error("Terjadi kesalahan saat menolak booking ID {$id}: " . $e->getMessage());
            return redirect()->back()->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }

    public function complete($id)
    {
        try {
            $token = session('token');

            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login untuk melakukan aksi ini.');
            }

            $url = config('api.base_url') . 'bookings/{$id}/complete';
            dd($url);
            Log::info("Mengirim request penyelesaian booking ke: {$url}");

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'Accept' => 'application/json',
                'Content-Type' => 'application/json'
            ])->timeout(10)->post($url, []);

            if ($response->successful()) {
                Log::info("Booking ID {$id} berhasil diselesaikan.");
                return redirect()->back()->with('success', 'Booking berhasil diselesaikan.');
            } else {
                Log::error("Gagal menyelesaikan booking ID {$id}. Status: " . $response->status() . " | Response: " . $response->body());
                return redirect()->back()->with('error', 'Gagal menyelesaikan pemesanan. Silakan coba lagi.');
            }
        } catch (\Exception $e) {
            Log::error("Terjadi kesalahan saat menyelesaikan booking ID {$id}: " . $e->getMessage());
            return redirect()->back()->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }


    public function addManualBooking(Request $request)
{
    
    try {
        $token = session()->get('token');
        if (!$token) {
            return redirect()->back()->with('error', 'Anda harus login terlebih dahulu.');
        }

        // Validasi input (tanpa end_date, pakai duration)
        $validated = $request->validate([
            'motor_id' => 'required|integer',
            'customer_name' => 'required|string',
            'start_date_date' => 'required|date_format:Y-m-d',
            'start_date_time' => 'required|date_format:H:i',
            'duration' => 'required|integer|min:1',
            'pickup_location' => 'required|string',
            'photo_id' => 'nullable|file|mimes:jpg,jpeg,png',
            'ktp_id' => 'nullable|file|mimes:jpg,jpeg,png',
        ]);

        // Gabungkan input tanggal dan waktu
        $startDateInput = $validated['start_date_date'] . 'T' . $validated['start_date_time'] . ':00';

        // Buat Carbon date dan validasi tidak di masa lalu
        $carbonStartDate = \Carbon\Carbon::createFromFormat('Y-m-d\TH:i:s', $startDateInput, 'Asia/Jakarta');
        if ($carbonStartDate->lt(\Carbon\Carbon::now('Asia/Jakarta'))) {
            return redirect()->back()->with('error', 'Tanggal dan jam mulai tidak boleh kurang dari waktu saat ini.');
        }

        // Format ISO8601
        $startDate = $carbonStartDate->format('Y-m-d\TH:i:sP');

        // Multipart data
        $multipart = [
            ['name' => 'motor_id', 'contents' => $validated['motor_id']],
            ['name' => 'customer_name', 'contents' => trim($validated['customer_name'])],
            ['name' => 'start_date', 'contents' => $startDate],
            ['name' => 'duration', 'contents' => $validated['duration']],
            ['name' => 'pickup_location', 'contents' => $validated['pickup_location']],
            ['name' => 'type', 'contents' => 'manual'],
            ['name' => 'status', 'contents' => 'confirmed'],
        ];

        // File upload opsional
        if ($request->hasFile('photo_id')) {
            $photo = $request->file('photo_id');
            $multipart[] = [
                'name' => 'photo_id',
                'contents' => fopen($photo->getPathname(), 'r'),
                'filename' => $photo->getClientOriginalName()
            ];
        }
        if ($request->hasFile('ktp_id')) {
            $ktp = $request->file('ktp_id');
            $multipart[] = [
                'name' => 'ktp_id',
                'contents' => fopen($ktp->getPathname(), 'r'),
                'filename' => $ktp->getClientOriginalName()
            ];
        }

        Log::info("Manual Booking (pakai duration):", [
            'start_date' => $startDate,
            'duration' => $validated['duration'],
            'validated' => $validated
        ]);

        // Kirim request
        $response = Http::withToken($token)
            ->asMultipart()
            ->post(config('api.base_url') . '/vendor/manual/bookings', $multipart);

            if ($response->successful()) {
                return redirect()->back()->with('message', 'Booking manual berhasil dibuat');
            } else {
                // Debugging tambahan untuk response API
                Log::error("Error API Response:", [
                    'status' => $response->status(),
                    'body' => $response->body(),
                    'json' => $response->json(),
                ]);
            
                // Ambil pesan error yang bersih jika tersedia
                $errorMessage = 'Gagal menambahkan booking manual.';
            
                if ($response->header('Content-Type') === 'application/json') {
                    $json = $response->json();
                    if (isset($json['error'])) {
                        $errorMessage = $json['error']; // Pesan error yang lebih spesifik dari API
                    }
                }
            
                return redirect()->back()->with('error', $errorMessage); // Mengirim pesan error ke session
            }
            

    } catch (\Exception $e) {
        Log::error("Error saat booking manual (duration): " . $e->getMessage());
        return redirect()->back()->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
    }
}


}
