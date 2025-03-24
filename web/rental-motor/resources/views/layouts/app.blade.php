<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="auth-token" content="{{ session('token') }}">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title')</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
</head>

<body class="bg-gray-100 flex">
    <!-- Sidebar -->
    <aside class="w-64 bg-blue-600 text-white min-h-screen p-6 space-y-6">
        <h1 class="text-2xl font-bold">Rental Motor</h1>
        <nav>

            <ul class="space-y-4">
                @php
                    $userRole = session('role', 'guest');
                    $userId = session('user_id') ?? null; // Tambahkan default NULL

                    if ($userRole === 'admin') {
                        $dashboardUrl = route('admin');
                    } elseif ($userRole === 'vendor' && $userId) {
                        $dashboardUrl = route('vendor.dashboard', ['id' => $userId]);
                    } else {
                        $dashboardUrl = route('login');
                    }
                @endphp
                <li>
                    @if ($userId)
                        <a href="{{ $dashboardUrl }}"
                            class="block px-4 py-2 rounded bg-white text-blue-600 font-semibold">Dashboard</a>
                    @else
                        <span
                            class="block px-4 py-2 rounded bg-gray-400 text-white font-semibold cursor-not-allowed">Dashboard</span>
                    @endif
                </li>
                @php
                    $userRole = session('role', 'guest');
                    $userId = session('user_id');

                    if ($userRole === 'admin') {
                        $profileUrl = route('admin.profile', ['id' => $userId]);
                    } elseif ($userRole === 'vendor' && $userId) {
                        $profileUrl = route('vendor.profile', ['id' => $userId]);
                    } else {
                        $profileUrl = '#'; // Default jika role tidak dikenali
                    }
                @endphp

                <li>
                    <a href="{{ $profileUrl }}" class="block px-4 py-2 rounded hover:bg-white hover:text-blue-600">
                        Kelola Profil
                    </a>
                </li>
                <li>
                    <form method="GET" action="{{ url('logout') }}">
                        <button type="submit"
                            class="w-full text-left px-4 py-2 rounded hover:bg-white hover:text-blue-600">Logout</button>
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
</body>

</html>
