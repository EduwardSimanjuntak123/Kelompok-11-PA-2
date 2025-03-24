@extends('layouts.app')

@section('title', 'Input Data Transaksi')

@section('content')
<div class="container mx-auto p-8">
    <h2 class="text-4xl font-extrabold text-center text-gray-800 mb-8">🛵 Input Data Transaksi Rental</h2>

    <div class="bg-white shadow-xl rounded-xl p-8 max-w-lg mx-auto border border-gray-200">
        <form action="#" method="POST" class="space-y-5">
            @csrf

            <!-- Nama Pelanggan -->
            <div>
                <label class="block text-gray-700 font-semibold mb-2">Nama Pelanggan</label>
                <input type="text" name="nama_pelanggan"
                       class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none"
                       placeholder="Masukkan nama pelanggan" required>
            </div>

            <!-- Pilih Motor -->
            <div>
                <label class="block text-gray-700 font-semibold mb-2">Motor yang Disewa</label>
                <select name="motor"
                        class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none"
                        required>
                    <option value="" disabled selected>Pilih motor...</option>
                    <option value="Honda Vario 150">Honda Vario 150</option>
                    <option value="Yamaha NMAX">Yamaha NMAX</option>
                    <option value="Suzuki Satria FU">Suzuki Satria FU</option>
                    <option value="Honda Beat Street">Honda Beat Street</option>
                    <option value="Kawasaki Ninja 250">Kawasaki Ninja 250</option>
                </select>
            </div>

            <!-- Lama Rental -->
            <div>
                <label class="block text-gray-700 font-semibold mb-2">Lama Rental (Hari)</label>
                <input type="number" name="lama_rental"
                       class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none"
                       min="1" placeholder="Masukkan lama rental" required>
            </div>

            <!-- Harga Total -->
            <div>
                <label class="block text-gray-700 font-semibold mb-2">Harga Total (Rp)</label>
                <input type="text" name="harga_total"
                       class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none"
                       placeholder="Masukkan harga total" required>
            </div>

            <!-- Metode Pembayaran -->
            <div>
                <label class="block text-gray-700 font-semibold mb-2">Metode Pembayaran</label>
                <select name="metode_pembayaran"
                        class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none"
                        required>
                    <option value="" disabled selected>Pilih metode pembayaran...</option>
                    <option value="Transfer Bank">Transfer Bank</option>
                    <option value="Cash">Cash</option>
                    <option value="E-Wallet">E-Wallet</option>
                </select>
            </div>

            <!-- Tombol Simpan -->
            <button type="submit"
                    class="w-full bg-blue-600 text-white px-6 py-3 rounded-lg shadow-md hover:bg-blue-700 transition duration-200 text-lg font-semibold">
                💾 Simpan Transaksi
            </button>
        </form>
    </div>
</div>
@endsection
