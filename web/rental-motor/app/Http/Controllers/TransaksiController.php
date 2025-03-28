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
    
    public function exportExcel(Request $request)
{
    try {
        $token = session()->get('token', 'TOKEN_KAMU_DI_SINI');
        if (!$token) {
            return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu.');
        }

        $month = (int) $request->query('month');
        $year = (int) $request->query('year');

        $startDate = Carbon::createFromDate($year, $month, 1)->startOfMonth();
        $endDate = Carbon::createFromDate($year, $month, 1)->endOfMonth();

        $queryParams = [
            'start_date' => $startDate->toDateString(),
            'end_date'   => $endDate->toDateString(),
        ];

        $url = "{$this->apiBaseUrl}/transaction";
        Log::info("Mengambil laporan bulan: $month/$year | Params: " . json_encode($queryParams));
        $response = Http::withToken($token)->timeout(10)->get($url, $queryParams);
        Log::info("Response laporan: " . $response->body());

        if ($response->successful()) {
            $jsonData = $response->json();
            $transactions = isset($jsonData['data']) ? $jsonData['data'] : $jsonData;

            // ✅ Filter hanya data dengan booking_date di bulan & tahun yang dipilih
            $transactions = collect($transactions)->filter(function ($item) use ($month, $year) {
                $bookingDate = Carbon::parse($item['booking_date']);
                return $bookingDate->year === $year && $bookingDate->month === $month;
            })->values()->toArray();

            // ✅ Validasi jika kosong
            if (empty($transactions)) {
                return redirect()->back()->with('error', 'Tidak ada data transaksi di bulan yang dipilih.');
            }
        } else {
            Log::error("Gagal mengambil data transaksi bulanan. HTTP Status: " . $response->status());
            return redirect()->back()->with('error', 'Gagal mengambil data transaksi.');
        }
    } catch (\Exception $e) {
        Log::error("Kesalahan saat export transaksi: " . $e->getMessage());
        return redirect()->back()->with('error', 'Terjadi kesalahan saat mengekspor data.');
    }

    return Excel::download(new TransactionExport($transactions), "transaksi_{$year}_{$month}.xlsx");
}

}
