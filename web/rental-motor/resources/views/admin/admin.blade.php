@extends('layouts.app')

@section('title', 'Dashboard Admin')

@section('content')
    <div class="bg-white shadow-md rounded-lg p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Dashboard Admin</h2>

        <div class="mb-8">
            <canvas id="pendaftarChart" height="120"></canvas>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const ctx = document.getElementById('pendaftarChart').getContext('2d');

        const pendaftarChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: {!! json_encode($labels) !!}, // Misal: ['Februari', 'Maret', 'April', 'Mei', 'Juni']
                datasets: [{
                        label: 'Vendor',
                        data: {!! json_encode($vendorCounts) !!},
                        fill: true,
                        backgroundColor: 'rgba(59, 130, 246, 0.1)', // Biru transparan
                        borderColor: '#3B82F6',
                        borderDash: [5, 5], // Garis putus-putus
                        tension: 0.4, // Melengkung
                        pointBackgroundColor: '#3B82F6',
                        pointBorderColor: '#1D4ED8',
                        pointRadius: 5,
                        borderWidth: 2
                    },
                    {
                        label: 'Customer',
                        data: {!! json_encode($customerCounts) !!},
                        fill: true,
                        backgroundColor: 'rgba(16, 185, 129, 0.1)', // Hijau transparan
                        borderColor: '#10B981',
                        borderDash: [5, 5],
                        tension: 0.4,
                        pointBackgroundColor: '#10B981',
                        pointBorderColor: '#047857',
                        pointRadius: 5,
                        borderWidth: 2
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: true,
                        labels: {
                            usePointStyle: true,
                            pointStyle: 'circle'
                        }
                    },
                    title: {
                        display: true,
                        text: 'Jumlah Pendaftar Vendor & Customer per Bulan',
                        font: {
                            size: 18
                        }
                    },
                    tooltip: {
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
                        ticks: {
                            stepSize: 1
                        },
                        title: {
                            display: true,
                            text: 'Jumlah Pendaftar'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Bulan'
                        }
                    }
                }
            }
        });
    </script>
@endsection
