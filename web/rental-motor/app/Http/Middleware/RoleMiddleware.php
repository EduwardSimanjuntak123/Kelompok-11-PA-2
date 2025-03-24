<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, $role)
    {

        if (!session()->has('role')) {
            return redirect('/login')->withErrors(['error' => 'Akses tidak diizinkan!']);
        }

        if (Session::get('role') != $role) {
            if (Session::get('role')== 'admin') {
                return redirect('/admin')->withErrors("Customer hanya bisa Log in di device mobile");
            }
            elseif (Session::get('role')== 'vendor') {
                return redirect('/vendor');
            } else {
                return redirect('/login');
            }
        }
        return $next($request);
    }
}

