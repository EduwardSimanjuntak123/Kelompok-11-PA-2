@extends('layouts.app')

@section('title', 'Transaksi Vendor Rental')

@section('content')

    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Data Transaksi Vendor</h1>
            <div class="flex space-x-4">
                <!-- Tombol Cetak Laporan -->
                <button onclick="openModal('printModal')" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                    Cetak Laporan
                </button>
            </div>
        </div>
        @if (session('error'))
            <div class="mb-4 p-4 bg-red-100 border border-red-300 text-red-700 rounded">
                {{ session('error') }}
            </div>
        @endif
        <!-- Daftar Transaksi -->
        <div class="space-y-4">
            {{-- @dd($transactions); --}}
            @if (!empty($transactions) && count($transactions) > 0)
                @foreach ($transactions as $transaction)
                    <div class="p-4 bg-white shadow rounded cursor-pointer hover:bg-gray-100 transition"
                        onclick="showTransactionDetails({{ json_encode($transaction) }})">
                        <h3 class="text-lg font-semibold">{{ $transaction['customer_name'] }} -
                            {{ ucfirst($transaction['status']) }}</h3>
                        <p class="text-sm text-gray-500">📅 Booking:
                            {{ \Carbon\Carbon::parse($transaction['booking_date'])->format('Y-m-d H:i:s') }}</p>
                    </div>
                @endforeach
            @else
                <div class="p-6 bg-yellow-100 text-yellow-800 rounded text-center shadow">
                    😕 Tidak ada data transaksi yang tersedia.
                </div>
            @endif
        </div>

    </div>

    <!-- Modal content -->
    <div id="transactionDetailModal"
        class="fixed inset-0 z-50 hidden bg-black bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-2xl shadow-xl w-full max-w-3xl p-6 relative">
            <!-- Close button -->
            <button onclick="closeModal('transactionDetailModal')"
                class="absolute top-4 right-4 text-gray-500 hover:text-red-500">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>

            <!-- Modal body -->
            <h2 class="text-xl font-bold mb-4 flex items-center gap-2">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" stroke-width="2"
                    viewBox="0 0 24 24">
                    <path d="M5 13l4 4L19 7" />
                </svg>
                Transaction Details
            </h2>

            <div id="transactionDetailContent" class="grid grid-cols-2 gap-4 text-sm text-gray-700">
                <!-- Content will be injected here -->
            </div>
        </div>
    </div>


    <!-- Modal Cetak Laporan -->
    <div id="printModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center modal z-50">
        <div class="bg-white rounded-lg shadow-lg w-11/12 md:w-1/3 p-6 modal-box">
            <h2 class="text-2xl font-bold mb-4">🖨️ Cetak Laporan Transaksi Bulanan</h2>
            <form action="{{ route('vendor.transactions.export') }}" method="GET">
                <div class="mb-4">
                    <label for="month" class="block text-gray-700 font-semibold mb-2">Pilih Bulan & Tahun</label>
                    <div class="flex space-x-4">
                        <select name="month" id="month" class="border border-gray-300 rounded px-2 py-1 w-1/2"
                            required>
                            @for ($m = 1; $m <= 12; $m++)
                                <option value="{{ $m }}">
                                    {{ \Carbon\Carbon::create()->month($m)->translatedFormat('F') }}</option>
                            @endfor
                        </select>
                        <select name="year" id="year" class="border border-gray-300 rounded px-2 py-1 w-1/2"
                            required>
                            @for ($y = now()->year; $y >= now()->year - 5; $y--)
                                <option value="{{ $y }}">{{ $y }}</option>
                            @endfor
                        </select>
                    </div>
                </div>
                <div class="flex justify-end space-x-4">
                    <button type="button" onclick="closeModal('printModal')"
                        class="px-4 py-2 bg-gray-500 text-white rounded">
                        Batal
                    </button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
                        Export Excel
                    </button>
                </div>
            </form>
        </div>
    </div>



    <script>
        function openModal(modalId) {
            let modal = document.getElementById(modalId);
            modal.classList.remove('hidden');
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeModal(modalId) {
            let modal = document.getElementById(modalId);
            modal.classList.remove('active');
            modal.classList.add('hidden');
            document.body.style.overflow = '';
        }

        function showTransactionDetails(transaction) {
            const statusColor = {
                completed: "bg-green-100 text-green-700",
                pending: "bg-yellow-100 text-yellow-700",
                cancelled: "bg-red-100 text-red-700",
                ongoing: "bg-blue-100 text-blue-700"
            };

            const statusClass = statusColor[transaction.status?.toLowerCase()] || "bg-gray-100 text-gray-700";

            let motorDetails = transaction.motor ? `
    <div class="border-t pt-4">
        <h3 class="text-md font-semibold mb-3 flex items-center gap-2">
            <svg class="w-5 h-5 text-indigo-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M13 4h-1l-1 2H6v2h1l1 2H6v2h1l1 2H6v2h7l1 2h1l1-2h3v-2h-1l-1-2h1v-2h-1l-1-2h1V6h-4l-1-2z" />
            </svg>
            Informasi Motor
        </h3>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-y-2 gap-x-8">
            <div><span class="text-gray-500">Nama</span><br><span class="font-semibold">${transaction.motor.name}</span></div>
            <div><span class="text-gray-500">Merek</span><br><span class="font-semibold">${transaction.motor.brand}</span></div>
            <div><span class="text-gray-500">Model</span><br><span class="font-semibold">${transaction.motor.model}</span></div>
            <div><span class="text-gray-500">Tahun</span><br><span class="font-semibold">${transaction.motor.year}</span></div>
            <div><span class="text-gray-500">Harga / Hari</span><br><span class="font-semibold">Rp ${transaction.motor.price_per_day.toLocaleString()}</span></div>
        </div>
    </div>
` : `...`;

            let content = `
    <div>
        <h3 class="text-md font-semibold mb-3 flex items-center gap-2">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M9 17v-6a2 2 0 0 1 2-2h2m4 0h-4m0 0V7a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v4" />
            </svg>
            Detail Transaksi
        </h3>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-y-2 gap-x-8">
            <div><span class="text-gray-500">Tanggal Booking</span><br><span class="font-semibold">${new Date(transaction.booking_date).toLocaleString()}</span></div>
            <div><span class="text-gray-500">Nama Customer</span><br><span class="font-semibold">${transaction.customer_name}</span></div>
            <div><span class="text-gray-500">Lokasi Jemput</span><br><span class="font-semibold">${transaction.pickup_location}</span></div>
            <div><span class="text-gray-500">Tanggal Mulai</span><br><span class="font-semibold">${new Date(transaction.start_date).toLocaleDateString()}</span></div>
            <div><span class="text-gray-500">Tanggal Selesai</span><br><span class="font-semibold">${new Date(transaction.end_date).toLocaleDateString()}</span></div>
            <div><span class="text-gray-500">Status</span><br>
                <span class="inline-block px-3 py-1 text-xs rounded-full font-semibold ${statusClass}">
                    ${transaction.status}
                </span>
            </div>
            <div><span class="text-gray-500">Total Harga</span><br><span class="font-semibold">Rp ${transaction.total_price.toLocaleString()}</span></div>
        </div>
    </div>
    ${motorDetails}
`;


            document.getElementById('transactionDetailContent').innerHTML = content;
            openModal('transactionDetailModal');
        }
    </script>

    <style>
        .modal {
            display: none !important;
        }

        .modal.active {
            display: flex !important;
        }

        .modal-box {
            animation: fadeIn 0.3s ease-in-out;
        }

        @keyframes fadeIn {
            from {
                transform: scale(0.95);
                opacity: 0;
            }

            to {
                transform: scale(1);
                opacity: 1;
            }
        }
    </style>
@endsection
