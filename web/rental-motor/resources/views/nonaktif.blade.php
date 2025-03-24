@extends('layouts.app')

@section('title', 'Profil Vendor')

@section('content')
<div class="container mx-auto p-8">
    <h2 class="text-4xl font-extrabold text-center text-gray-800 mb-8">🏢 Daftar Vendor Terdaftar</h2>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        @php
            // Data vendor statis (tanpa database)
            $vendors = [
                [
                    'nama' => 'Gaol Rental Motor',
                    'email' => 'gaolrental@email.com',
                    'no_hp' => '081234567890',
                    'alamat' => 'Jl. Sianipar Sihail Hail',
                    'status' => 'Aktif'
                ],
                [
                    'nama' => 'Sipahutar Rental Motor',
                    'email' => 'pahutarmotor@email.com',
                    'no_hp' => '085678901234',
                    'alamat' => 'Jl. Uma Rihit, Gg Makmur',
                    'status' => 'Aktif'
                ],
                [
                    'nama' => 'Makcik Rental',
                    'email' => 'warungsenggol@email.com',
                    'no_hp' => '087712345678',
                    'alamat' => 'Jl. Arjuna, Sitoluama',
                    'status' => 'Aktif'
                ]
            ];
        @endphp

        @foreach ($vendors as $vendor)
        <div class="bg-white shadow-xl rounded-xl p-6 border border-gray-200 transform hover:scale-105 transition duration-300">
            <!-- Gambar Profil -->
            <div class="flex justify-center mb-4">
                <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png" alt="Profil Vendor"
                    class="w-24 h-24 rounded-full border-4 border-gray-300 shadow-md">
            </div>

            <h3 class="text-2xl font-bold text-gray-800">{{ $vendor['nama'] }}</h3>
            <p class="text-gray-500 mt-1">📧 {{ $vendor['email'] }}</p>
            <p class="text-gray-500">📞 {{ $vendor['no_hp'] }}</p>
            <p class="text-gray-500">📍 {{ $vendor['alamat'] }}</p>
            <p class="text-green-600 font-semibold mt-2">🟢 {{ $vendor['status'] }}</p>

            <!-- Tombol Nonaktifkan Vendor -->
            <button onclick="nonaktifkanVendor('{{ $vendor['nama'] }}')"
                class="bg-red-600 text-white px-5 py-2 rounded-lg mt-4 hover:bg-red-700 transition duration-200 font-semibold shadow-md">
                 Nonaktifkan Vendor
            </button>
        </div>
        @endforeach
    </div>
</div>

<script>
    function nonaktifkanVendor(nama) {
        if (confirm("Apakah Anda yakin ingin menonaktifkan " + nama + "?")) {
            alert(nama + " telah dinonaktifkan.");
            // Di sini bisa ditambahkan logika untuk mengupdate status vendor di backend
        }
    }
</script>
@endsection
