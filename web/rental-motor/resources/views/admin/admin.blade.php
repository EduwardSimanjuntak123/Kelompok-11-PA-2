@extends('layouts.app')

@section('title', 'Dashboard Admin' )

@section('content')
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <div class="bg-gradient-to-br from-gray-50 to-white rounded-2xl shadow-xl p-4 sm:p-6">
        <!-- Header Section - Improved responsive layout -->
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 sm:mb-8 gap-4">
            <div class="w-full sm:w-auto">
                <h2 class="text-2xl sm:text-3xl font-bold text-gray-800">Dashboard Admin</h2>
                <p class="text-sm sm:text-base text-gray-600 mt-1 sm:mt-2">Ringkasan aktivitas dan statistik sistem</p>
            </div>
            <div class="w-full sm:w-auto">
                <span class="inline-block bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs sm:text-sm font-medium w-full sm:w-auto text-center">
                    {{ now()->format('d F Y') }}
                </span>
            </div>
        </div>

        <!-- Stats Cards - Enhanced responsive grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-6 mb-6 sm:mb-8">
            <div class="bg-white p-4 sm:p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-2 sm:p-3 rounded-lg bg-blue-50 text-blue-600 flex-shrink-0">
                        <i class="bi bi-building text-xl sm:text-2xl"></i>
                    </div>
                    <div class="ml-3 sm:ml-4 min-w-0 flex-1">
                        <p class="text-xs sm:text-sm font-medium text-gray-500 truncate">Total Vendor</p>
                        <p class="text-xl sm:text-2xl font-semibold text-gray-800">{{ array_sum($vendorCounts) }}</p>
                    </div>
                </div>
            </div>

            <div class="bg-white p-4 sm:p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-2 sm:p-3 rounded-lg bg-green-50 text-green-600 flex-shrink-0">
                        <i class="bi bi-people-fill text-xl sm:text-2xl"></i>
                    </div>
                    <div class="ml-3 sm:ml-4 min-w-0 flex-1">
                        <p class="text-xs sm:text-sm font-medium text-gray-500 truncate">Total Customer</p>
                        <p class="text-xl sm:text-2xl font-semibold text-gray-800">{{ array_sum($customerCounts) }}</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Chart - Responsive container -->
        <div class="bg-white p-4 sm:p-6 rounded-2xl shadow-lg mb-6 sm:mb-8">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-4 sm:mb-6 gap-2 sm:gap-4">
                <div class="w-full sm:w-auto">
                    <h3 class="text-lg sm:text-xl font-bold text-gray-800">Pertumbuhan Pengguna</h3>
                    <p class="text-sm sm:text-base text-gray-600 mt-1">Perkembangan pendaftar vendor dan customer</p>
                </div>
            </div>
            <!-- Responsive chart container -->
            <div class="h-64 sm:h-80 lg:h-96 w-full">
                <canvas id="pendaftarChart" class="w-full h-full"></canvas>
            </div>
        </div>

        <!-- Recent Activity - Enhanced mobile layout -->
        <div class="bg-white p-4 sm:p-6 rounded-2xl shadow-lg">
            <h3 class="text-lg sm:text-xl font-bold text-gray-800 mb-3 sm:mb-4">Aktivitas Terakhir</h3>
            <div class="space-y-3 sm:space-y-4">
                <div class="flex items-start pb-3 sm:pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                    <div class="p-2 rounded-lg bg-blue-50 text-blue-600 mr-3 flex-shrink-0">
                        <i class="bi bi-person-lines-fill text-base sm:text-lg"></i>
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-xs sm:text-sm font-medium text-gray-800 break-words">
                            Total {{ array_sum($vendorCounts) }} vendor dan {{ array_sum($customerCounts) }} customer terdaftar
                        </p>
                        <p class="text-xs text-gray-500 mt-1">Hari ini</p>
                    </div>
                </div>
                <div class="flex items-start pb-3 sm:pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                    <div class="p-2 rounded-lg bg-green-50 text-green-600 mr-3 flex-shrink-0">
                        <i class="bi bi-check-circle-fill text-base sm:text-lg"></i>
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-xs sm:text-sm font-medium text-gray-800">Sistem berjalan dengan baik</p>
                        <p class="text-xs text-gray-500 mt-1">Hari ini</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const ctx = document.getElementById('pendaftarChart').getContext('2d');

        const pendaftarChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: @json($labels),
                datasets: [{
                        label: 'Vendor',
                        data: @json($vendorCounts),
                        fill: true,
                        backgroundColor: 'rgba(99, 102, 241, 0.1)',
                        borderColor: '#6366F1',
                        borderWidth: 2,
                        tension: 0.3,
                        pointBackgroundColor: '#6366F1',
                        pointBorderColor: '#fff',
                        pointRadius: 5,
                        pointHoverRadius: 7
                    },
                    {
                        label: 'Customer',
                        data: @json($customerCounts),
                        fill: true,
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        borderColor: '#10B981',
                        borderWidth: 2,
                        tension: 0.3,
                        pointBackgroundColor: '#10B981',
                        pointBorderColor: '#fff',
                        pointRadius: 5,
                        pointHoverRadius: 7
                    }
                ]
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
                                return context.dataset.label + ': ' + context.parsed.y + ' orang';
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
                            stepSize: 1,
                            font: {
                                size: window.innerWidth < 640 ? 10 : 12
                            }
                        },
                        title: {
                            display: true,
                            text: 'Jumlah Pendaftar',
                            font: {
                                size: window.innerWidth < 640 ? 11 : 13,
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
                            maxRotation: window.innerWidth < 640 ? 45 : 0
                        },
                        title: {
                            display: true,
                            text: 'Bulan',
                            font: {
                                size: window.innerWidth < 640 ? 11 : 13,
                                weight: 'bold'
                            }
                        }
                    }
                }
            }
        });

        // Handle window resize for chart responsiveness
        window.addEventListener('resize', function() {
            pendaftarChart.resize();
        });
    </script>
@endsection