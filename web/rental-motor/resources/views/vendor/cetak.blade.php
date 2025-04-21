@extends('layouts.app')

@section('title', 'Cetak Laporan Transaksi Vendor')

@section('content')
    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Laporan Transaksi
                {{ \Carbon\Carbon::create()->month(request('month'))->format('F') }}
                {{ request('year') }}</h1>
            <button onclick="window.print()" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                Cetak
            </button>
        </div>
        <div class="overflow-x-auto">
            <table class="min-w-full border-collapse border border-gray-300">
                <thead class="bg-gray-200">
                    <tr>
                        {{-- Kolom sesuai kebutuhan --}}
                        <th class="py-2 px-4 border">ID</th>
                        <th class="py-2 px-4 border">Tanggal Booking</th>
                        <th class="py-2 px-4 border">Customer</th>
                        <th class="py-2 px-4 border">Mulai</th>
                        <th class="py-2 px-4 border">Selesai</th>
                        <th class="py-2 px-4 border">Status</th>
                        <th class="py-2 px-4 border">Lokasi Jemput</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($transactions as $t)
                        <tr>
                            <td class="py-2 px-4 border">{{ $t->id }}</td>
                            <td class="py-2 px-4 border">
                                {{ $t->booking_date->format('Y-m-d H:i') }}
                            </td>
                            <td class="py-2 px-4 border">{{ $t->customer_name }}</td>
                            <td class="py-2 px-4 border">
                                {{ $t->start_date->format('Y-m-d') }}
                            </td>
                            <td class="py-2 px-4 border">
                                {{ $t->end_date->format('Y-m-d') }}
                            </td>
                            <td class="py-2 px-4 border">{{ ucfirst($t->status) }}</td>
                            <td class="py-2 px-4 border">{{ $t->pickup_location }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
@endsection
