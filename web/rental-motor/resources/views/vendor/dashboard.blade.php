@extends('layouts.app')

@section('title', 'Dashboard Vendor Rental')

@section('content')
    <!-- Greeting -->
    <div class="bg-white shadow-xl rounded-2xl p-6 mb-6">
        <h2 class="text-2xl font-extrabold text-gray-800 mb-2">
            Selamat Datang, {{ session('user.vendor.business_name') ?? 'Vendor' }}
        </h2>
        <p class="text-gray-600">ID Vendor Anda: <span class="font-semibold">{{ $id }}</span></p>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <div class="bg-white shadow rounded-xl p-4 text-center">
            <p class="text-sm text-gray-500">Motor Aktif</p>
            <h3 class="text-2xl font-bold text-indigo-600">{{ $jumlah_motor ?? 0 }}</h3>
        </div>
        <div class="bg-white shadow rounded-xl p-4 text-center">
            <p class="text-sm text-gray-500">Pesanan Bulan Ini</p>
            <h3 class="text-2xl font-bold text-green-600">{{ $pesanan_bulan_ini ?? 0 }}</h3>
        </div>
        <div class="bg-white shadow rounded-xl p-4 text-center">
            <p class="text-sm text-gray-500">Pendapatan</p>
            <h3 class="text-2xl font-bold text-yellow-600">Rp{{ number_format($pendapatan ?? 0, 0, ',', '.') }}</h3>
        </div>
        <div class="bg-white shadow rounded-xl p-4 text-center">
            <p class="text-sm text-gray-500">Rating Rata-Rata</p>
            <h3 class="text-2xl font-bold text-purple-600">{{ $rating ?? '-' }}/5</h3>
        </div>
    </div>

    <!-- Banner / Notification -->
    <div class="bg-gradient-to-r from-indigo-500 to-purple-500 text-white p-6 rounded-2xl shadow-lg">
        <h3 class="text-xl font-bold mb-2">Apa yang bisa kami bantu hari ini?</h3>
        <p class="text-sm text-white/80">
            Gunakan menu navigasi di atas untuk mengelola motor, memproses pesanan, memantau ulasan pelanggan, dan melihat riwayat transaksi Anda.
        </p>
    </div>
@endsection
