@extends('layouts.app') <!-- Pastikan file layout ada -->

@section('title', 'Atur Harga Rental')

@section('content')
<div class="bg-white shadow-lg rounded-lg p-6">
    <h2 class="text-2xl font-bold text-gray-800 mb-4">Atur Harga Rental</h2>
    <p class="text-gray-600">Silakan atur harga rental sesuai kebutuhan.</p>
</div>

<div class="container mx-auto p-6">
    <h2 class="text-3xl font-bold text-center text-gray-800 mb-8">Atur Harga Motor</h2>

    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-3 gap-6">
        @for ($i = 0; $i < 6; $i++)
            <div class="bg-white shadow-xl rounded-lg overflow-hidden p-5 transform transition duration-300 hover:scale-105">
                <!-- Gambar Motor -->
                <div class="flex justify-center">
                    <img src="{{ asset('motor.jpg') }}" alt="Nama Motor" class="w-40 h-32 object-cover rounded-md shadow-md hover:shadow-lg transition">
                </div>

                <!-- Nama Motor -->
                <h3 class="text-lg font-semibold mt-4 text-center text-gray-800">Nama Motor {{ $i+1 }}</h3>

                <!-- Harga Motor -->
                <p class="text-gray-700 text-center mt-2">Harga: <span class="font-bold text-blue-600">Rp 100.000</span> / hari</p>

                <!-- Input Harga Baru -->
                <div class="mt-4">
                    <label class="block text-sm font-medium text-gray-700">Atur Harga Baru (Rp)</label>
                    <input
                        type="number"
                        name="harga_baru"
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent"
                        placeholder="Masukkan harga baru"
                        min="10000"
                        step="1000"
                        required
                    >
                </div>


                <!-- Tombol Simpan -->
                <button class="mt-4 w-full bg-gradient-to-r from-green-500 to-green-600 text-white px-4 py-2 rounded-lg shadow-md hover:shadow-lg hover:from-green-600 hover:to-green-700 transition">
                    Simpan Harga
                </button>
            </div>
        @endfor
    </div>
</div>
@endsection
