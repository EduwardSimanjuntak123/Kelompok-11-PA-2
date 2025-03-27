@extends('layouts.app')

@section('title', 'Transaksi Vendor Rental')

@section('content')
    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Data Transaksi Vendor</h1>
            <div class="flex space-x-4">
                <!-- Tombol + Transaksi Manual -->
                <button onclick="openModal('addTransactionModal')"
                    class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
                    + Transaksi Manual
                </button>
                <!-- Tombol Cetak Laporan -->
                <button onclick="openModal('printModal')" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                    Cetak Laporan
                </button>
            </div>
        </div>
        <!-- Tabel Transaksi -->
        
            
            <!-- Daftar Transaksi -->
            <div class="space-y-4">
                @foreach ($transactions as $transaction)
                    <div class="p-4 bg-white shadow rounded cursor-pointer" onclick="showTransactionDetails({{ json_encode($transaction) }})">
                        <h3 class="text-lg font-semibold">{{ $transaction['customer_name'] }} - {{ $transaction['status'] }}</h3>
                        <p class="text-sm text-gray-500">Booking: {{ \Carbon\Carbon::parse($transaction['booking_date'])->format('Y-m-d H:i:s') }}</p>
                    </div>
                @endforeach
            </div>
        </div>
    
        <!-- Modal Detail Transaksi -->
        <div id="transactionDetailModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center">
            <div class="bg-white rounded-lg shadow-lg w-1/2 p-6">
                <h2 class="text-2xl font-bold mb-4">Detail Transaksi</h2>
                <div id="transactionDetailContent"></div>
                <div class="flex justify-end mt-4">
                    <button onclick="closeModal('transactionDetailModal')" class="px-4 py-2 bg-gray-500 text-white rounded">
                        Tutup
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Add Transaksi Manual -->
    <div id="addTransactionModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-lg w-1/2 p-6">
            <h2 class="text-2xl font-bold mb-4">Tambah Transaksi Manual</h2>
            <form action="{{ route('vendor.transaksi.store') }}" method="POST" enctype="multipart/form-data">
                @csrf
                <!-- Dropdown Motor: hanya motor yang dimiliki vendor -->
                <div class="mb-4">
                    <label for="motor_id" class="block text-gray-700 font-semibold">Pilih Motor</label>
                    <select name="motor_id" id="motor_id" class="w-full p-2 border rounded" required>
                        <option value="">-- Pilih Motor --</option>
                        @foreach ($motors as $motor)
                            <option value="{{ $motor['id'] }}">
                                {{ $motor['name'] }} ({{ $motor['brand'] }})
                            </option>
                        @endforeach
                    </select>
                </div>
                <!-- Start Date menggunakan datetime-local -->
                <div class="mb-4">
                    <label for="start_date" class="block text-gray-700 font-semibold">Start Date</label>
                    <input type="datetime-local" name="start_date" id="start_date" class="w-full p-2 border rounded"
                        required>
                </div>
                <!-- End Date menggunakan datetime-local -->
                <div class="mb-4">
                    <label for="end_date" class="block text-gray-700 font-semibold">End Date</label>
                    <input type="datetime-local" name="end_date" id="end_date" class="w-full p-2 border rounded" required>
                </div>
                <!-- Pickup Location -->
                <div class="mb-4">
                    <label for="pickup_location" class="block text-gray-700 font-semibold">Pickup Location</label>
                    <textarea name="pickup_location" id="pickup_location" class="w-full p-2 border rounded" required></textarea>
                </div>
                <!-- Foto ID (opsional) -->
                <div class="mb-4">
                    <label for="photo_id" class="block text-gray-700 font-semibold">Foto ID (Opsional)</label>
                    <input type="file" name="photo_id" id="photo_id" class="w-full p-2 border rounded">
                </div>
                <!-- Foto KTP (opsional) -->
                <div class="mb-4">
                    <label for="ktp_id" class="block text-gray-700 font-semibold">Foto KTP (Opsional)</label>
                    <input type="file" name="ktp_id" id="ktp_id" class="w-full p-2 border rounded">
                </div>
                <div class="flex justify-end space-x-4">
                    <button type="button" onclick="closeModal('addTransactionModal')"
                        class="px-4 py-2 bg-gray-500 text-white rounded">
                        Batal
                    </button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded">
                        Simpan
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Cetak Laporan -->
    <div id="printModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-lg w-1/3 p-6">
            <h2 class="text-2xl font-bold mb-4">Cetak Laporan Transaksi</h2>
            <form action="{{ route('vendor.transactions.export') }}" method="GET">
                <div class="mb-4">
                    <label class="block text-gray-700 font-semibold mb-2">Pilih Rentang Laporan</label>
                    <div class="flex items-center space-x-4">
                        <label class="inline-flex items-center">
                            <input type="radio" class="form-radio" name="range" value="week" required>
                            <span class="ml-2">Seminggu</span>
                        </label>
                        <label class="inline-flex items-center">
                            <input type="radio" class="form-radio" name="range" value="month" required>
                            <span class="ml-2">Sebulan</span>
                        </label>
                    </div>
                </div>
                <div class="flex justify-end space-x-4">
                    <button type="button" onclick="closeModal('printModal')"
                        class="px-4 py-2 bg-gray-500 text-white rounded">
                        Batal
                    </button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded">
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
            let motorDetails = transaction.motor
                ? `
                    <p><strong>Motor Details:</strong></p>
                    <ul>
                        <li><strong>ID:</strong> ${transaction.motor.id}</li>
                        <li><strong>Name:</strong> ${transaction.motor.name}</li>
                        <li><strong>Brand:</strong> ${transaction.motor.brand}</li>
                        <li><strong>Model:</strong> ${transaction.motor.model}</li>
                        <li><strong>Year:</strong> ${transaction.motor.year}</li>
                        <li><strong>Price/Day:</strong> ${transaction.motor.price_per_day.toLocaleString()}</li>
                        <li><strong>Total Price:</strong> ${transaction.motor.total_price.toLocaleString()}</li>
                    </ul>
                ` : `<p><strong>Motor Details:</strong> Data tidak tersedia</p>`;
    
            let content = `
                <p><strong>ID:</strong> ${transaction.id}</p>
                <p><strong>Booking Date:</strong> ${transaction.booking_date}</p>
                <p><strong>Customer Name:</strong> ${transaction.customer_name}</p>
                <p><strong>Start Date:</strong> ${transaction.start_date}</p>
                <p><strong>End Date:</strong> ${transaction.end_date}</p>
                <p><strong>Status:</strong> ${transaction.status}</p>
                <p><strong>Pickup Location:</strong> ${transaction.pickup_location}</p>
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
    </style>
    
@endsection
