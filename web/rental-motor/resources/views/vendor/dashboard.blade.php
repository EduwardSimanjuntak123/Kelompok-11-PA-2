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
    <div class="bg-gradient-to-br from-gray-50 to-white rounded-2xl shadow-xl p-4 sm:p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 sm:mb-8">
            <div class="w-full md:w-auto">
                <h2 class="text-xl sm:text-2xl font-extrabold text-gray-800 mb-2 break-words">
                    Selamat Datang, {{ session('user.vendor.shop_name') ?? 'Pemilik Rental' }}
                </h2>
                <p class="text-blue-600 text-sm sm:text-base">
                    <span class="font-semibold">{{ $ratingData['user']['name'] }}</span>
                </p>
            </div>
            <div class="mt-4 md:mt-0 w-full md:w-auto">
                <span class="inline-block bg-indigo-100 text-indigo-800 px-3 py-1 rounded-full text-xs sm:text-sm font-medium w-full md:w-auto text-center">
                    {{ now()->format('d F Y') }}
                </span>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 mb-6 sm:mb-8">
            <!-- Motor Aktif -->
            <div class="bg-white p-3 sm:p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-2 sm:p-3 rounded-lg bg-blue-50 text-blue-600 flex-shrink-0">
                        <i class="bi bi-bicycle text-xl sm:text-2xl"></i>
                    </div>
                    <div class="ml-3 sm:ml-4 min-w-0 flex-1">
                        <p class="text-xs sm:text-sm font-medium text-gray-500 truncate">Motor Aktif</p>
                        <p class="text-xl sm:text-2xl font-semibold text-indigo-600">{{ count($motorData['data'] ?? []) }}</p>
                    </div>
                </div>
            </div>

            <!-- Pesanan Pending -->
            <a href="{{ route('vendor.kelola', ['id' => $userId, 'status' => 'pending']) }}" class="group">
                <div class="bg-white p-3 sm:p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                    <div class="flex items-center">
                        <div class="p-2 sm:p-3 rounded-lg bg-yellow-50 text-yellow-600 flex-shrink-0">
                            <i class="bi bi-hourglass-split text-xl sm:text-2xl"></i>
                        </div>
                        <div class="ml-3 sm:ml-4 min-w-0 flex-1">
                            <p class="text-xs sm:text-sm font-medium text-gray-500 group-hover:text-indigo-600 truncate">Pesanan Pending</p>
                            <p class="text-xl sm:text-2xl font-semibold text-yellow-600 group-hover:text-indigo-600">
                                {{ $pesananPending }}
                            </p>
                        </div>
                    </div>
                </div>
            </a>

            <!-- Pendapatan Bulan Ini -->
            <div class="bg-white p-3 sm:p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-2 sm:p-3 rounded-lg bg-green-50 text-green-600 flex-shrink-0">
                        <span class="text-xl sm:text-2xl font-bold">Rp</span>
                    </div>
                    <div class="ml-3 sm:ml-4 min-w-0 flex-1">
                        <p class="text-xs sm:text-sm font-medium text-gray-500 truncate">Pendapatan Bulan Ini</p>
                        <p class="text-lg sm:text-2xl font-semibold text-green-600 break-all sm:break-normal">
                            {{ number_format($pendapatanBulan, 0, ',', '.') }}
                        </p>
                    </div>
                </div>
            </div>

            <!-- Rating Rata-Rata -->
            <div class="bg-white p-3 sm:p-4 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-2 sm:p-3 rounded-lg bg-purple-50 text-purple-600 flex-shrink-0">
                        <i class="bi bi-star-fill text-xl sm:text-2xl"></i>
                    </div>
                    <div class="ml-3 sm:ml-4 min-w-0 flex-1">
                        <p class="text-xs sm:text-sm font-medium text-gray-500 truncate">Rating Rata-Rata</p>
                        <p class="text-xl sm:text-2xl font-semibold text-purple-600">
                            {{ $ratingData['user']['vendor']['rating'] ?? '0' }}/5
                        </p>
                    </div>
                </div>
            </div>
        </div>


        <!-- Revenue Chart -->
        <div class="bg-white p-4 sm:p-6 rounded-2xl shadow-lg mb-6 sm:mb-8">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-4 sm:mb-6">
                <div class="w-full md:w-auto mb-4 md:mb-0">
                    <h3 class="text-lg sm:text-xl font-bold text-gray-800">Grafik Pendapatan</h3>
                    <p class="text-sm sm:text-base text-gray-600">Perkembangan pendapatan 5 bulan terakhir</p>
                </div>
            </div>
            <div class="h-64 sm:h-80 lg:h-96 w-full">
                <canvas id="pendapatanChart" class="w-full h-full"></canvas>
            </div>
        </div>
    </div>

    <!-- Recent Activity -->
    <div class="bg-white p-4 sm:p-6 rounded-2xl shadow-lg">
        <h3 class="text-lg sm:text-xl font-bold text-gray-800 mb-4">Aktivitas Terakhir</h3>
        <div class="space-y-3 sm:space-y-4">
            <div class="flex items-start pb-3 sm:pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                <div class="p-2 rounded-lg bg-indigo-50 text-indigo-600 mr-3 flex-shrink-0">
                    <i class="bi bi-plus-circle-fill text-base sm:text-lg"></i>
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-xs sm:text-sm font-medium text-gray-800 break-words">Ada {{ count($motorData['data'] ?? []) }} motor aktif yang
                        dapat disewa</p>
                    <p class="text-xs text-gray-500 mt-1">Diperbarui hari ini</p>
                </div>
            </div>

            <div class="flex items-start pb-3 sm:pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                <div class="p-2 rounded-lg bg-yellow-50 text-yellow-600 mr-3 flex-shrink-0">
                    <i class="bi bi-hourglass-split text-base sm:text-lg"></i>
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-xs sm:text-sm font-medium text-gray-800 break-words">{{ $pesananPending }} pesanan masih menunggu konfirmasi</p>
                    <p class="text-xs text-gray-500 mt-1">Diperbarui hari ini</p>
                </div>
            </div>

            <div class="flex items-start pb-3 sm:pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                <div class="p-2 rounded-lg bg-green-50 text-green-600 mr-3 flex-shrink-0">
                    <i class="bi bi-coin text-base sm:text-lg"></i>
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-xs sm:text-sm font-medium text-gray-800 break-words">Pendapatan bulan ini: Rp
                        {{ number_format($pendapatanBulan, 0, ',', '.') }}</p>
                    <p class="text-xs text-gray-500 mt-1">Diperbarui hari ini</p>
                </div>
            </div>

            <div class="flex items-start pb-3 sm:pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                <div class="p-2 rounded-lg bg-purple-50 text-purple-600 mr-3 flex-shrink-0">
                    <i class="bi bi-star-fill text-base sm:text-lg"></i>
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-xs sm:text-sm font-medium text-gray-800 break-words">Rating rata-rata vendor:
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
                                padding: window.innerWidth < 640 ? 10 : 20,
                                font: {
                                    size: window.innerWidth < 640 ? 12 : 14
                                }
                            }
                        },
                        tooltip: {
                            backgroundColor: '#1F2937',
                            titleFont: {
                                size: window.innerWidth < 640 ? 12 : 14,
                                weight: 'bold'
                            },
                            bodyFont: {
                                size: window.innerWidth < 640 ? 11 : 13
                            },
                            padding: window.innerWidth < 640 ? 8 : 12,
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
                                    if (window.innerWidth < 640) {
                                        // Format lebih singkat untuk mobile
                                        if (value >= 1000000) {
                                            return 'Rp ' + (value / 1000000).toFixed(1) + 'M';
                                        } else if (value >= 1000) {
                                            return 'Rp ' + (value / 1000).toFixed(1) + 'K';
                                        }
                                        return 'Rp ' + value.toLocaleString('id-ID');
                                    }
                                    return 'Rp ' + value.toLocaleString('id-ID');
                                },
                                font: {
                                    size: window.innerWidth < 640 ? 10 : 12
                                },
                                maxTicksLimit: window.innerWidth < 640 ? 5 : 8
                            },
                            title: {
                                display: window.innerWidth >= 640,
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
                                    size: window.innerWidth < 640 ? 10 : 12
                                },
                                maxRotation: window.innerWidth < 640 ? 45 : 0,
                                callback: function(value, index) {
                                    const label = this.getLabelForValue(value);
                                    if (window.innerWidth < 640) {
                                        // Format lebih singkat untuk mobile
                                        return label.split(' ')[0];
                                    }
                                    return label;
                                }
                            },
                            title: {
                                display: window.innerWidth >= 640,
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