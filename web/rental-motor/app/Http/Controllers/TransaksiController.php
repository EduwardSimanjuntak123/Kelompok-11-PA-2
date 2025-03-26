<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\TransactionExport;

class TransaksiController extends Controller
{
    protected $apiBaseUrl = 'http://localhost:8080'; // URL backend

    public function index()
    {
        try {
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
            if (!$token) {
                Log::error("Token tidak ditemukan");
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
            }
            
            // Ambil transaksi
            $url = "{$this->apiBaseUrl}/transaction";
            Log::info("Mengirim request ke: " . $url);
            $response = Http::withToken($token)->timeout(10)->get($url);
            Log::info("Response body: " . $response->body());
            
            if ($response->successful()) {
                $jsonData = $response->json();
                $transactions = isset($jsonData['data']) ? $jsonData['data'] : $jsonData;
            } else {
                Log::error("Gagal mengambil data transaksi. HTTP Status: " . $response->status());
                $transactions = [];
            }
            
            // Ambil motor vendor dari API
            $urlMotors = "{$this->apiBaseUrl}/motor/vendor";
            Log::info("Mengirim request motor ke: " . $urlMotors);
            $responseMotors = Http::withToken($token)->timeout(10)->get($urlMotors);
            Log::info("Response motor: " . $responseMotors->body());
            if ($responseMotors->successful()) {
                $jsonMotor = $responseMotors->json();
                $motors = isset($jsonMotor['data']) ? $jsonMotor['data'] : $jsonMotor;
            } else {
                Log::error("Gagal mengambil data motor. HTTP Status: " . $responseMotors->status());
                $motors = [];
            }
        } catch (\Exception $e) {
            Log::error("Kesalahan saat mengambil data: " . $e->getMessage());
            $transactions = [];
            $motors = [];
        }
        
        return view('vendor.transaksi', compact('transactions', 'motors'));
    }

    // Fungsi untuk menambahkan transaksi manual (sudah ada)
    public function addTransactionManual(Request $request)
    {
        try {
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
            if (!$token) {
                return redirect()->back()->with('error', 'Anda harus login terlebih dahulu.');
            }

            $validated = $request->validate([
                'motor_id'        => 'required|integer',
                'start_date'      => 'required|string',
                'end_date'        => 'required|string',
                'pickup_location' => 'required|string',
            ]);

            $multipart = [];
            foreach ($validated as $key => $value) {
                $multipart[] = ['name' => $key, 'contents' => $value];
            }
            $multipart[] = ['name' => 'type', 'contents' => 'manual'];
            $multipart[] = ['name' => 'status', 'contents' => 'completed'];

            if ($request->hasFile('photo_id')) {
                $file = $request->file('photo_id');
                $multipart[] = [
                    'name'     => 'photo_id',
                    'contents' => fopen($file->getPathname(), 'r'),
                    'filename' => $file->getClientOriginalName()
                ];
            }

            if ($request->hasFile('ktp_id')) {
                $file = $request->file('ktp_id');
                $multipart[] = [
                    'name'     => 'ktp_id',
                    'contents' => fopen($file->getPathname(), 'r'),
                    'filename' => $file->getClientOriginalName()
                ];
            }

            $url = $this->apiBaseUrl . '/transaction/manual';
            Log::info("Mengirim request ke: " . $url);
            $response = Http::withToken($token)->asMultipart()->post($url, $multipart);
            Log::info("Response dari addTransactionManual: " . $response->body());

            if ($response->successful()) {
                return redirect()->route('vendor.transactions')->with('message', 'Transaksi manual berhasil ditambahkan');
            } else {
                return redirect()->back()->with('error', 'Gagal menambahkan transaksi manual');
            }
        } catch (\Exception $e) {
            Log::error("Terjadi kesalahan saat menambahkan transaksi manual: " . $e->getMessage());
            return redirect()->back()->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }

    // Fungsi untuk mencetak laporan transaksi berdasarkan rentang (week atau month)
     // Fungsi untuk mengekspor transaksi ke Excel
     public function exportExcel(Request $request)
     {
         try {
             $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
             if (!$token) {
                 return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
             }
             
             // Ambil parameter rentang laporan, misalnya "week" atau "month"
             $range = $request->query('range', 'week');
             $endDate = Carbon::today();
             if ($range === 'week') {
                 $startDate = $endDate->copy()->subDays(7);
             } elseif ($range === 'month') {
                 $startDate = $endDate->copy()->subMonth();
             } else {
                 $startDate = $endDate->copy()->subDays(7);
             }
            //  dd($range);
             
             // Siapkan parameter untuk query API (misalnya, menggunakan query string)
             $queryParams = [
                 'start_date' => $startDate->toDateString(),
                 'end_date'   => $endDate->toDateString(),
             ];
             
             $url = "{$this->apiBaseUrl}/transaction";
             Log::info("Mengirim request laporan ke: " . $url . " dengan parameter " . json_encode($queryParams));
             $response = Http::withToken($token)->timeout(10)->get($url, $queryParams);
             Log::info("Response laporan: " . $response->body());
             
             if ($response->successful()) {
                 $jsonData = $response->json();
                 $transactions = isset($jsonData['data']) ? $jsonData['data'] : $jsonData;
             } else {
                 Log::error("Gagal mengambil data laporan transaksi. HTTP Status: " . $response->status());
                 $transactions = [];
             }
         } catch (\Exception $e) {
             Log::error("Kesalahan saat mengambil data laporan transaksi: " . $e->getMessage());
             $transactions = [];
         }
         
         // Ekspor data ke Excel menggunakan TransactionExport
         return Excel::download(new TransactionExport($transactions), 'transactions.xlsx');
     }
}
