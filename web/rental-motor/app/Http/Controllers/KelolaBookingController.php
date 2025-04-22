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
    public function index($id)
    {
        try {
            $token = session('token');
            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
            }

            // Get bookings from Go backend
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

            // Get vendor motors from Go backend
            $urlMotors = config('api.base_url') . '/motor/vendor';
            Log::info("Mengirim request motor ke: " . $urlMotors);
            $responseMotors = Http::withToken($token)->timeout(10)->get($urlMotors);
            Log::info("Response motor: " . $responseMotors->body());
            if ($responseMotors->successful()) {
                $jsonMotor = $responseMotors->json();
                $motors = isset($jsonMotor['data']) ? $jsonMotor['data'] : $jsonMotor;
            } else {
                Log::error("Gagal mengambil data motor. HTTP Status: " . $responseMotors->status());
                $motors = [];
            }
        } catch (\Exception $e) {
            Log::error('Gagal mengambil data booking atau motor: ' . $e->getMessage());
            $bookings = [];
            $motors = [];
        }
        // === START: manual pagination untuk $bookings ===
        $perPage = 5;
        $currentPage = Paginator::resolveCurrentPage('page');      // ambil ?page=…
        $collection = collect($bookings);                        // bungkus array jadi Collection
        $currentItems = $collection
            ->forPage($currentPage, $perPage)     // slice data
            ->values();                           // reindex

        $paginatedBookings = new LengthAwarePaginator(
            $currentItems,                // data halaman ini
            $collection->count(),         // total item
            $perPage,                     // item per halaman
            $currentPage,                 // halaman sekarang
            [
                'path' => Paginator::resolveCurrentPath(),
                'pageName' => 'page',
            ]
        );
        // === END: manual pagination ===

        // Kirim view sekali, dengan paginator
        return view('vendor.kelola', [
            'bookings' => $paginatedBookings,
            'motors' => $motors,
        ]);

        return view('vendor.kelola', compact('bookings', 'motors'));
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

            // Gabungkan input tanggal dan waktu; tambahkan ":00" untuk detik
            $startDateInput = $validated['start_date_date'] . 'T' . $validated['start_date_time'] . ':00';

            // Buat objek Carbon dari input
            $carbonStartDate = \Carbon\Carbon::createFromFormat('Y-m-d\TH:i:s', $startDateInput, 'Asia/Jakarta');

            // Cek apakah tanggal mulai yang dimasukkan sudah lewat waktu saat ini
            if ($carbonStartDate->lt(\Carbon\Carbon::now('Asia/Jakarta'))) {
                return redirect()->back()->with('error', 'Tanggal dan jam mulai tidak boleh kurang dari waktu saat ini.');
            }

            // Setelah validasi, format objek Carbon menjadi string ISO8601
            $startDate = $carbonStartDate->format('Y-m-d\TH:i:sP');

            // Bangun data multipart untuk dikirim ke API backend
            $multipart = [
                ['name' => 'motor_id', 'contents' => $validated['motor_id']],
                ['name' => 'customer_name', 'contents' => trim($validated['customer_name'])],
                ['name' => 'start_date', 'contents' => $startDate],
                ['name' => 'duration', 'contents' => $validated['duration']],
                ['name' => 'pickup_location', 'contents' => $validated['pickup_location']],
                ['name' => 'type', 'contents' => 'manual'],
                ['name' => 'status', 'contents' => 'confirmed'],
            ];

            // Optional file upload (foto ID dan KTP)
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

            $response = Http::withToken($token)
                ->asMultipart()
                ->post(config('api.base_url') . '/vendor/manual/bookings', $multipart);

            if ($response->successful()) {
                return redirect()->back()
                    ->with('message', 'Booking manual berhasil dibuat');
            } else {
                return redirect()->back()
                    ->with('error', 'Gagal menambahkan booking manual: ' . $response->body());
            }

        } catch (\Exception $e) {
            Log::error("Error saat booking manual (duration): " . $e->getMessage());
            return redirect()->back()->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }
}
