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
        <div class="overflow-x-auto">
            <table class="min-w-full border-collapse border border-gray-200">
                <thead>
                    <tr class="bg-gray-100">
                        <th class="py-2 px-4 border border-gray-200">ID</th>
                        <th class="py-2 px-4 border border-gray-200">Booking Date</th>
                        <th class="py-2 px-4 border border-gray-200">Customer Name</th>
                        <th class="py-2 px-4 border border-gray-200">Start Date</th>
                        <th class="py-2 px-4 border border-gray-200">End Date</th>
                        <th class="py-2 px-4 border border-gray-200">Status</th>
                        <th class="py-2 px-4 border border-gray-200">Pickup Location</th>
                        <th class="py-2 px-4 border border-gray-200">Motor Details</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($transactions as $transaction)
                        <tr>
                            <td class="py-2 px-4 border border-gray-200">{{ $transaction['id'] }}</td>
                            <td class="py-2 px-4 border border-gray-200">
                                {{ \Carbon\Carbon::parse($transaction['booking_date'])->format('Y-m-d H:i:s') }}
                            </td>
                            <td class="py-2 px-4 border border-gray-200">{{ $transaction['customer_name'] }}</td>
                            <td class="py-2 px-4 border border-gray-200">
                                {{ \Carbon\Carbon::parse($transaction['start_date'])->format('Y-m-d H:i:s') }}
                            </td>
                            <td class="py-2 px-4 border border-gray-200">
                                {{ \Carbon\Carbon::parse($transaction['end_date'])->format('Y-m-d H:i:s') }}
                            </td>
                            <td class="py-2 px-4 border border-gray-200">{{ $transaction['status'] }}</td>
                            <td class="py-2 px-4 border border-gray-200">{{ trim($transaction['pickup_location']) }}</td>
                            <td class="py-2 px-4 border border-gray-200">
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
            document.getElementById(modalId).classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.add('hidden');
            document.body.style.overflow = '';
        }
    </script>
@endsection
