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
                <h3 class="text-lg font-semibold">{{ $transaction['customer_name'] }} - {{ ucfirst($transaction['status']) }}</h3>
                <p class="text-sm text-gray-500">📅 Booking: {{ \Carbon\Carbon::parse($transaction['booking_date'])->format('Y-m-d H:i:s') }}</p>
            </div>
        @endforeach
    @else
        <div class="p-6 bg-yellow-100 text-yellow-800 rounded text-center shadow">
            😕 Tidak ada data transaksi yang tersedia.
        </div>
    @endif
</div>

</div>

<!-- Modal Detail Transaksi -->
<div id="transactionDetailModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center modal z-50">
    <div class="bg-white rounded-lg shadow-lg w-11/12 md:w-2/3 p-6 max-h-[80vh] overflow-y-auto modal-box">
        <h2 class="text-2xl font-bold mb-4">📄 Detail Transaksi</h2>
        <div id="transactionDetailContent" class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-700">
            <!-- Diisi oleh JavaScript -->
        </div>
        <div class="flex justify-end mt-6">
            <button onclick="closeModal('transactionDetailModal')" class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600">
                Tutup
            </button>
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
                    <select name="month" id="month" class="border border-gray-300 rounded px-2 py-1 w-1/2" required>
                        @for ($m = 1; $m <= 12; $m++)
                            <option value="{{ $m }}">{{ \Carbon\Carbon::create()->month($m)->translatedFormat('F') }}</option>
                        @endfor
                    </select>
                    <select name="year" id="year" class="border border-gray-300 rounded px-2 py-1 w-1/2" required>
                        @for ($y = now()->year; $y >= now()->year - 5; $y--)
                            <option value="{{ $y }}">{{ $y }}</option>
                        @endfor
                    </select>
                </div>
            </div>
            <div class="flex justify-end space-x-4">
                <button type="button" onclick="closeModal('printModal')" class="px-4 py-2 bg-gray-500 text-white rounded">
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
        let motorDetails = transaction.motor ? `
            <div class="col-span-2 border-t pt-4">
                <h3 class="text-md font-semibold mb-2">🛵 Motor Details</h3>
                <div class="grid grid-cols-2 gap-4">
                    <div><span class="font-medium">ID:</span> ${transaction.motor.id}</div>
                    <div><span class="font-medium">Name:</span> ${transaction.motor.name}</div>
                    <div><span class="font-medium">Brand:</span> ${transaction.motor.brand}</div>
                    <div><span class="font-medium">Model:</span> ${transaction.motor.model}</div>
                    <div><span class="font-medium">Year:</span> ${transaction.motor.year}</div>
                    <div><span class="font-medium">Price/Day:</span> Rp ${transaction.motor.price_per_day.toLocaleString()}</div>
                </div>
            </div>
        ` : `
            <div class="col-span-2 text-red-500 font-semibold mt-4">⚠️ Motor Details: Data tidak tersedia</div>
        `;

        let content = `
            <div><span class="font-medium">🆔 ID Transaksi:</span> ${transaction.id}</div>
            <div><span class="font-medium">📅 Booking Date:</span> ${new Date(transaction.booking_date).toLocaleString()}</div>
            <div><span class="font-medium">👤 Customer:</span> ${transaction.customer_name}</div>
            <div><span class="font-medium">📍 Pickup Location:</span> ${transaction.pickup_location}</div>
            <div><span class="font-medium">🚀 Start Date:</span> ${new Date(transaction.start_date).toLocaleDateString()}</div>
            <div><span class="font-medium">⏳ End Date:</span> ${new Date(transaction.end_date).toLocaleDateString()}</div>
            <div><span class="font-medium">📌 Status:</span> <span class="capitalize">${transaction.status}</span></div>
            <div><span class="font-medium">💰 Total Price:</span> Rp ${transaction.total_price.toLocaleString()}</div>
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
        from { transform: scale(0.95); opacity: 0; }
        to { transform: scale(1); opacity: 1; }
    }
</style>
@endsection
