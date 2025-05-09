@extends('layouts.app')

@section('title', 'Dashboard Vendor Rental')

@section('content')
    <!-- Greeting -->
    <div class="bg-white shadow-xl rounded-2xl p-6 mb-6">
        <h2 class="text-2xl font-extrabold text-gray-800 mb-2">
            Selamat Datang, {{ session('user.vendor.shop_name') ?? 'Pemilik Rental' }}
        </h2>
        <p class="text-blue-600">
            <span class="font-semibold">{{ $ratingData['user']['name'] }}</span>
        </p>
    </div>

    @php
        use Carbon\Carbon;

        $userId = session('user_id') ?? null;

        // Inisialisasi array pendapatan bulanan
        $pendapatanBulanan = [];
        $bulanSekarang = Carbon::now()->startOfMonth(); // Awal bulan sekarang
        $bulanFormat = 'F Y';

        // Rentang 2 bulan sebelum dan 2 bulan setelah bulan sekarang
        $rentangBulan = [];
        for ($i = -2; $i <= 2; $i++) {
            $bulan = $bulanSekarang->copy()->addMonths($i)->format($bulanFormat);
            $rentangBulan[] = $bulan;
            $pendapatanBulanan[$bulan] = 0; // Inisialisasi pendapatan
        }

        // Pastikan transactions memiliki nilai default array kosong
        $transactions = $transactions ?? [];

        // Hitung pendapatan berdasarkan transaksi
        if (!empty($transactions)) {
            foreach ($transactions as $transaction) {
                $bulan = Carbon::parse($transaction['created_at'])->format($bulanFormat);
                if (isset($pendapatanBulanan[$bulan])) {
                    $pendapatanBulanan[$bulan] += $transaction['total_price'];
                }
            }
        }

        // Total pendapatan bulan ini
        $bulanSekarangFormatted = $bulanSekarang->format($bulanFormat);
        $pendapatanBulan = $pendapatanBulanan[$bulanSekarangFormatted] ?? 0;

        // Pastikan bookingData memiliki nilai default array kosong
        $bookingData = $bookingData ?? [];

        // Hitung jumlah pesanan yang berstatus "pending"
        $pesananPending = collect($bookingData)->where('status', 'pending')->count();
    @endphp

    <!-- Summary Cards -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <div class="bg-white shadow rounded-xl p-4 h-32 flex flex-col justify-center text-center">
            <p class="text-sm text-gray-500">Motor Aktif</p>
            <h3 class="text-2xl font-bold text-indigo-600">{{ count($motorData['data'] ?? []) }}</h3>
        </div>
        <a href="{{ route('vendor.kelola', ['id' => $userId, 'status' => 'pending']) }}" class="group">
            <div
                class="bg-white shadow rounded-xl p-4 h-32 flex flex-col justify-center text-center transition-transform hover:scale-105">
                <p class="text-sm text-gray-500 group-hover:text-indigo-600">Pesanan Masuk (Pending)</p>
                <h3 class="text-2xl font-bold text-green-600 group-hover:text-indigo-700">{{ $pesananPending }}</h3>
            </div>
        </a>
        <div
            class="bg-white shadow rounded-xl p-4 h-32 flex flex-col justify-center text-center border-l-4 border-green-500">
            <p class="text-sm text-gray-500">Pendapatan Bulan {{ $bulanSekarangFormatted }}</p>
            <h3 class="text-2xl font-bold text-green-600">Rp {{ number_format($pendapatanBulan, 0, ',', '.') }}</h3>
        </div>
        <div class="bg-white shadow rounded-xl p-4 h-32 flex flex-col justify-center text-center">
            <p class="text-sm text-gray-500">Rating Rata-Rata</p>
            <h3 class="text-2xl font-bold text-purple-600">{{ $ratingData['user']['vendor']['rating'] ?? '0' }}/5</h3>
        </div>
    </div>

    <!-- Grafik Pendapatan -->
    <div class="bg-white shadow-xl rounded-2xl p-6 mb-6">
        <h3 class="text-lg font-bold text-gray-800 mb-4">Grafik Pendapatan Per Bulan</h3>
        <canvas id="pendapatanChart"></canvas>
    </div>


    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const pendapatanLabels = @json($rentangBulan);
            const pendapatanData = @json(array_values($pendapatanBulanan));

            // Dapatkan bulan saat ini (0 = Jan, 11 = Des)
            const currentMonth = new Date().getMonth();

            // Cari index bulan saat ini di array $rentangBulan
            const indexBulanIni = pendapatanLabels.findIndex(label => {
                const date = new Date(`${label} 1, ${new Date().getFullYear()}`);
                return date.getMonth() === currentMonth;
            });

            // Atur warna titik
            const defaultColor = 'blue';
            const highlightColor = 'red';

            const pointColors = pendapatanLabels.map((_, i) =>
                i === indexBulanIni ? highlightColor : defaultColor
            );

            const ctxPendapatan = document.getElementById('pendapatanChart').getContext('2d');
            new Chart(ctxPendapatan, {
                type: 'line',
                data: {
                    labels: pendapatanLabels,
                    datasets: [{
                        label: 'Pendapatan (Rp)',
                        data: pendapatanData,
                        borderColor: defaultColor,
                        borderWidth: 2,
                        pointBackgroundColor: pointColors,
                        pointBorderColor: pointColors,
                        pointRadius: 6,
                        fill: false,
                        tension: 0.3,
                        borderDash: [5, 5]
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return 'Rp ' + value.toLocaleString('id-ID');
                                }
                            }
                        }
                    }
                }
            });
        });
    </script>
@endsection
