@extends('layouts.app')

@section('title', 'Dashboard Vendor Rental')

@section('content')
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
    <div class="bg-gradient-to-br from-gray-50 to-white rounded-2xl shadow-xl p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8">
            <div>
                <h2 class="text-2xl font-extrabold text-gray-800 mb-2">
                    Selamat Datang, {{ session('user.vendor.shop_name') ?? 'Pemilik Rental' }}
                </h2>
                <p class="text-blue-600">
                    <span class="font-semibold">{{ $ratingData['user']['name'] }}</span>
                </p>
            </div>
            <div class="mt-4 md:mt-0">
                <span class="inline-block bg-indigo-100 text-indigo-800 px-3 py-1 rounded-full text-sm font-medium">
                    {{ now()->format('d F Y') }}
                </span>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-3 rounded-lg bg-blue-50 text-blue-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-500">Motor Aktif</p>
                        <p class="text-2xl font-semibold text-indigo-600">{{ count($motorData['data'] ?? []) }}</p>
                    </div>
                </div>
            </div>

            <a href="{{ route('vendor.kelola', ['id' => $userId, 'status' => 'pending']) }}" class="group">
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                    <div class="flex items-center">
                        <div class="p-3 rounded-lg bg-yellow-50 text-yellow-600">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-500 group-hover:text-indigo-600">Pesanan Pending</p>
                            <p class="text-2xl font-semibold text-yellow-600 group-hover:text-indigo-600">
                                {{ $pesananPending }}</p>
                        </div>
                    </div>
                </div>
            </a>

            <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-3 rounded-lg bg-green-50 text-green-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-500">Pendapatan Bulan Ini</p>
                        <p class="text-2xl font-semibold text-green-600">Rp
                            {{ number_format($pendapatanBulan, 0, ',', '.') }}</p>
                    </div>
                </div>
            </div>

            <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-3 rounded-lg bg-purple-50 text-purple-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                        </svg>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-500">Rating Rata-Rata</p>
                        <p class="text-2xl font-semibold text-purple-600">
                            {{ $ratingData['user']['vendor']['rating'] ?? '0' }}/5</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Revenue Chart -->
        <div class="bg-white p-6 rounded-2xl shadow-lg mb-8">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6">
                <div>
                    <h3 class="text-xl font-bold text-gray-800">Grafik Pendapatan</h3>
                    <p class="text-gray-600">Perkembangan pendapatan 5 bulan terakhir</p>
                </div>
            </div>
            <div class="h-96">
                <canvas id="pendapatanChart"></canvas>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const pendapatanLabels = @json($rentangBulan);
            const pendapatanData = @json(array_values($pendapatanBulanan));

            const ctxPendapatan = document.getElementById('pendapatanChart').getContext('2d');
            new Chart(ctxPendapatan, {
                type: 'line',
                data: {
                    labels: pendapatanLabels,
                    datasets: [{
                        label: 'Pendapatan (Rp)',
                        data: pendapatanData,
                        borderColor: '#6366F1',
                        borderWidth: 2,
                        pointBackgroundColor: '#6366F1',
                        pointBorderColor: '#fff',
                        pointRadius: 5,
                        pointHoverRadius: 7,
                        fill: true,
                        backgroundColor: 'rgba(99, 102, 241, 0.1)',
                        tension: 0.3
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                            labels: {
                                usePointStyle: true,
                                padding: 20,
                                font: {
                                    size: 14
                                }
                            }
                        },
                        tooltip: {
                            backgroundColor: '#1F2937',
                            titleFont: {
                                size: 14,
                                weight: 'bold'
                            },
                            bodyFont: {
                                size: 13
                            },
                            padding: 12,
                            usePointStyle: true,
                            callbacks: {
                                label: function(context) {
                                    return 'Rp ' + context.parsed.y.toLocaleString('id-ID');
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                drawBorder: false,
                                color: '#E5E7EB'
                            },
                            ticks: {
                                callback: function(value) {
                                    return 'Rp ' + value.toLocaleString('id-ID');
                                },
                                font: {
                                    size: 12
                                }
                            },
                            title: {
                                display: true,
                                text: 'Jumlah Pendapatan',
                                font: {
                                    size: 13,
                                    weight: 'bold'
                                }
                            }
                        },
                        x: {
                            grid: {
                                display: false,
                                drawBorder: false
                            },
                            ticks: {
                                font: {
                                    size: 12
                                }
                            },
                            title: {
                                display: true,
                                text: 'Bulan',
                                font: {
                                    size: 13,
                                    weight: 'bold'
                                }
                            }
                        }
                    }
                }
            });
        });
    </script>
@endsection
