<?php

namespace App\Http\Controllers;
   
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\TransactionExport;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Pagination\Paginator;

class TransaksiController extends Controller
{
    protected $apiBaseUrl = 'http://localhost:8080'; // URL backend

    public function index()
    {
        try {
            // Ambil token
            $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
            if (! $token) {
                Log::error("Token tidak ditemukan");
                return redirect()->route('login')
                                 ->with('error', 'Anda harus login terlebih dahulu.');
            }

            // Fetch transaksi
            $url         = "{$this->apiBaseUrl}/transaction";
            Log::info("Mengirim request ke: " . $url);
            $response    = Http::withToken($token)
                               ->timeout(10)
                               ->get($url);
            Log::info("Response body: " . $response->body());
            $jsonData    = $response->successful() 
                           ? $response->json() 
                           : [];
            $transactions = $jsonData['data'] ?? $jsonData;

            // Fetch motor vendor
            $urlMotors      = "{$this->apiBaseUrl}/motor/vendor";
            Log::info("Mengirim request motor ke: " . $urlMotors);
            $responseMotors = Http::withToken($token)
                                 ->timeout(10)
                                 ->get($urlMotors);
            Log::info("Response motor: " . $responseMotors->body());
            $jsonMotor      = $responseMotors->successful() 
                              ? $responseMotors->json() 
                              : [];
            $motors         = $jsonMotor['data'] ?? $jsonMotor;

        } catch (\Exception $e) {
            Log::error("Kesalahan saat mengambil data: " . $e->getMessage());
            $transactions = [];
            $motors       = [];
        }

        // === START: manual paginasi ===
        $perPage     = 5;
        $currentPage = Paginator::resolveCurrentPage('page'); // ambil ?page=…
        $collection  = collect($transactions);

        // slice dan re-index
        $currentItems = $collection->forPage($currentPage, $perPage)->values();

        $paginatedTransactions = new LengthAwarePaginator(
            $currentItems,
            $collection->count(),
            $perPage,
            $currentPage,
            [
                'path'     => Paginator::resolveCurrentPath(),
                'pageName' => 'page',
            ]
        );
        // === END: manual paginasi ===

        // Kirim view sekali saja, dengan paginator
        return view('vendor.transaksi', [
            'transactions' => $paginatedTransactions,
            'motors'       => $motors,
        ]);
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
public function exportExcel(Request $request)
{
    try {
        $token = session()->get('token');
        if (!$token) {
            return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
        }

        $month = (int) $request->query('month');
        $year = (int) $request->query('year');

        $startDate = Carbon::createFromDate($year, $month, 1)->startOfMonth();
        $endDate = Carbon::createFromDate($year, $month, 1)->endOfMonth();
        $monthName = $startDate->translatedFormat('F'); // contoh: "Maret"

        $queryParams = [
            'start_date' => $startDate->toDateString(),
            'end_date'   => $endDate->toDateString(),
        ];

        $url = "{$this->apiBaseUrl}/transaction";
        $response = Http::withToken($token)->timeout(10)->get($url, $queryParams);

        if ($response->successful()) {
            $jsonData = $response->json();
            $transactions = isset($jsonData['data']) ? $jsonData['data'] : $jsonData;

            $transactions = collect($transactions)->filter(function ($item) use ($month, $year) {
                $bookingDate = Carbon::parse($item['booking_date']);
                return $bookingDate->year === $year && $bookingDate->month === $month;
            })->values()->toArray();

            if (empty($transactions)) {
                return redirect()->back()->with('error', 'Maaf, tidak ditemukan data transaksi untuk bulan dan tahun yang Anda pilih.');
            }

            return Excel::download(
                new TransactionExport($transactions, $monthName, $year),
                "laporan_transaksi_{$month}_{$year}.xlsx"
            );
        } else {
            return redirect()->back()->with('error', 'Gagal mengambil data transaksi.');
        }
    } catch (\Exception $e) {
        return redirect()->back()->with('error', 'Terjadi kesalahan saat mengekspor data.');
    }
}



}
