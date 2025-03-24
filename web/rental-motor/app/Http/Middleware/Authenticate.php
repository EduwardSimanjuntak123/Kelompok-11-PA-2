<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Session;

class Authenticate
{
    public function handle(Request $request, Closure $next)
    {
        // Cek apakah token ada dalam session
        if (!Session::has('token')) {
            Log::warning("Middleware Authenticate: Tidak ada token dalam session.");
            return redirect()->route('login')->withErrors(['error' => 'Silakan login terlebih dahulu!']);
        }

        // Cek peran user
        $role = Session::get("role");

        if ($role === "admin" || $role === "vendor") {
            return redirect()->route('admin');
        }

        Log::warning("Middleware Authenticate: Peran tidak valid - " . $role);
        return redirect()->route('login')->withErrors(['error' => 'Akses tidak diizinkan!']);
    }
}
