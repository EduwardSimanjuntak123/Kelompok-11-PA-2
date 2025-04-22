<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class VendorController extends Controller
{
    protected $apiBaseUrl;

    public function __construct()
    {
        $this->apiBaseUrl = config('api.base_url');
    }

    // Menampilkan profil vendor
    public function profile()
    {
        $token = Session::get('token');
        Log::info('Token saat dashboard:', ['token' => $token]);
        if (!$token) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }

        // Panggil API untuk mendapatkan data profil vendor
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->get($this->apiBaseUrl . '/vendor/profile');

        if ($response->failed()) {
            return redirect()->route('vendor.dashboard')->with('error', 'Gagal mengambil data profil vendor.');
        }

        // Ambil data user dari respons API
        $data = $response->json();
        // Asumsikan struktur respons mengandung key "user"
        $user = $data['user'] ?? null;
        if (!$user) {
            return redirect()->route('vendor.dashboard')->with('error', 'Data profil vendor tidak lengkap.');
        }

        return view('vendor.profile', compact('user'));
    }

    public function dashboard($id = null)
    {
        if (!$id) {
            $id = session('user_id');
        }
    
        if (!$id) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }
    
        $token = session()->get('token');
        $motorData = [];
        $ratingData = [];
        $bookingData = [];
        $transactions = [];
        $pendapatanBulanan = [];
        $pesananBulanan = [];
    
        if ($token) {
            try {
                // Ambil daftar motor vendor
                $motorResponse = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $token
                ])->get(config('api.base_url') . '/motor/vendor/');
                Log::info('Token saat dashboard:', ['token' => $token]);
                if ($motorResponse->successful()) {
                    $motorData = $motorResponse->json();
                }
                
    
                // Ambil profil vendor (rating)
                $ratingResponse = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $token
                ])->get(config('api.base_url') .'/vendor/profile');
    // Tambahkan debug ini
Log::info('Rating Response Status: ' . $ratingResponse->status());
Log::info('Rating Response Body: ' . $ratingResponse->body());
                if ($ratingResponse->successful()) {
                    $ratingData = $ratingResponse->json();
                }
    
                // Ambil daftar booking
                $bookingResponse = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $token
                ])->get(config('api.base_url') .'/vendor/bookings');
    
                if ($bookingResponse->successful()) {
                    $bookingData = $bookingResponse->json();
                }
    
                // Ambil data transaksi
                $transactionResponse = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $token
                ])->get(config('api.base_url') .'/transaction/');
    
                if ($transactionResponse->successful()) {
                    $transactions = $transactionResponse->json();
                }
            } catch (\Exception $e) {
                Log::error('Gagal mengambil data vendor: ' . $e->getMessage());
            }
        }
    
        return view('vendor.dashboard', compact(
            'motorData', 'ratingData', 'bookingData', 'id',
            'transactions', 'pendapatanBulanan', 'pesananBulanan'
        ));
    }

    
    


    // Mengupdate profil vendor dengan data form-data
    public function updateProfile(Request $request)
{
    try {
        $token = Session::get('token', 'TOKEN_KAMU_DI_SINI');
        $multipart = [];

        // Data User
        if ($name = $request->input('name')) {
            $multipart[] = ['name' => 'name', 'contents' => $name];
        }
        if ($email = $request->input('email')) {
            $multipart[] = ['name' => 'email', 'contents' => $email];
        }
        if ($phone = $request->input('phone')) {
            $multipart[] = ['name' => 'phone', 'contents' => $phone];
        }
        if ($address = $request->input('address')) {
            $multipart[] = ['name' => 'address', 'contents' => $address];
        }
        if ($password = $request->input('password')) {
            $multipart[] = ['name' => 'password', 'contents' => $password];
        }

        // Data Vendor
        if ($shopName = $request->input('shop_name')) {
            $multipart[] = ['name' => 'shop_name', 'contents' => $shopName];
        }
        if ($shopAddress = $request->input('shop_address')) {
            $multipart[] = ['name' => 'shop_address', 'contents' => $shopAddress];
        }
        if ($shopDescription = $request->input('shop_description')) {
            $multipart[] = ['name' => 'shop_description', 'contents' => $shopDescription];
        }
        if ($idKecamatan = $request->input('nama_kecamatan')) {
            $multipart[] = ['name' => 'nama_kecamatan', 'contents' => $idKecamatan];
        }

        // Upload file profile_image
        if ($request->hasFile('profile_image')) {
            $image = $request->file('profile_image');
            $multipart[] = [
                'name' => 'profile_image',
                'contents' => fopen($image->getPathname(), 'r'),
                'filename' => $image->getClientOriginalName()
            ];
        }

        

        // Update waktu
        $multipart[] = ['name' => 'updated_at', 'contents' => now()->toDateTimeString()];

        // Kirim request ke API backend
        $response = Http::withToken($token)
            ->asMultipart()
            ->put($this->apiBaseUrl . '/vendor/profile/edit', $multipart);

            if ($response->successful()) {
                $redirect = redirect()->back();
            
                if ($request->hasFile('profile_image')) {
                    $redirect = $redirect->with('message_photo', 'Foto profil berhasil diubah')
                                         ->with('type_photo', 'success');
                }
            
                $hasProfileData = collect($multipart)->filter(function ($item) {
                    return !in_array($item['name'], ['profile_image', 'updated_at']);
                })->isNotEmpty();
            
                if ($hasProfileData) {
                    $redirect = $redirect->with('message_profile', 'Profil vendor berhasil diperbarui')
                                         ->with('type_profile', 'success');
                }
            
                return $redirect;
            }
            

        Log::error("Gagal memperbarui profil vendor. Status: " . $response->status());
        return redirect()->back()->with('message', 'Gagal memperbarui profil vendor')->with('type', 'error');

    } catch (\Exception $e) {
        Log::error("Terjadi kesalahan saat memperbarui profil vendor: " . $e->getMessage());
        return redirect()->back()->with('message', 'Terjadi kesalahan server')->with('type', 'error');
    }
}

}
