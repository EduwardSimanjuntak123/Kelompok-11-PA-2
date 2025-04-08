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
            type: 'bar',
            data: {
                labels: {!! json_encode($labels) !!},
                datasets: [
                    {
                        label: 'Vendor',
                        data: {!! json_encode($vendorCounts) !!},
                        backgroundColor: '#3B82F6',
                        borderColor: '#2563EB',
                        borderWidth: 1,
                        borderRadius: 6
                    },
                    {
                        label: 'Customer',
                        data: {!! json_encode($customerCounts) !!},
                        backgroundColor: '#10B981',
                        borderColor: '#059669',
                        borderWidth: 1,
                        borderRadius: 6
                    }
                ]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true
                    }
                }
            }
        });
    </script>
@endsection
