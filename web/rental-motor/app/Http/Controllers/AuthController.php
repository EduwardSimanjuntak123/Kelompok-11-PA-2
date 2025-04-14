<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\AuthService;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Exception;

class AuthController extends Controller
{
    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    public function login(Request $request)
{
    Log::info('Request login masuk:', $request->except('password'));

    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
        'password' => 'required|min:6',
    ]);

    if ($validator->fails()) {
        return redirect()->route('login')
            ->withErrors($validator)
            ->withInput();
    }

    try {
        $response = $this->authService->login($request->email, $request->password);
    } catch (Exception $e) {
        Log::error("Kesalahan koneksi ke backend: " . $e->getMessage());
        return redirect()->route('login')->with('alert', 'Tidak bisa terhubung ke server, silakan coba lagi.');
    }

    // Periksa apakah respons mengindikasikan kesalahan login
    if (isset($response['error'])) {
        return redirect()->route('login')->with('error', 'Incorrect username or password.');
    }

    // Pastikan respons memiliki struktur yang benar
    if (!isset($response['token']) || !isset($response['user'])) {
        return redirect()->route('login')->with('alert', 'Login gagal. Backend tidak mengembalikan data yang diharapkan.');
    }

    // Simpan session
    session()->put('token', $response['token']);
    session()->put('role', $response['user']['role'] ?? 'guest');
    session()->put('user_id', $response['user']['id'] ?? null);
    session()->put('user', $response['user']);
    session()->save();

    Log::info("Session setelah login:", session()->all());

    // Redirect sesuai role
    return redirect()->route($this->redirectByRole($response['user']['role'] ?? 'guest'));
}


    public function logout()
    {
        if (!session()->has('token')) {
            return redirect()->route('login')->with('alert', 'Anda belum login.');
        }

        Log::info("User logout, menghapus session:", session()->all());

        // Hapus semua session
        Session::flush();

        return redirect()->route('login')->with('message', 'Berhasil logout!')
            ->withCookie(cookie()->forget('token'))
            ->withCookie(cookie()->forget('role'));
    }

    private function redirectByRole($role)
    {
        return match ($role) {
            'admin' => 'admin.dashboard',
            'vendor' => 'vendor.dashboard', // Perbaikan di sini
            default => 'login',
        };
    }
}
