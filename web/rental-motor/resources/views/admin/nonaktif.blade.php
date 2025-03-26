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
                    <h3 class="text-2xl font-bold text-gray-800">
                        {{ $vendor['name'] ?: 'Vendor Tanpa Nama' }}
                    </h3>
                    <p class="text-gray-500 mt-1">📧 {{ $vendor['email'] }}</p>
                    <p class="text-gray-500">📞 {{ $vendor['phone'] }}</p>
                    <p class="text-gray-500">📍 {{ $vendor['address'] }}</p>
                    <p class="text-green-600 font-semibold mt-2">
                        🟢 {{ $vendor['status'] ?: 'Aktif' }}
                    </p>
                    <p class="text-gray-700 mt-2">
                        <strong>Jumlah Motor:</strong> {{ $vendor['motor_count'] ?? 0 }}
                    </p>
                    <p class="text-gray-700">
                        <strong>Jumlah Transaksi:</strong> {{ $vendor['transaction_count'] ?? 0 }}
                    </p>
                    <!-- Tombol Nonaktifkan Vendor dengan alert konfirmasi -->
                    <form action="{{ route('vendor.deactivate', $vendor['id']) }}" method="POST"
                        onsubmit="return confirmNonaktif('{{ $vendor['id'] ?: 'Vendor' }}');" class="mt-4">
                        @csrf
                        <button type="submit"
                            class="bg-red-600 text-white px-5 py-2 rounded-lg hover:bg-red-700 transition duration-200 font-semibold shadow-md">
                            Nonaktifkan Vendor
                        </button>
                    </form>
                </div>
            @endforeach
        </div>
    </div>

    <script>
        function confirmNonaktif(nama) {
            return confirm("Apakah Anda yakin ingin menonaktifkan " + nama + "?");
        }
    </script>
@endsection
