<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RedirectIfAuthenticated
{
    public function handle(Request $request, Closure $next)
    {
        if (Auth::check()) {
            $role = Auth::user()->role;
            print_r($role);

            // Redirect berdasarkan role
            if ($role === 'admin') {
                return redirect()->route('admin'); // Pastikan route ini ada
            } elseif ($role === 'vendor') {
                return redirect()->route('vendor'); // Pastikan route ini ada
            } elseif ($role === 'customer') {
                // Jika customer login, arahkan kembali ke login dengan error
                Auth::logout();
                return redirect()->route('login')->withErrors(['error' => 'Pelanggan hanya bisa login di aplikasi mobile']);
            }

            // Jika role tidak dikenali, logout & redirect ke login
            Auth::logout();
            return redirect()->route('login')->withErrors(['error' => 'Role tidak dikenali. Silakan login kembali.']);
        }

        return $next($request);
    }
}
