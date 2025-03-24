@extends('layouts.app')

@section('title', 'Cetak Data Transaksi')

@section('content')
<div class="container mx-auto p-8">
    <h2 class="text-4xl font-extrabold text-center text-gray-800 mb-8">📜 Catatan Transaksi Rental</h2>

    <div class="bg-white shadow-xl rounded-xl p-8 border border-gray-200">
        @php
            // Data transaksi statis (tanpa database)
            $transaksi = [
                [
                    'nama_pelanggan' => 'Budi Santoso',
                    'motor' => 'Honda Vario 150',
                    'lama_rental' => '3 Hari',
                    'harga_total' => 'Rp 150.000',
                    'metode_pembayaran' => 'Transfer Bank',
                    'tanggal' => '2024-03-06'
                ],
                [
                    'nama_pelanggan' => 'Ani Wijaya',
                    'motor' => 'Yamaha NMAX',
                    'lama_rental' => '5 Hari',
                    'harga_total' => 'Rp 300.000',
                    'metode_pembayaran' => 'Cash',
                    'tanggal' => '2024-03-05'
                ],
                [
                    'nama_pelanggan' => 'Joko Susilo',
                    'motor' => 'Suzuki Satria FU',
                    'lama_rental' => '2 Hari',
                    'harga_total' => 'Rp 100.000',
                    'metode_pembayaran' => 'E-Wallet',
                    'tanggal' => '2024-03-04'
                ]
            ];
        @endphp

        <div class="overflow-x-auto">
            <table class="w-full border-collapse rounded-lg shadow-lg overflow-hidden">
                <thead>
                    <tr class="bg-blue-600 text-white text-center">
                        <th class="px-6 py-3">No</th>
                        <th class="px-6 py-3">Nama Pelanggan</th>
                        <th class="px-6 py-3">Motor</th>
                        <th class="px-6 py-3">Lama Rental</th>
                        <th class="px-6 py-3">Harga Total</th>
                        <th class="px-6 py-3">Metode Pembayaran</th>
                        <th class="px-6 py-3">Tanggal</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    @foreach ($transaksi as $index => $data)
                        <tr class="text-center hover:bg-gray-100 transition">
                            <td class="px-6 py-4">{{ $index + 1 }}</td>
                            <td class="px-6 py-4">{{ $data['nama_pelanggan'] }}</td>
                            <td class="px-6 py-4">{{ $data['motor'] }}</td>
                            <td class="px-6 py-4">{{ $data['lama_rental'] }}</td>
                            <td class="px-6 py-4 font-bold text-green-600">{{ $data['harga_total'] }}</td>
                            <td class="px-6 py-4">{{ $data['metode_pembayaran'] }}</td>
                            <td class="px-6 py-4">{{ $data['tanggal'] }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <!-- Tombol Cetak -->
        <div class="mt-6 text-center">
            <button onclick="window.print()"
                    class="bg-blue-600 text-white px-6 py-3 rounded-lg shadow-md hover:bg-blue-700 transition duration-200 text-lg font-semibold">
                🖨 Cetak Transaksi
            </button>
        </div>
    </div>
</div>
@endsection
