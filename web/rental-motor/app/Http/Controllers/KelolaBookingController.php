<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class KelolaBookingController extends Controller
{
    private $apiBaseUrl = 'http://localhost:8080'; // Sesuaikan dengan backend
    public function index($id)
    {
        try {
            $token = session('token');
            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
            }

            // Get bookings from Go backend
            $urlBookings = "{$this->apiBaseUrl}/vendor/bookings";
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
            $urlMotors = "{$this->apiBaseUrl}/motor/vendor";
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

        return view('vendor.kelola', compact('bookings', 'motors'));
    }

    public function confirm($id)
    {
        try {
            $token = session('token');

            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login untuk melakukan aksi ini.');
            }

            $url = "{$this->apiBaseUrl}/bookings/{$id}/confirm";

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

            $url = "{$this->apiBaseUrl}/bookings/{$id}/reject";

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

            $url = "{$this->apiBaseUrl}/bookings/{$id}/complete";
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
        // Ambil token dari session
        $token = session()->get('token');
        if (!$token) {
            return redirect()->back()->with('error', 'Anda harus login terlebih dahulu.');
        }

        // Validasi input form-data dengan format tanggal tanpa detik
        $validated = $request->validate([
            'motor_id'        => 'required|integer',
            'customer_name'   => 'required|string',
            'start_date'      => 'required|date_format:Y-m-d\TH:i',  // Contoh: "2025-04-01T00:00"
            'end_date'        => 'required|date_format:Y-m-d\TH:i',  // Contoh: "2025-04-05T00:00"
            'pickup_location' => 'required|string',
            'photo_id'        => 'nullable|file|mimes:jpg,jpeg,png',
            'ktp_id'          => 'nullable|file|mimes:jpg,jpeg,png',
        ]);

        // Karena input tidak mengandung detik, kita tambahkan ":00" untuk parsing.
        $startDateInput = $validated['start_date'] . ':00';
        $endDateInput   = $validated['end_date'] . ':00';

        // Konversi start_date dan end_date ke format ISO8601 dengan timezone Asia/Jakarta
        $startDate = \Carbon\Carbon::createFromFormat('Y-m-d\TH:i:s', $startDateInput, 'Asia/Jakarta')
            ->format('Y-m-d\TH:i:sP'); // Hasil misal: "2025-04-01T00:00:00+07:00"
        $endDate = \Carbon\Carbon::createFromFormat('Y-m-d\TH:i:s', $endDateInput, 'Asia/Jakarta')
            ->format('Y-m-d\TH:i:sP');

        // Persiapkan data multipart
        $multipart = [];
        // Tambahkan field teks (dengan override tanggal menggunakan nilai yang telah dikonversi)
        $multipart[] = [
            'name'     => 'motor_id',
            'contents' => $validated['motor_id']
        ];
        $multipart[] = [
            'name'     => 'customer_name',
            'contents' => trim($validated['customer_name'])
        ];
        $multipart[] = [
            'name'     => 'start_date',
            'contents' => $startDate
        ];
        $multipart[] = [
            'name'     => 'end_date',
            'contents' => $endDate
        ];
        $multipart[] = [
            'name'     => 'pickup_location',
            'contents' => $validated['pickup_location']
        ];

        // Set type dan status secara manual (untuk booking manual)
        $multipart[] = [
            'name'     => 'type',
            'contents' => 'manual'
        ];
        $multipart[] = [
            'name'     => 'status',
            'contents' => 'confirmed'
        ];

        // Tangani file upload jika ada (optional)
        if ($request->hasFile('photo_id')) {
            $photo = $request->file('photo_id');
            $multipart[] = [
                'name'     => 'photo_id',
                'contents' => fopen($photo->getPathname(), 'r'),
                'filename' => $photo->getClientOriginalName()
            ];
        }
        if ($request->hasFile('ktp_id')) {
            $ktp = $request->file('ktp_id');
            $multipart[] = [
                'name'     => 'ktp_id',
                'contents' => fopen($ktp->getPathname(), 'r'),
                'filename' => $ktp->getClientOriginalName()
            ];
        }

        // Log data untuk debugging
        Log::info("Request Data (manual booking): " . json_encode($validated));
        Log::info("Converted start_date: " . $startDate . " | end_date: " . $endDate);

        // Kirim POST request ke backend Go untuk booking manual
        $url = $this->apiBaseUrl . '/vendor/manual/bookings';
        Log::info("Mengirim request ke: " . $url);

        $response = Http::withToken($token)
            ->asMultipart()
            ->post($url, $multipart);

        Log::info("Response dari addManualBooking: " . $response->body());

        if ($response->successful()) {
            return redirect()->route('vendor.kelola')
                ->with('message', 'Booking manual berhasil dibuat');
        } else {
            return redirect()->back()->with('error', 'Gagal menambahkan booking manual: ' . $response->body());
        }
    } catch (\Exception $e) {
    Log::error("Terjadi kesalahan saat menambahkan booking manual: " . $e->getMessage());
        return redirect()->back()->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
    }
}

    
    
}
