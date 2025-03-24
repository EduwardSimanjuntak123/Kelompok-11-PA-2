@extends('layouts.app')

@section('title', 'Dashboard Vendor Rental')

@section('content')

    <div class="bg-white shadow-lg rounded-lg p-6 mb-4">
        <h2 class="text-xl font-bold mb-4">
            Dashboard Vendor Motor: {{ session('user.vendor.business_name') ?? 'Tidak tersedia' }}
        </h2>
        <p>Selamat datang, Vendor dengan ID: {{ $id }}</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <!-- Kelola Harga & Ketersediaan Motor -->
        <div class="bg-green-100 p-4 rounded-lg shadow-md">
            <h3 class="font-semibold mb-2">Kelola Harga & Ketersediaan Motor</h3>
            <a href="{{ route('vendor.motor', ['id' => $id]) }}" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 block text-center">
                Atur Harga
            </a>
        </div>

        <!-- Melihat Ulasan -->
        <div class="bg-blue-100 p-4 rounded-lg shadow-md">
            <h3 class="font-semibold mb-2">Ulasan Pelanggan</h3>
            <a href="{{ route('ulasan') }}" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 block text-center">
                Lihat & Tanggapi Ulasan
            </a>
        </div>

        <!-- Menyetujui/Tolak Pesanan -->
        <div class="bg-yellow-100 p-4 rounded-lg shadow-md">
            <h3 class="font-semibold mb-2">Kelola Pemesanan</h3>
            {{-- {{ dd(session()) }} --}}
            <a href="{{ route('vendor.kelola', ['id' => session('user.id')]) }}" class="bg-yellow-600 text-white px-4 py-2 rounded hover:bg-yellow-700 block text-center">
                Setujui/Tolak Pesanan
            </a>
        </div>

        <!-- Input Data Transaksi -->
        <div class="bg-purple-100 p-4 rounded-lg shadow-md">
            <h3 class="font-semibold mb-2">Input Data Transaksi</h3>
            <a href="{{ route('input') }}" class="bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700 block text-center">
                Input Data
            </a>
        </div>

        <!-- Cetak Data Transaksi -->
        <div class="bg-gray-100 p-4 rounded-lg shadow-md">
            <h3 class="font-semibold mb-2">Cetak Data Transaksi</h3>
            <a href="{{ route('cetak') }}" class="bg-gray-600 text-white px-4 py-2 rounded hover:bg-gray-700 block text-center">
                Cetak Transaksi
            </a>
        </div>
    </div>

@endsection
