@extends('layouts.app')

@section('title', 'Dashboard Vendor Rental')

@section('content')
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

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
    
    {{-- @dd($id) --}}
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
            <!-- Motor Aktif -->
            <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-3 rounded-lg bg-blue-50 text-blue-600">
                        <i class="bi bi-bicycle text-2xl"></i>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-500">Motor Aktif</p>
                        <p class="text-2xl font-semibold text-indigo-600">{{ count($motorData['data'] ?? []) }}</p>
                    </div>
                </div>
            </div>

            <!-- Pesanan Pending -->
            <a href="{{ route('vendor.kelola', ['id' => $userId, 'status' => 'pending']) }}" class="group">
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                    <div class="flex items-center">
                        <div class="p-3 rounded-lg bg-yellow-50 text-yellow-600">
                            <i class="bi bi-hourglass-split text-2xl"></i>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-500 group-hover:text-indigo-600">Pesanan Pending</p>
                            <p class="text-2xl font-semibold text-yellow-600 group-hover:text-indigo-600">
                                {{ $pesananPending }}
                            </p>
                        </div>
                    </div>
                </div>
            </a>

            <!-- Pendapatan Bulan Ini -->
            <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-3 rounded-lg bg-green-50 text-green-600">
                        <span class="text-2xl font-bold">Rp</span>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-500">Pendapatan Bulan Ini</p>
                        <p class="text-2xl font-semibold text-green-600">
                            {{ number_format($pendapatanBulan, 0, ',', '.') }}
                        </p>
                    </div>
                </div>
            </div>

            <!-- Rating Rata-Rata -->
            <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-3 rounded-lg bg-purple-50 text-purple-600">
                        <i class="bi bi-star-fill text-2xl"></i>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-500">Rating Rata-Rata</p>
                        <p class="text-2xl font-semibold text-purple-600">
                            {{ $ratingData['user']['vendor']['rating'] ?? '0' }}/5
                        </p>
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

    <!-- Recent Activity -->
    <div class="bg-white p-6 rounded-2xl shadow-lg">
        <h3 class="text-xl font-bold text-gray-800 mb-4">Aktivitas Terakhir</h3>
        <div class="space-y-4">
            <div class="flex items-start pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                <div class="p-2 rounded-lg bg-indigo-50 text-indigo-600 mr-3">
                    <i class="bi bi-plus-circle-fill text-lg"></i>
                </div>
                <div class="flex-1">
                    <p class="text-sm font-medium text-gray-800">Ada {{ count($motorData['data'] ?? []) }} motor aktif yang
                        dapat disewa</p>
                    <p class="text-xs text-gray-500 mt-1">Diperbarui hari ini</p>
                </div>
            </div>

            <div class="flex items-start pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                <div class="p-2 rounded-lg bg-yellow-50 text-yellow-600 mr-3">
                    <i class="bi bi-hourglass-split text-lg"></i>
                </div>
                <div class="flex-1">
                    <p class="text-sm font-medium text-gray-800">{{ $pesananPending }} pesanan masih menunggu konfirmasi</p>
                    <p class="text-xs text-gray-500 mt-1">Diperbarui hari ini</p>
                </div>
            </div>

            <div class="flex items-start pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                <div class="p-2 rounded-lg bg-green-50 text-green-600 mr-3">
                    <i class="bi bi-coin text-lg"></i>
                </div>
                <div class="flex-1">
                    <p class="text-sm font-medium text-gray-800">Pendapatan bulan ini: Rp
                        {{ number_format($pendapatanBulan, 0, ',', '.') }}</p>
                    <p class="text-xs text-gray-500 mt-1">Diperbarui hari ini</p>
                </div>
            </div>

            <div class="flex items-start pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                <div class="p-2 rounded-lg bg-purple-50 text-purple-600 mr-3">
                    <i class="bi bi-star-fill text-lg"></i>
                </div>
                <div class="flex-1">
                    <p class="text-sm font-medium text-gray-800">Rating rata-rata vendor:
                        {{ $ratingData['user']['vendor']['rating'] ?? '0' }}/5</p>
                    <p class="text-xs text-gray-500 mt-1">Diperbarui hari ini</p>
                </div>
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
