<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Session;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class OtpController extends Controller
{
public function showOtpForm()
{
    $token = Session::get('token');
    
    if (!$token) {
        return redirect()->route('login')->with('error', 'Silakan login terlebih dahulu.');
    }

    // Ambil data user dari API
    $response = Http::withToken($token)
        ->get(config('api.base_url') . '/vendor/profile');

    if ($response->successful()) {
        $data = $response->json();
        $user = $data['user'] ?? [];
    } else {
        $user = [];
    }

    // Kirim data user ke view otpvertification.blade.php
    return view('otpvertification', compact('user'));
}

    public function requestResetOtp(Request $request)
    {
        $email = $request->input('email');
        $token = session()->get('token', 'TOKEN_KAMU_DI_SINI'); // Ambil token dari session atau bisa dari header
// dd($token);
        if (!$token) {
            return back()->with('error', 'Token tidak ditemukan.');
        }

        $response = Http::withToken($token)
            ->post('http://localhost:8080/request-reset-password-otp', [
                'email' => $email
            ]);

        if ($response->status() === 200) {
            session(['otp_start_time' => now()]);
            return back()->with('success', 'Kode OTP telah dikirim ke email Anda.')->with('show_otp_form', true);

        }

        return back()->with('error', 'Gagal mengirim OTP.')->withInput();
    }

    public function verifyOtp(Request $request)
    {
        $email = $request->input('email');
        $otp = $request->input('otp');

        $otpStartTime = session('otp_start_time');
        if (!$otpStartTime || now()->diffInMinutes($otpStartTime) > 10) {
            return back()->with('error', 'OTP kadaluarsa, silakan minta ulang.');
        }

        $response = Http::post('http://localhost:8080/verify-otp', [
            'email' => $email,
            'otp' => $otp
        ]);

        if ($response->successful() && $response->json('status') === 'success') {
    return back()
        ->with('success', 'OTP berhasil diverifikasi.')
        ->with('show_reset_form', true); // ✅ TAMBAHKAN INI
}

        return back()->with('error', 'OTP salah atau tidak valid.')->withInput();
    }

    public function updatePassword(Request $request)
    {
        $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
        if (!$token) {
            return back()->with('error', 'Token tidak ditemukan.');
        }

        $response = Http::withToken($token)->post('http://localhost:8080/reset-password', [
            'old_password' => $request->input('old_password'),
            'new_password' => $request->input('new_password'),
        ]);

        if ($response->status() === 200) {
            return back()->with('success', 'Password berhasil diperbarui.');
        }

        return back()->with('error', 'Gagal memperbarui password.');
    }
}
