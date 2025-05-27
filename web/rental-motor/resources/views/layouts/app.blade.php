<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="auth-token" content="{{ session('token') }}">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title')</title>
    <!-- Favicon Basic -->
    <link rel="icon" href="/logo2.png" type="image/png">

    <!-- Untuk browser modern -->
    <link rel="icon" type="image/png" sizes="32x32" href="/logo1.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/logo1.png">
    <link rel="apple-touch-icon" href="/logo1.png">

    <!-- Fallback untuk berbagai browser -->
    <link rel="shortcut icon" href="/logo1.png">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="bg-gray-100">
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

    <div class="flex min-h-screen">
        <!-- Mobile Menu Button -->
        <button id="mobile-menu-button" class="lg:hidden fixed top-4 left-4 z-50 bg-blue-600 text-white p-2 rounded-md shadow-md">
            <i class="fas fa-bars text-lg"></i>
        </button>

        <!-- Overlay for mobile -->
        <div id="mobile-overlay" class="lg:hidden fixed inset-0 bg-black bg-opacity-50 z-30 hidden"></div>

        <!-- Sidebar -->
        <aside id="sidebar" class="w-64 bg-blue-600 text-white min-h-screen p-4 sm:p-6 space-y-4 sm:space-y-6 fixed lg:relative lg:translate-x-0 transform -translate-x-full transition-transform duration-300 ease-in-out z-40">
            <!-- Close button for mobile -->
            <button id="close-sidebar" class="lg:hidden absolute top-4 right-4 text-white text-xl">
                <i class="fas fa-times"></i>
            </button>

            {{-- Logo --}}
            <a href="{{ route('vendor.dashboard') }}" class="block mt-8 lg:mt-0">
                <img src="{{ asset('logo1.png') }}" alt="Logo Rental Motor" class="h-10 sm:h-12 w-auto mx-auto" />
            </a>
            <nav>
                <ul class="space-y-2 sm:space-y-4">
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
                                class="block px-3 sm:px-4 py-2 rounded font-semibold text-sm sm:text-base {{ request()->routeIs($userRole === 'admin' ? 'admin' : 'vendor.dashboard') ? 'bg-white text-blue-600' : 'hover:bg-white hover:text-blue-600' }}">
                                <i class="fas fa-tachometer-alt mr-2"></i>Dashboard
                            </a>
                        @else
                            <span class="block px-3 sm:px-4 py-2 rounded bg-gray-400 text-white font-semibold cursor-not-allowed text-sm sm:text-base">
                                <i class="fas fa-tachometer-alt mr-2"></i>Dashboard
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
                            class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs($userRole === 'admin' ? 'admin.profile' : 'vendor.profile') ? 'bg-white text-blue-600' : '' }}">
                            <i class="fas fa-user mr-2"></i>Kelola Profil
                        </a>
                    </li>
                    @if ($userRole === 'admin')
                        <!-- Menu untuk Admin -->
                        <li>
                            <a href="{{ route('admin.nonaktif', ['id' => $userId]) }}"
                                class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs('admin.nonaktif') ? 'bg-white text-blue-600' : '' }}">
                                <i class="fas fa-users-cog mr-2"></i><span class="hidden sm:inline">Kelola Akun</span><span class="sm:hidden">Akun</span> Vendor
                            </a>
                        </li>
                        <li>
                            <a href="{{ route('admin.kecamatan', ['id' => $userId]) }}"
                                class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs('admin.kecamatan') ? 'bg-white text-blue-600' : '' }}">
                                <i class="fas fa-map-marker-alt mr-2"></i><span class="hidden sm:inline">Kelola</span> Kecamatan
                            </a>
                        </li>
                        <li>
                            <a href="{{ route('admin.titiklokasi', ['id' => $userId]) }}"
                                class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs('admin.titiklokasi') ? 'bg-white text-blue-600' : '' }}">
                                <i class="fas fa-map mr-2"></i><span class="hidden sm:inline">Rekomendasi</span> Lokasi
                            </a>
                        </li>
                    @elseif ($userRole === 'vendor')
                        <!-- Menu untuk Vendor -->
                        <li>
                            <a href="{{ route('vendor.motor', ['id' => $userId]) }}"
                                class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs('vendor.motor') ? 'bg-white text-blue-600' : '' }}">
                                <i class="fas fa-motorcycle mr-2"></i><span class="hidden lg:inline">Kelola Harga &</span> <span class="lg:hidden">Harga &</span> <span class="hidden sm:inline">Ketersediaan</span> Motor
                            </a>
                        </li>
                        <li>
                            <a href="{{ route('vendor.kelola', ['id' => $userId]) }}"
                                class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs('vendor.kelola') ? 'bg-white text-blue-600' : '' }}">
                                <i class="fas fa-clipboard-check mr-2"></i><span class="hidden sm:inline">Setujui/Tolak</span><span class="sm:hidden">Kelola</span> Pesanan
                            </a>
                        </li>
                        <li>
                            <a href="{{ route('vendor.perpanjangansewa', ['id' => $userId]) }}"
                                class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs('vendor.perpanjangansewa') ? 'bg-white text-blue-600' : '' }}">
                                <i class="fas fa-calendar-plus mr-2"></i><span class="hidden sm:inline">Perpanjangan</span> Sewa
                            </a>
                        </li>
                        <li>
                            <a href="{{ route('vendor.transaksi', ['id' => $userId]) }}"
                                class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs('vendor.transaksi') ? 'bg-white text-blue-600' : '' }}">
                                <i class="fas fa-receipt mr-2"></i>Data Transaksi
                            </a>
                        </li>
                        <li>
                            <a href="{{ route('vendor.ulasan', ['id' => $userId]) }}"
                                class="block px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base {{ request()->routeIs('vendor.ulasan') ? 'bg-white text-blue-600' : '' }}">
                                <i class="fas fa-star mr-2"></i><span class="hidden sm:inline">Ulasan</span> Pelanggan
                            </a>
                        </li>
                    @endif
                    <li>
                        <form id="logout-form" method="GET" action="{{ url('logout') }}">
                            <button type="button" onclick="confirmLogout()"
                                class="w-full text-left px-3 sm:px-4 py-2 rounded hover:bg-white hover:text-blue-600 text-sm sm:text-base">
                                <i class="fas fa-sign-out-alt mr-2"></i>Logout
                            </button>
                        </form>
                    </li>
                </ul>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 lg:ml-0 p-4 sm:p-6 pt-16 lg:pt-6">
            <div class="bg-white p-4 sm:p-6 rounded shadow">
                @yield('content')
            </div>
        </main>
    </div>

    <script>
        // Mobile menu functionality
        const mobileMenuButton = document.getElementById('mobile-menu-button');
        const sidebar = document.getElementById('sidebar');
        const mobileOverlay = document.getElementById('mobile-overlay');
        const closeSidebar = document.getElementById('close-sidebar');

        function openSidebar() {
            sidebar.classList.remove('-translate-x-full');
            mobileOverlay.classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeSidebarFunc() {
            sidebar.classList.add('-translate-x-full');
            mobileOverlay.classList.add('hidden');
            document.body.style.overflow = 'auto';
        }

        mobileMenuButton.addEventListener('click', openSidebar);
        closeSidebar.addEventListener('click', closeSidebarFunc);
        mobileOverlay.addEventListener('click', closeSidebarFunc);

        // Close sidebar when clicking on menu items on mobile
        const sidebarLinks = sidebar.querySelectorAll('a');
        sidebarLinks.forEach(link => {
            link.addEventListener('click', () => {
                if (window.innerWidth < 1024) {
                    closeSidebarFunc();
                }
            });
        });

        // Handle window resize
        window.addEventListener('resize', () => {
            if (window.innerWidth >= 1024) {
                closeSidebarFunc();
            }
        });

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