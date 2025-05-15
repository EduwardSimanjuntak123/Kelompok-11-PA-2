<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="auth-token" content="{{ session('token') }}">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title')</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="bg-gray-100 flex">
    @if (session('error'))
        <script>
            Swal.fire({
                title: 'Error!',
                text: '{{ session('error') }}',
                icon: 'error',
                confirmButtonColor: '#d33'
            });
        </script>
    @endif

    @if (session('success'))
        <script>
            Swal.fire({
                title: 'Berhasil!',
                text: '{{ session('success') }}',
                icon: 'success',
                confirmButtonColor: '#3085d6'
            });
        </script>
    @endif

    <!-- Sidebar -->
    <aside class="w-64 bg-blue-600 text-white min-h-screen p-6 space-y-6">
        {{-- Logo --}}
        <a href="{{ route('vendor.dashboard') }}" class="block">
            <img src="{{ asset('logo1.png') }}" alt="Logo Rental Motor" class="h-12 w-auto mx-auto" />
        </a>
        <nav>
            <ul class="space-y-4">
                @php
                    $userRole = session('role', 'guest');
                    $userId = session('user_id') ?? null;
                    if ($userRole === 'admin') {
                        $dashboardUrl = route('admin.dashboard');
                    } elseif ($userRole === 'vendor' && $userId) {
                        $dashboardUrl = route('vendor.dashboard', ['id' => $userId]);
                    } else {
                        $dashboardUrl = route('login');
                    }
                @endphp
                <li>
                    @if ($userId)
                        <a href="{{ $dashboardUrl }}"
                            class="block px-4 py-2 rounded font-semibold {{ request()->routeIs($userRole === 'admin' ? 'admin' : 'vendor.dashboard') ? 'bg-white text-blue-600' : 'hover:bg-white hover:text-blue-600' }}">
                            Dashboard
                        </a>
                    @else
                        <span class="block px-4 py-2 rounded bg-gray-400 text-white font-semibold cursor-not-allowed">
                            Dashboard
                        </span>
                    @endif
                </li>
                @php
                    if ($userRole === 'admin') {
                        $profileUrl = route('admin.profile', ['id' => $userId]);
                    } elseif ($userRole === 'vendor' && $userId) {
                        $profileUrl = route('vendor.profile', ['id' => $userId]);
                    } else {
                        $profileUrl = '#';
                    }
                @endphp
                <li>
                    <a href="{{ $profileUrl }}"
                        class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs($userRole === 'admin' ? 'admin.profile' : 'vendor.profile') ? 'bg-white text-blue-600' : '' }}">
                        Kelola Profil
                    </a>
                </li>
                @if ($userRole === 'admin')
                    <!-- Menu untuk Admin -->
                    <li>
                        <a href="{{ route('admin.nonaktif', ['id' => $userId]) }}"
                            class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs('admin.nonaktif') ? 'bg-white text-blue-600' : '' }}">
                            Kelola Akun Vendor
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('admin.kecamatan', ['id' => $userId]) }}"
                            class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs('admin.kecamatan') ? 'bg-white text-blue-600' : '' }}">
                            Kelola kecamatan
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('admin.titiklokasi', ['id' => $userId]) }}"
                            class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs('admin.titiklokasi') ? 'bg-white text-blue-600' : '' }}">
                            Rekomendasi Lokasi
                        </a>
                    </li>
                @elseif ($userRole === 'vendor')
                    <!-- Menu untuk Vendor -->
                    <li>
                        <a href="{{ route('vendor.motor', ['id' => $userId]) }}"
                            class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs('vendor.motor') ? 'bg-white text-blue-600' : '' }}">
                            Kelola Harga & Ketersediaan Motor
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('vendor.kelola', ['id' => $userId]) }}"
                            class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs('vendor.kelola') ? 'bg-white text-blue-600' : '' }}">
                            Setujui/Tolak Pesanan
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('vendor.perpanjangansewa', ['id' => $userId]) }}"
                            class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs('vendor.perpanjangansewa') ? 'bg-white text-blue-600' : '' }}">
                            Perpanjangan Sewa
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('vendor.transaksi', ['id' => $userId]) }}"
                            class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs('vendor.transaksi') ? 'bg-white text-blue-600' : '' }}">
                            Data Transaksi
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('vendor.ulasan', ['id' => $userId]) }}"
                            class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600 {{ request()->routeIs('vendor.ulasan') ? 'bg-white text-blue-600' : '' }}">
                            Ulasan Pelanggan
                        </a>
                    </li>
                @endif
                <li>
                    <form id="logout-form" method="GET" action="{{ url('logout') }}">
                        <button type="button" onclick="confirmLogout()"
                            class="w-full text-left px-4 py-2 rounded hover:bg-white hover:text-blue-600">
                            Logout
                        </button>
                    </form>
                </li>
            </ul>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 p-6">
        <div class="bg-white p-6 rounded shadow">
            @yield('content')
        </div>
    </main>

    <script>
        function confirmLogout() {
            Swal.fire({
                title: 'Keluar dari Aplikasi?',
                text: 'Anda akan keluar dari sesi login. Lanjutkan?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: '<i class="fas fa-sign-out-alt"></i> Ya, Keluar',
                cancelButtonText: 'Batal',
                reverseButtons: true,
                focusCancel: true
            }).then((result) => {
                if (result.isConfirmed) {
                    document.getElementById('logout-form').submit();
                }
            });

        }
    </script>
</body>

</html>
