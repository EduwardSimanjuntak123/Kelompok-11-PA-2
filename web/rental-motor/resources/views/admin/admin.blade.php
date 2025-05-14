@extends('layouts.app')

@section('title', 'Dashboard Admin')

@section('content')
    <div class="bg-gradient-to-br from-gray-50 to-white rounded-2xl shadow-xl p-6">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8">
            <div>
                <h2 class="text-3xl font-bold text-gray-800">Dashboard Admin</h2>
                <p class="text-gray-600 mt-2">Ringkasan aktivitas dan statistik sistem</p>
            </div>
            <div class="mt-4 md:mt-0">
                <span class="inline-block bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-medium">
                    {{ now()->format('d F Y') }}
                </span>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-3 rounded-lg bg-blue-50 text-blue-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                        </svg>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-500">Total Vendor</p>
                        <p class="text-2xl font-semibold text-gray-800">{{ array_sum($vendorCounts) }}</p>
                    </div>
                </div>
            </div>

            <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                    <div class="p-3 rounded-lg bg-green-50 text-green-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                        </svg>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-500">Total Customer</p>
                        <p class="text-2xl font-semibold text-gray-800">{{ array_sum($customerCounts) }}</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Chart -->
        <div class="bg-white p-6 rounded-2xl shadow-lg mb-8">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6">
                <div>
                    <h3 class="text-xl font-bold text-gray-800">Pertumbuhan Pengguna</h3>
                    <p class="text-gray-600">Perkembangan pendaftar vendor dan customer</p>
                </div>
            </div>
            <div class="h-96">
                <canvas id="pendaftarChart"></canvas>
            </div>
        </div>

        <!-- Recent Activity -->
        <div class="bg-white p-6 rounded-2xl shadow-lg">
            <h3 class="text-xl font-bold text-gray-800 mb-4">Aktivitas Terakhir</h3>
            <div class="space-y-4">
                <div class="flex items-start pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                    <div class="p-2 rounded-lg bg-blue-50 text-blue-600 mr-3">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                        </svg>
                    </div>
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-800">Total {{ array_sum($vendorCounts) }} vendor dan
                            {{ array_sum($customerCounts) }} customer terdaftar</p>
                        <p class="text-xs text-gray-500 mt-1">Hari ini</p>
                    </div>
                </div>
                <div class="flex items-start pb-4 border-b border-gray-100 last:border-0 last:pb-0">
                    <div class="p-2 rounded-lg bg-green-50 text-green-600 mr-3">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    </div>
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-800">Sistem berjalan dengan baik</p>
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
                                size: 12
                            }
                        },
                        title: {
                            display: true,
                            text: 'Jumlah Pendaftar',
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
    </script>
@endsection
