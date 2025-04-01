<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Log;

class AdminController extends Controller
{
    protected $apiBaseUrl = 'http://localhost:8080';

    public function profile()
    {
        // Ambil token autentikasi dari sesi
        $token = Session::get('token');

        // Pastikan token ada
        if (!$token) {
            return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
        }

        // Panggil API untuk mendapatkan data profil admin
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->get($this->apiBaseUrl . '/admin/profile');

        // Periksa apakah respons berhasil
        if ($response->failed()) {
            return redirect()->route('admin')->with('error', 'Gagal mengambil data profil admin.');
        }

        $adminData = $response->json();

        // Kirim data ke view
        return view('admin.profile', compact('adminData'));
    }
    

    public function updateProfile(Request $request)
{
    try {
        // Ambil token dari session
        $token = session()->get('token');
        if (!$token) {
            return redirect()->route('login')->with('message', 'Anda harus login terlebih dahulu.')->with('type', 'error');
        }
        $multipart = [];
        // Ambil data input jika tersedia
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
        if ($status = $request->input('status')) {
            $multipart[] = ['name' => 'status', 'contents' => $status];
        }
        if ($role = $request->input('role')) {
            $multipart[] = ['name' => 'role', 'contents' => $role];
        }

        // Tangani upload foto profil
        if ($request->hasFile('profile_image')) {
            $image = $request->file('profile_image');
            $multipart[] = [
                'name' => 'profile_image',
                'contents' => fopen($image->getPathname(), 'r'),
                'filename' => $image->getClientOriginalName()
            ];
        }

        // Kirim PUT request ke API Golang
        $response = Http::withToken($token)
            ->asMultipart()
            ->put("{$this->apiBaseUrl}/admin/profile/edit", $multipart);

        // Jika berhasil
        if ($response->successful()) {
            return redirect()->back()->with('message', 'Profil berhasil diperbarui')->with('type', 'success');
        }

        // Jika gagal tapi bukan exception
        Log::error("Gagal memperbarui profil. Status: " . $response->status());
        return redirect()->back()->with('message', 'Gagal memperbarui profil')->with('type', 'error');
    } catch (\Exception $e) {
        Log::error("Terjadi kesalahan saat memperbarui profil: " . $e->getMessage());
        return redirect()->back()->with('message', 'Terjadi kesalahan server')->with('type', 'error');
    }
}
}
