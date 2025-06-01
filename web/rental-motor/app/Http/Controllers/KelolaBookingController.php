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
        // Cek token login
        $token = session()->get('token');
        if (!$token) {
            if ($request->ajax()) {
                return response()->json(['error' => 'Anda harus login terlebih dahulu.'], 401);
            }
            return redirect()->back()->with('error', 'Anda harus login terlebih dahulu.');
        }

        // Validasi input (gunakan aturan validasi yang sudah ditentukan)
        $validated = $request->validate([
            'motor_id' => 'required|integer',
            'customer_name' => 'required|string|min:3',
            'start_date_date' => 'required|date_format:Y-m-d',
            'start_date_time' => 'required|date_format:H:i',
            'duration' => 'required|integer|min:1',
            'booking_purpose' => 'required|string',
            'pickup_location' => 'required|string',
            'dropoff_location' => 'nullable|string',
            'photo_id' => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
            'ktp_id' => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
        ]);

        // Gabungkan tanggal dan waktu menjadi string ISO8601
        $startDateInput = $validated['start_date_date'] . 'T' . $validated['start_date_time'] . ':00';

        // Buat Carbon instance timezone Asia/Jakarta dan validasi agar tidak di masa lalu
        $carbonStartDate = \Carbon\Carbon::createFromFormat('Y-m-d\TH:i:s', $startDateInput, 'Asia/Jakarta');
        if ($carbonStartDate->lt(\Carbon\Carbon::now('Asia/Jakarta'))) {
            $errorMessage = 'Tanggal dan jam mulai tidak boleh kurang dari waktu saat ini.';
            if ($request->ajax()) {
                return response()->json(['error' => $errorMessage], 422);
            }
            return redirect()->back()->with('error', $errorMessage);
        }
        Log::info('Carbon Start Date:', ['start' => $carbonStartDate->toIso8601String()]);



        // Format ISO8601 dengan timezone offset, misal 2025-05-31T14:30:00+07:00
        $startDate = $carbonStartDate->format('Y-m-d\TH:i:sP');

        // Siapkan data multipart untuk request ke API
        $multipart = [
            ['name' => 'motor_id', 'contents' => $validated['motor_id']],
            ['name' => 'customer_name', 'contents' => trim($validated['customer_name'])],
            ['name' => 'start_date', 'contents' => $startDate],
            ['name' => 'duration', 'contents' => $validated['duration']],
            ['name' => 'booking_purpose', 'contents' => $validated['booking_purpose']],
            ['name' => 'pickup_location', 'contents' => $validated['pickup_location']],
            ['name' => 'type', 'contents' => 'manual'],      // Menandai booking manual
            ['name' => 'status', 'contents' => 'confirmed'], // Status langsung confirmed
        ];

        // Tambahkan dropoff_location jika ada
        if (!empty($validated['dropoff_location'])) {
            $multipart[] = ['name' => 'dropoff_location', 'contents' => $validated['dropoff_location']];
        }

        // Tambahkan file photo_id jika ada
        if ($request->hasFile('photo_id')) {
            $photo = $request->file('photo_id');
            $multipart[] = [
                'name' => 'photo_id',
                'contents' => fopen($photo->getPathname(), 'r'),
                'filename' => $photo->getClientOriginalName()
            ];
        }

        // Tambahkan file ktp_id jika ada
        if ($request->hasFile('ktp_id')) {
            $ktp = $request->file('ktp_id');
            $multipart[] = [
                'name' => 'ktp_id',
                'contents' => fopen($ktp->getPathname(), 'r'),
                'filename' => $ktp->getClientOriginalName()
            ];
        }

        // Log data request untuk debugging
        Log::info("Manual Booking Request:", [
            'start_date' => $startDate,
            'duration' => $validated['duration'],
            'motor_id' => $validated['motor_id'],
            'customer_name' => $validated['customer_name']
        ]);

        // Kirim request POST multipart ke API eksternal dengan token otentikasi
        $response = Http::withToken($token)
            ->timeout(30)
            ->asMultipart()
            ->post(config('api.base_url') . '/vendor/manual/bookings', $multipart);

        // Log response API untuk debugging
        Log::info("API Response:", [
            'status' => $response->status(),
            'headers' => $response->headers(),
            'body' => $response->body()
        ]);

        if ($response->successful()) {
            $responseData = $response->json();
            $successMessage = $responseData['message'] ?? 'Booking manual berhasil dibuat';

            if ($request->ajax()) {
                return response()->json([
                    'message' => $successMessage,
                    'data' => $responseData
                ]);
            }
            return redirect()->back()->with('message', $successMessage);
        } else {
            // Jika gagal, ambil pesan error dari response API
            $errorMessage = 'Gagal menambahkan booking manual.';
            $statusCode = $response->status();

            Log::error("API Error Response:", [
                'status' => $statusCode,
                'body' => $response->body(),
                'headers' => $response->headers()
            ]);

            // Parsing response JSON untuk mendapatkan pesan error spesifik
            try {
                $errorData = $response->json();

                if (isset($errorData['error'])) {
                    $errorMessage = $errorData['error'];
                } elseif (isset($errorData['message'])) {
                    $errorMessage = $errorData['message'];
                } elseif (isset($errorData['errors'])) {
                    if (is_array($errorData['errors'])) {
                        $errorMessages = [];
                        foreach ($errorData['errors'] as $field => $messages) {
                            if (is_array($messages)) {
                                $errorMessages[] = implode(', ', $messages);
                            } else {
                                $errorMessages[] = $messages;
                            }
                        }
                        $errorMessage = implode('; ', $errorMessages);
                    }
                }

                if ($request->ajax()) {
                    return response()->json([
                        'error' => $errorMessage,
                        'errors' => $errorData['errors'] ?? null
                    ], $statusCode);
                }
            } catch (\Exception $parseError) {
                $responseBody = $response->body();
                if (!empty($responseBody)) {
                    $errorMessage = $responseBody;
                }

                Log::error("Failed to parse API error response:", [
                    'parse_error' => $parseError->getMessage(),
                    'response_body' => $responseBody
                ]);
            }

            if ($request->ajax()) {
                return response()->json(['error' => $errorMessage], $statusCode);
            }
            return redirect()->back()->with('error', $errorMessage);
        }
    } catch (\Illuminate\Validation\ValidationException $e) {
        Log::error("Validation Error:", ['errors' => $e->errors()]);

        if ($request->ajax()) {
            return response()->json([
                'error' => 'Data yang dimasukkan tidak valid.',
                'errors' => $e->errors()
            ], 422);
        }
        return redirect()->back()->withErrors($e->errors())->withInput();
    } catch (\Exception $e) {
        Log::error("Exception in addManualBooking:", [
            'message' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);

        $errorMessage = 'Terjadi kesalahan sistem: ' . $e->getMessage();

        if ($request->ajax()) {
            return response()->json(['error' => $errorMessage], 500);
        }
        return redirect()->back()->with('error', $errorMessage);
    }
}

}
