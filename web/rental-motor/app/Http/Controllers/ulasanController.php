<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class ulasanController extends Controller
{
    protected $apiBaseUrl;

    public function __construct()
    {
        $this->apiBaseUrl = config('api.base_url');
    }
    public function index($id)
    {
        try {
            $token = session('token');
            if (!$token) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
            }

            // Get bookings from Go backend
            $urlReviews = "{$this->apiBaseUrl}/vendor/reviews";
            Log::info("Mengirim request reviews ke: " . $urlReviews);
            $responseReviews = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token
            ])->timeout(10)->get($urlReviews, [
                'vendor_id' => $id
            ]);
            Log::info("Response reviews: " . $responseReviews->body());
            $Reviews = ($responseReviews->successful() && is_array($responseReviews->json()))
                        ? $responseReviews->json()
                        : [];
            

        } catch (\Exception $e) {
            Log::error('Gagal mengambil data atau motor: ' . $e->getMessage());
            $Reviews = [];
        }

        return view('vendor.ulasan', compact('Reviews'));
    }


    public function submitReply(Request $request, $id)
{
    $token = session('token'); // Ambil token dari session

    if (!$token) {
        return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
    }

    $response = Http::withHeaders([
        'Authorization' => 'Bearer ' . $token
    ])->post("{$this->apiBaseUrl}/vendor/review/{$id}/reply", [
        'reply' => $request->input('balasan')
    ]);
    

    if ($response->successful()) {
        return redirect()->back()->with('success', 'Balasan berhasil dikirim.');
    } else {
        return redirect()->back()->with('error', 'Gagal mengirim balasan.');
    }
}

}
