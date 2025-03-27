<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class KelolaBookingController extends Controller
{
    private $apiBaseUrl = 'http://localhost:8080'; // Sesuaikan dengan backend

    public function index($id)
    {
        // dd($id);
        try {
            $token = session('token');

            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token
            ])->timeout(10)->get("{$this->apiBaseUrl}/vendor/bookings", [
                'vendor_id' => $id
            ]);

            if ($response->successful() && is_array($response->json())) {
                $bookings = $response->json();
            } else {
                Log::error("Gagal mengambil data pemesanan. HTTP Status: " . $response->status() . " | Response: " . $response->body());
                $bookings = [];
            }
        } catch (\Exception $e) {
            Log::error('Gagal mengambil data pemesanan: ' . $e->getMessage());
            $bookings = [];
        }

        return view('vendor.kelola', compact('bookings'));
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
}
