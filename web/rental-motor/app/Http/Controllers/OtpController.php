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
    return view('vendor.otp_request', compact('user'));
}

    public function requestResetOtp(Request $request)
    {
        $email = $request->input('email');
        $token = Session::get('token');

        if (!$token) {
            return back()->with('error', 'Token tidak ditemukan.');
        }

        $response = Http::withToken($token)
            ->post(config('api.base_url') . '/request-reset-password-otp', [
                'email' => $email
            ]);

        if ($response->successful()) {
            Session::put('email_for_otp', $email);
            return redirect()->route('vendor.otp.verify.form')
                ->with('success', 'Kode OTP telah dikirim ke email Anda.');
        }

        return back()->with('error', 'Gagal mengirim OTP: ' . $response->json()['message'] ?? '');
    }

    public function showVerifyOtpForm()
    {
        $email = Session::get('email_for_otp');
        
        if (!$email) {
            return redirect()->route('vendor.otp.form')
                ->with('error', 'Silakan masukkan email terlebih dahulu.');
        }

        return view('vendor.otp_verify', compact('email'));
    }

    public function verifyOtp(Request $request)
    {
        $email = $request->input('email');
        $otp = $request->input('otp');

        $response = Http::post(config('api.base_url') . '/verify-otp', [
            'email' => $email,
            'otp' => $otp
        ]);

        if ($response->successful() && $response->json('status') === 'success') {
            Session::put('verified_email', $email);
          return redirect()->route('vendor.password.form');
        }

        return back()->with('error', 'OTP salah atau tidak valid: ' . $response->json()['message'] ?? '');
    }

    public function showResetPasswordForm()
    {
        $email = Session::get('verified_email');
        
        if (!$email) {
            return redirect()->route('vendor.otp.form')
                ->with('error', 'Silakan verifikasi OTP terlebih dahulu.');
        }

        return view('vendor.reset_password', compact('email'));
    }

    public function updatePassword(Request $request)
{
    $token = session()->get('token');
    $userId = session()->get('user_id'); // Pastikan ini sesuai dengan session ID user

    if (!$token) {
        return back()->with('error', 'Token tidak ditemukan.');
    }

    $response = Http::withToken($token)->post(config('api.base_url') . '/reset-password', [
        'old_password' => $request->input('old_password'),
        'new_password' => $request->input('new_password'),
    ]);

    if ($response->successful()) {
        return redirect()->route('vendor.profile', ['id' => $userId])
            ->with('success', 'Password berhasil diperbarui.');
    }

    return back()->with('error', 'Gagal memperbarui password: ' . ($response->json()['message'] ?? ''));
}
    
}
