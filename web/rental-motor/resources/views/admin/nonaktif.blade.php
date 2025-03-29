@extends('layouts.app')

@section('title', 'Daftar Vendor Terdaftar')

@section('content')
    <div class="container mx-auto p-8">
        <h2 class="text-4xl font-extrabold text-center text-gray-800 mb-8">Daftar Vendor Terdaftar</h2>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            @foreach ($vendors as $vendor)
                <div
                    class="bg-white shadow-xl rounded-xl p-6 border border-gray-200 transform hover:scale-105 transition duration-300">
                    <!-- Gambar Profil -->
                    <div class="flex justify-center mb-4">
                        <img src="{{ $vendor['profile_image'] }}" alt="Profil Vendor"
                            class="w-24 h-24 rounded-full border-4 border-gray-300 shadow-md object-cover">
                    </div>
                    <h3 class="text-2xl font-bold text-gray-800">{{ $vendor['name'] ?: 'Vendor Tanpa Nama' }}</h3>
                    <p class="text-gray-500 mt-1">📧 {{ $vendor['email'] }}</p>
                    <p class="text-gray-500">📞 {{ $vendor['phone'] }}</p>
                    <p class="text-gray-500">📍 {{ $vendor['address'] }}</p>

                    <!-- Status Vendor dengan warna dinamis -->
                    @php
                        $statusText = $vendor['status'] == 'active' ? '🟢 Aktif' : '🔴 Tidak Aktif';
                        $statusColor = $vendor['status'] == 'active' ? 'text-green-600' : 'text-red-600';
                    @endphp
                    <p class="font-semibold mt-2 {{ $statusColor }}">
                        {{ $statusText }}
                    </p>

                    <p class="text-gray-700 mt-2">
                        <strong>Jumlah Motor:</strong> {{ $vendor['motor_count'] ?? 0 }}
                    </p>
                    <p class="text-gray-700">
                        <strong>Jumlah Transaksi:</strong> {{ $vendor['transaction_count'] ?? 0 }}
                    </p>

                    <!-- Tombol Nonaktifkan Vendor dengan alert konfirmasi -->
                    @if ($vendor['status'] == 'active')
                        <form action="{{ route('vendor.deactivate', $vendor['id']) }}" method="POST"
                            onsubmit="return confirmNonaktif('{{ $vendor['name'] ?: 'Vendor' }}');" class="mt-4">
                            @csrf
                            <button type="submit"
                                class="bg-red-600 text-white px-5 py-2 rounded-lg hover:bg-red-700 transition duration-200 font-semibold shadow-md">
                                Nonaktifkan Vendor
                            </button>
                        </form>
                    @endif
                    @if ($vendor['status'] == 'inactive')
                        <form action="{{ route('vendor.activate', $vendor['id']) }}" method="POST"
                            onsubmit="return confirmAktifkan('{{ $vendor['name'] }}');">
                            @csrf
                            @method('PUT')
                            <button type="submit"
                                class="bg-green-600 text-white px-5 py-2 rounded-lg hover:bg-green-700 transition duration-200 font-semibold shadow-md">
                                Aktifkan Vendor
                            </button>
                        </form>
                    @endif
                </div>
            @endforeach
        </div>
    </div>

    <script>
        function confirmNonaktif(nama) {
            return confirm("Apakah Anda yakin ingin menonaktifkan " + nama + "?");
        }

        function confirmAktifkan(nama) {
            return confirm("Apakah Anda yakin ingin mengaktifkan kembali " + nama + "?");
        }
    </script>

@endsection
