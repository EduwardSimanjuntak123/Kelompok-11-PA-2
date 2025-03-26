@extends('layouts.app')

@section('title', 'Cetak Laporan Transaksi Vendor')

@section('content')
    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Laporan Transaksi Vendor</h1>
            <!-- Tombol Cetak -->
            <button onclick="window.print()" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                Cetak Laporan
            </button>
        </div>
        <div class="overflow-x-auto">
            <table class="min-w-full border-collapse border border-gray-300">
                <thead>
                    <tr class="bg-gray-200">
                        <th class="py-2 px-4 border border-gray-300">ID</th>
                        <th class="py-2 px-4 border border-gray-300">Booking Date</th>
                        <th class="py-2 px-4 border border-gray-300">Customer Name</th>
                        <th class="py-2 px-4 border border-gray-300">Start Date</th>
                        <th class="py-2 px-4 border border-gray-300">End Date</th>
                        <th class="py-2 px-4 border border-gray-300">Status</th>
                        <th class="py-2 px-4 border border-gray-300">Pickup Location</th>
                        <th class="py-2 px-4 border border-gray-300">Motor Details</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($transactions as $transaction)
                        <tr>
                            <td class="py-2 px-4 border border-gray-300">{{ $transaction['id'] }}</td>
                            <td class="py-2 px-4 border border-gray-300">
                                {{ \Carbon\Carbon::parse($transaction['booking_date'])->format('Y-m-d H:i:s') }}
                            </td>
                            <td class="py-2 px-4 border border-gray-300">{{ $transaction['customer_name'] }}</td>
                            <td class="py-2 px-4 border border-gray-300">
                                {{ \Carbon\Carbon::parse($transaction['start_date'])->format('Y-m-d H:i:s') }}
                            </td>
                            <td class="py-2 px-4 border border-gray-300">
                                {{ \Carbon\Carbon::parse($transaction['end_date'])->format('Y-m-d H:i:s') }}
                            </td>
                            <td class="py-2 px-4 border border-gray-300">{{ $transaction['status'] }}</td>
                            <td class="py-2 px-4 border border-gray-300">{{ trim($transaction['pickup_location']) }}</td>
                            <td class="py-2 px-4 border border-gray-300">
                                <ul class="list-disc list-inside text-sm">
                                    <li><strong>ID:</strong> {{ $transaction['motor']['id'] }}</li>
                                    <li><strong>Name:</strong> {{ $transaction['motor']['name'] }}</li>
                                    <li><strong>Brand:</strong> {{ $transaction['motor']['brand'] }}</li>
                                    <li><strong>Model:</strong> {{ $transaction['motor']['model'] }}</li>
                                    <li><strong>Year:</strong> {{ $transaction['motor']['year'] }}</li>
                                    <li><strong>Price/Day:</strong>
                                        {{ number_format($transaction['motor']['price_per_day'], 0, ',', '.') }}</li>
                                    <li><strong>Total Price:</strong>
                                        {{ number_format($transaction['motor']['total_price'], 0, ',', '.') }}</li>
                                </ul>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
@endsection
