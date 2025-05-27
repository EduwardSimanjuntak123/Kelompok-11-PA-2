@extends('layouts.app')

@section('title', 'Cetak Laporan Transaksi Vendor')

@section('content')
    <div class="container mx-auto px-3 sm:px-4 py-4 sm:py-6 lg:py-8">
        <!-- Header Section -->
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-4 sm:mb-6 gap-3 sm:gap-4">
            <div class="w-full sm:w-auto">
                <h1 class="text-lg sm:text-xl md:text-2xl lg:text-3xl font-bold text-gray-800 leading-tight">
                    Laporan Transaksi
                    <span class="block sm:inline mt-1 sm:mt-0">
                        {{ \Carbon\Carbon::create()->month(request('month'))->format('F') }}
                        {{ request('year') }}
                    </span>
                </h1>
            </div>
            <button onclick="window.print()" 
                class="w-full sm:w-auto px-3 sm:px-4 py-2 bg-blue-600 text-white text-sm sm:text-base rounded hover:bg-blue-700 transition-colors print:hidden flex items-center justify-center">
                <i class="fas fa-print mr-2"></i>Cetak
            </button>
        </div>

        <!-- Desktop Table View -->
        <div class="hidden lg:block overflow-x-auto">
            <table class="min-w-full border-collapse border border-gray-300 bg-white shadow-sm">
                <thead class="bg-gray-200">
                    <tr>
                        <th class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-left font-semibold text-gray-700 text-xs sm:text-sm">ID</th>
                        <th class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-left font-semibold text-gray-700 text-xs sm:text-sm">Tanggal Booking</th>
                        <th class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-left font-semibold text-gray-700 text-xs sm:text-sm">Customer</th>
                        <th class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-left font-semibold text-gray-700 text-xs sm:text-sm">Mulai</th>
                        <th class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-left font-semibold text-gray-700 text-xs sm:text-sm">Selesai</th>
                        <th class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-left font-semibold text-gray-700 text-xs sm:text-sm">Status</th>
                        <th class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-left font-semibold text-gray-700 text-xs sm:text-sm">Lokasi Jemput</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($transactions as $t)
                        <tr class="hover:bg-gray-50">
                            <td class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-xs sm:text-sm">{{ $t->id }}</td>
                            <td class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-xs sm:text-sm">
                                {{ $t->booking_date->format('Y-m-d H:i') }}
                            </td>
                            <td class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-xs sm:text-sm">{{ $t->customer_name }}</td>
                            <td class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-xs sm:text-sm">
                                {{ $t->start_date->format('Y-m-d') }}
                            </td>
                            <td class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300 text-xs sm:text-sm">
                                {{ $t->end_date->format('Y-m-d') }}
                            </td>
                            <td class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300">
                                <span class="px-2 py-1 text-xs font-medium rounded-full
                                    @if(strtolower($t->status) == 'completed') bg-green-100 text-green-800
                                    @elseif(strtolower($t->status) == 'pending') bg-yellow-100 text-yellow-800
                                    @elseif(strtolower($t->status) == 'confirmed') bg-blue-100 text-blue-800
                                    @elseif(strtolower($t->status) == 'rejected') bg-red-100 text-red-800
                                    @else bg-gray-100 text-gray-800
                                    @endif">
                                    {{ ucfirst($t->status) }}
                                </span>
                            </td>
                            <td class="py-2 sm:py-3 px-2 sm:px-4 border border-gray-300">
                                <div class="max-w-xs truncate text-xs sm:text-sm" title="{{ $t->pickup_location }}">
                                    {{ $t->pickup_location }}
                                </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <!-- Mobile Card View -->
        <div class="lg:hidden space-y-3 sm:space-y-4">
            @foreach ($transactions as $t)
                <div class="bg-white rounded-lg shadow-md border border-gray-200 p-3 sm:p-4">
                    <!-- Header -->
                    <div class="flex justify-between items-start mb-2 sm:mb-3">
                        <div class="flex-1 min-w-0">
                            <h3 class="font-semibold text-gray-800 text-sm sm:text-base truncate">{{ $t->customer_name }}</h3>
                            <p class="text-xs sm:text-sm text-gray-500">ID: {{ $t->id }}</p>
                        </div>
                        <span class="px-2 py-1 text-xs font-medium rounded-full ml-2 flex-shrink-0
                            @if(strtolower($t->status) == 'completed') bg-green-100 text-green-800
                            @elseif(strtolower($t->status) == 'pending') bg-yellow-100 text-yellow-800
                            @elseif(strtolower($t->status) == 'confirmed') bg-blue-100 text-blue-800
                            @elseif(strtolower($t->status) == 'rejected') bg-red-100 text-red-800
                            @else bg-gray-100 text-gray-800
                            @endif">
                            {{ ucfirst($t->status) }}
                        </span>
                    </div>

                    <!-- Details Grid -->
                    <div class="space-y-2 text-xs sm:text-sm">
                        <div class="grid grid-cols-1 gap-2">
                            <div>
                                <span class="font-medium text-gray-600">Tanggal Booking:</span>
                                <p class="text-gray-800">{{ $t->booking_date->format('d/m/Y H:i') }}</p>
                            </div>
                            <div>
                                <span class="font-medium text-gray-600">Periode Sewa:</span>
                                <p class="text-gray-800">
                                    {{ $t->start_date->format('d/m/Y') }} - {{ $t->end_date->format('d/m/Y') }}
                                </p>
                            </div>
                            <div>
                                <span class="font-medium text-gray-600">Lokasi Jemput:</span>
                                <p class="text-gray-800 break-words">{{ $t->pickup_location }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>

        <!-- Empty State -->
        @if($transactions->isEmpty())
            <div class="flex flex-col items-center justify-center text-center p-6 sm:p-8 lg:p-12 bg-white rounded-lg shadow-md">
                <i class="fas fa-file-alt fa-2x sm:fa-3x text-gray-400 mb-4"></i>
                <h2 class="text-lg sm:text-xl lg:text-2xl font-semibold text-gray-700">Tidak Ada Transaksi</h2>
                <p class="text-gray-600 mt-2 text-sm sm:text-base">Belum ada transaksi untuk periode yang dipilih.</p>
            </div>
        @endif
    </div>

    <!-- Print Styles -->
    <style>
        @media print {
            .print\:hidden {
                display: none !important;
            }
            
            body {
                font-size: 10px;
            }
            
            .container {
                max-width: none;
                padding: 0;
            }
            
            table {
                page-break-inside: auto;
                font-size: 10px;
            }
            
            tr {
                page-break-inside: avoid;
                page-break-after: auto;
            }
            
            .lg\:hidden {
                display: none !important;
            }
            
            .hidden {
                display: block !important;
            }
        }
        
        @media (max-width: 640px) {
            .container {
                padding-left: 0.75rem;
                padding-right: 0.75rem;
            }
        }
    </style>
@endsection