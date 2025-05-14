@extends('layouts.app')

@section('title', 'Daftar Vendor Terdaftar')

@section('content')
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    @if (session('message'))
        <script>
            Swal.fire({
                icon: 'success',
                title: 'Berhasil!',
                text: '{{ session('message') }}',
                confirmButtonText: 'OK'
            });
        </script>
    @endif

    @if (session('error'))
        <script>
            Swal.fire({
                icon: 'error',
                title: 'Gagal!',
                text: '{{ session('error') }}',
                showConfirmButton: true,
            });
        </script>
    @endif

    <div class="container mx-auto p-8">
        <h2 class="text-4xl font-extrabold text-center text-gray-800 mb-8">Daftar Vendor Terdaftar</h2>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            @forelse ($vendors as $vendor)
                <div
                    class="bg-gradient-to-br from-white to-gray-50 shadow-xl rounded-2xl p-6 border border-gray-200 hover:shadow-2xl transform hover:scale-[1.02] transition duration-300">
                    <!-- Gambar Profil -->
                    <div class="flex justify-center mb-4">
                        <img src="{{ $vendor['profile_image'] }}" alt="Profil Vendor"
                            class="w-24 h-24 rounded-full border-4 border-white shadow-lg object-cover hover:scale-110 transition duration-300">
                    </div>

                    <!-- Nama dan Kontak -->
                    <h3 class="text-2xl font-bold text-gray-800 text-center">{{ $vendor['name'] ?: 'Vendor Tanpa Nama' }}
                    </h3>
                    <div class="text-sm mt-4 space-y-2 text-gray-600 text-left">
                        <div class="flex items-center justify-start gap-2">
                            <i class="bi bi-envelope-fill text-blue-500"></i>
                            <span>{{ $vendor['email'] }}</span>
                        </div>
                        <div class="flex items-center justify-start gap-2">
                            <i class="bi bi-telephone-fill text-blue-500"></i>
                            <span>{{ $vendor['phone'] }}</span>
                        </div>
                        <div class="flex items-center justify-start gap-2">
                            <i class="bi bi-geo-alt-fill text-blue-500"></i>
                            <span>{{ $vendor['address'] }}</span>
                        </div>
                    </div>

                    <!-- Status Badge -->
                    @php
                        $isActive = $vendor['status'] === 'active';
                        $badgeColor = $isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700';
                        $statusText = $isActive ? '🟢 Aktif' : '🔴 Tidak Aktif';
                    @endphp
                    <div class="mt-4 text-left">
                        <span class="inline-block px-3 py-1 rounded-full text-sm font-semibold {{ $badgeColor }}">
                            {{ $statusText }}
                        </span>
                    </div>

                    <!-- Statistik -->
                    <div class="mt-4 text-sm text-gray-700 space-y-1 text-left">
                        <p><strong>Jumlah Motor:</strong> {{ $vendor['motor_count'] ?? 0 }}</p>
                        <p><strong>Jumlah Transaksi:</strong> {{ $vendor['transaction_count'] ?? 0 }}</p>
                    </div>

                    <!-- Tombol Aksi -->
                    <div class="mt-6 text-center">
                        @if ($vendor['status'] == 'active')
                            <form action="{{ route('vendor.deactivate', $vendor['id']) }}" method="POST"
                                onsubmit="return confirmNonaktif(event, '{{ $vendor['name'] }}');">
                                @csrf
                                <button type="submit"
                                    class="bg-red-600 text-white px-12 py-2 rounded-lg hover:bg-red-700 transition-all duration-200 font-semibold shadow-md text-base truncate">
                                    Nonaktifkan Vendor
                                </button>
                            </form>
                        @else
                            <form action="{{ route('vendor.activate', $vendor['id']) }}" method="POST"
                                onsubmit="return confirmAktifkan(event, '{{ $vendor['name'] ?: 'Vendor' }}');">
                                @csrf
                                @method('PUT')
                                <button type="submit"
                                    class="bg-green-600 text-white px-16 py-2 rounded-lg hover:bg-green-700 transition-all duration-200 font-semibold shadow-md text-base truncate">
                                    Aktifkan Vendor
                                </button>
                            </form>
                        @endif
                    </div>
                </div>
            @empty
                <div class="col-span-full">
                    <div class="flex flex-col items-center justify-center bg-white rounded-2xl shadow-lg p-12 text-center">
                        <div class="text-gray-400 text-6xl mb-6">
                            <i class="fas fa-store-slash"></i>
                        </div>
                        <h3 class="text-2xl font-bold text-gray-700 mb-3">Belum Ada Vendor Terdaftar</h3>
                        <p class="text-gray-500 mb-6 max-w-md">
                            Sistem belum mencatat vendor terdaftar. Silakan undang vendor baru
                            atau hubungi administrator untuk informasi lebih lanjut.
                        </p>
                        <div class="flex flex-col sm:flex-row gap-4">
                            <button onclick="window.location.reload()"
                                class="bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium py-3 px-8 rounded-lg shadow-md transition-all flex items-center justify-center">
                                <i class="fas fa-sync-alt mr-2"></i> Refresh
                            </button>
                        </div>
                    </div>
                </div>
            @endforelse
        </div>
    </div>

    <script>
        function confirmNonaktif(event, nama) {
            event.preventDefault(); // hentikan submit
            Swal.fire({
                title: 'Yakin?',
                text: "Apakah Anda yakin ingin menonaktifkan " + nama + "?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Ya, nonaktifkan!',
                cancelButtonText: 'Batal'
            }).then((result) => {
                if (result.isConfirmed) {
                    event.target.submit(); // lanjutkan submit form
                }
            });
            return false;
        }

        function confirmAktifkan(event, nama) {
            event.preventDefault();
            Swal.fire({
                title: 'Yakin?',
                text: "Apakah Anda yakin ingin mengaktifkan kembali " + nama + "?",
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Ya, aktifkan!',
                cancelButtonText: 'Batal'
            }).then((result) => {
                if (result.isConfirmed) {
                    event.target.submit();
                }
            });
            return false;
        }
    </script>


@endsection
