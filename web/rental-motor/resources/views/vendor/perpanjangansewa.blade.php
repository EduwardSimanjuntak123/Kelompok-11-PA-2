@extends('layouts.app')

@section('title', 'Data Perpanjangan Sewa')

@section('content')
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- SweetAlert -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <div class="container mx-auto px-4 py-4 sm:py-6">
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-800 mb-4 sm:mb-6">Permintaan Perpanjangan Sewa</h1>

        @if (session('success'))
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                {{ session('success') }}
            </div>
        @endif
        @if (session('error'))
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                {{ session('error') }}
            </div>
        @endif

        @if (empty($extens) || count($extens) == 0)
            <div class="flex flex-col items-center justify-center text-center p-6 sm:p-10 bg-white rounded-lg shadow-md">
                <i class="fas fa-clock fa-2x sm:fa-3x text-gray-400 mb-4"></i>
                <h2 class="text-xl sm:text-2xl font-semibold text-gray-700">Belum Ada Permintaan Perpanjangan</h2>
                <p class="text-gray-600 mt-2 text-sm sm:text-base">Tidak ada permintaan perpanjangan sewa untuk ditampilkan.
                </p>
            </div>
        @else
            <!-- Desktop Table View -->
            <div class="hidden xl:block overflow-x-auto">
                <table class="min-w-full bg-white border rounded-lg shadow-sm">
                    <thead class="bg-gray-100 text-sm font-semibold text-gray-600">
                        <tr>
                            <th class="py-3 px-4 text-left">Customer</th>
                            {{-- <th class="py-3 px-4 text-left">Motor & Plat Motor</th> --}}
                            <th class="py-3 px-4 text-left">Tanggal Diminta</th>
                            <th class="py-3 px-2 text-left w-1/12">Tanggal Perpanjangan</th>
                            <th class="py-3 px-2 text-left w-1/12">Harga Tambahan</th>
                            <th class="py-3 px-4 text-left">Status</th>
                            <th class="py-3 px-4 text-left">Foto Motor</th>
                            <th class="py-3 px-4 text-left">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach (collect($extens)->sortByDesc('requested_at') as $extension)
                            @php
                                $booking = collect($bookings)->firstWhere('id', $extension['booking_id']);
                                $platmotor = $booking['motor']['plat_motor'] ?? '-';
                                $customerPhotoPath = $booking['ktpid'] ?? ($booking['potoid'] ?? null);
                                $customerPhotoUrl = $customerPhotoPath
                                    ? rtrim($apiBaseUrl, '/') . '/' . ltrim($customerPhotoPath, '/')
                                    : asset('img/user-placeholder.png');
                                $motorPath = $booking['motor']['image'] ?? null;
                                $motorUrl = $motorPath
                                    ? rtrim($apiBaseUrl, '/') . '/' . ltrim($motorPath, '/')
                                    : asset('img/placeholder.png');
                            @endphp
                            <tr class="border-t hover:bg-gray-50 transition">
                                <td class="py-3 px-4 text-left align-middle">
                                    <a href="javascript:void(0)"
                                        class="open-modal group text-blue-600 font-reguler underline hover:underline cursor-pointer"
                                        data-modal-id="modal-{{ $booking['id'] }}"
                                        title="Klik untuk melihat detail pemesanan">
                                        <span class="italic">lihat data pemesan &gt;</span>
                                    </a>
                                </td>
                                {{-- <td class="py-3 px-4">{{ $extension['motor_name'] }} & {{ $platmotor }}</td> --}}
                                <td class="py-3 px-4 text-sm text-gray-700">
                                    {{ \Carbon\Carbon::parse($extension['requested_at'])->format('d-m-Y H:i') }}
                                </td>
                                <td class="py-3 px-2">
                                    <span
                                        class="inline-block bg-blue-100 text-blue-800 text-sm font-medium px-2 py-1 rounded">
                                        {{ \Carbon\Carbon::parse($extension['requested_end_date'])->format('d-m-Y') }}
                                    </span>
                                </td>
                                <td class="py-3 px-2">
                                    <span
                                        class="inline-block bg-green-100 text-green-800 text-sm font-semibold px-2 py-1 rounded">
                                        Rp {{ number_format($extension['additional_price'], 0, ',', '.') }}
                                    </span>
                                </td>
                                <td class="py-3 px-4">
                                    @php
                                        $status = $extension['status'];
                                        if ($status === 'approved') {
                                            $statusText = 'Disetujui';
                                            $badgeClasses = 'bg-green-100 text-green-700';
                                        } elseif ($status === 'rejected') {
                                            $statusText = 'Ditolak';
                                            $badgeClasses = 'bg-red-100 text-red-700';
                                        } elseif ($status === 'pending') {
                                            $statusText = 'Menunggu Konfirmasi';
                                            $badgeClasses = 'bg-yellow-100 text-yellow-700';
                                        } else {
                                            $statusText = ucfirst($status);
                                            $badgeClasses = 'bg-gray-100 text-gray-700';
                                        }
                                    @endphp
                                    <span
                                        class="inline-flex justify-center items-center px-2 py-1 rounded text-xs font-medium {{ $badgeClasses }}">
                                        {{ $statusText }}
                                    </span>
                                </td>
                                <td class="py-3 px-4">
                                    <img src="{{ $motorUrl }}" alt="Gambar {{ $extension['motor_name'] }}"
                                        class="w-20 h-14 object-cover rounded shadow-sm">
                                </td>
                                <td class="py-3 px-4">
                                    @if (in_array($extension['status'], ['pending', 'requested']))
                                        <div class="flex gap-2">
                                            <button type="button"
                                                class="btn-approve px-4 py-2 bg-green-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150"
                                                data-form-id="approve-form-{{ $extension['extension_id'] }}">
                                                <i class="fas fa-check mr-1"></i> Setujui
                                            </button>
                                            <form id="approve-form-{{ $extension['extension_id'] }}"
                                                action="{{ route('vendor.approveExtension', ['extension_id' => $extension['extension_id']]) }}"
                                                method="POST" class="hidden">
                                                @csrf
                                            </form>
                                            <button type="button"
                                                class="btn-reject px-4 py-2 bg-red-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150"
                                                data-form-id="reject-form-{{ $extension['extension_id'] }}">
                                                <i class="fas fa-times mr-1"></i> Tolak
                                            </button>
                                            <form id="reject-form-{{ $extension['extension_id'] }}"
                                                action="{{ route('vendor.rejectExtension', ['extension_id' => $extension['extension_id']]) }}"
                                                method="POST" class="hidden">
                                                @csrf
                                            </form>
                                        </div>
                                    @else
                                        <span class="text-gray-400 text-sm">—</span>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <!-- Mobile/Tablet Card View -->
            <div class="xl:hidden space-y-4">
                @foreach (collect($extens)->sortByDesc('requested_at') as $extension)
                    @php
                        $booking = collect($bookings)->firstWhere('id', $extension['booking_id']);
                        $platmotor = $booking['motor']['plat_motor'] ?? '-';
                        $customerPhotoPath = $booking['ktpid'] ?? ($booking['potoid'] ?? null);
                        $customerPhotoUrl = $customerPhotoPath
                            ? rtrim($apiBaseUrl, '/') . '/' . ltrim($customerPhotoPath, '/')
                            : asset('img/user-placeholder.png');
                        $motorPath = $booking['motor']['image'] ?? null;
                        $motorUrl = $motorPath
                            ? rtrim($apiBaseUrl, '/') . '/' . ltrim($motorPath, '/')
                            : asset('img/placeholder.png');
                        $status = $extension['status'];
                        if ($status === 'approved') {
                            $statusText = 'Disetujui';
                            $badgeClasses = 'bg-green-100 text-green-700';
                        } elseif ($status === 'rejected') {
                            $statusText = 'Ditolak';
                            $badgeClasses = 'bg-red-100 text-red-700';
                        } elseif ($status === 'pending') {
                            $statusText = 'Menunggu';
                            $badgeClasses = 'bg-yellow-100 text-yellow-700';
                        } else {
                            $statusText = ucfirst($status);
                            $badgeClasses = 'bg-gray-100 text-gray-700';
                        }
                    @endphp

                    <div class="bg-white rounded-lg shadow-md border border-gray-200 p-4">
                        <!-- Header -->
                        <div class="flex items-start justify-between mb-3">
                            <div class="flex-1">
                                <a href="#" class="open-modal text-blue-600 font-semibold text-lg"
                                    data-modal-id="modal-{{ $booking['id'] }}">
                                    <i class="fas fa-info-circle mr-1"></i>
                                    {{ $extension['customer_name'] }}
                                </a>
                                <p class="text-sm text-gray-600 mt-1">
                                    {{ $extension['motor_name'] }} • {{ $platmotor }}
                                </p>
                            </div>
                            <span class="px-2 py-1 text-xs font-medium rounded-full {{ $badgeClasses }}">
                                {{ $statusText }}
                            </span>
                        </div>

                        <!-- Motor Image & Details -->
                        <div class="flex gap-3 mb-4">
                            <img src="{{ $motorUrl }}" alt="Motor"
                                class="w-16 h-16 sm:w-20 sm:h-20 object-cover rounded shadow-sm flex-shrink-0">

                            <div class="flex-1 space-y-2 text-sm">
                                <div>
                                    <span class="font-medium text-gray-600">Diminta:</span>
                                    <span
                                        class="text-gray-800">{{ \Carbon\Carbon::parse($extension['requested_at'])->format('d/m/Y H:i') }}</span>
                                </div>
                                <div>
                                    <span class="font-medium text-gray-600">Perpanjang sampai:</span>
                                    <span
                                        class="inline-block bg-blue-100 text-blue-800 text-xs font-medium px-2 py-1 rounded ml-1">
                                        {{ \Carbon\Carbon::parse($extension['requested_end_date'])->format('d/m/Y') }}
                                    </span>
                                </div>
                                <div>
                                    <span class="font-medium text-gray-600">Biaya tambahan:</span>
                                    <span
                                        class="inline-block bg-green-100 text-green-800 text-xs font-semibold px-2 py-1 rounded ml-1">
                                        Rp {{ number_format($extension['additional_price'], 0, ',', '.') }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        @if (in_array($extension['status'], ['pending', 'requested']))
                            <div class="flex flex-col sm:flex-row gap-2">
                                <button type="button"
                                    class="btn-approve flex-1 px-4 py-2 bg-green-600 text-white font-medium text-sm rounded-lg hover:bg-green-700 transition-colors"
                                    data-form-id="approve-form-{{ $extension['extension_id'] }}">
                                    <i class="fas fa-check mr-1"></i> Setujui
                                </button>
                                <form id="approve-form-{{ $extension['extension_id'] }}"
                                    action="{{ route('vendor.approveExtension', ['extension_id' => $extension['extension_id']]) }}"
                                    method="POST" class="hidden">
                                    @csrf
                                </form>
                                <button type="button"
                                    class="btn-reject flex-1 px-4 py-2 bg-red-600 text-white font-medium text-sm rounded-lg hover:bg-red-700 transition-colors"
                                    data-form-id="reject-form-{{ $extension['extension_id'] }}">
                                    <i class="fas fa-times mr-1"></i> Tolak
                                </button>
                                <form id="reject-form-{{ $extension['extension_id'] }}"
                                    action="{{ route('vendor.rejectExtension', ['extension_id' => $extension['extension_id']]) }}"
                                    method="POST" class="hidden">
                                    @csrf
                                </form>
                            </div>
                        @endif
                    </div>
                @endforeach
            </div>
        @endif
    </div>

    <!-- All Modals placed here at the bottom -->
    @foreach (collect($extens)->sortByDesc('requested_at') as $extension)
        @php
            $booking = collect($bookings)->firstWhere('id', $extension['booking_id']);
            $customerPhotoPath = $booking['ktpid'] ?? ($booking['potoid'] ?? null);
            $customerPhotoUrl = $customerPhotoPath
                ? rtrim($apiBaseUrl, '/') . '/' . ltrim($customerPhotoPath, '/')
                : asset('img/user-placeholder.png');

            // Status classes and labels
            $status = $booking['status'];
            $statusClasses = [
                'pending' => 'bg-yellow-100 text-yellow-800',
                'confirmed' => 'bg-blue-100 text-blue-800',
                'in transit' => 'bg-indigo-100 text-indigo-800',
                'in use' => 'bg-purple-100 text-purple-800',
                'awaiting return' => 'bg-orange-100 text-orange-800',
                'completed' => 'bg-green-100 text-green-800',
                'rejected' => 'bg-red-100 text-red-800',
            ];
            $statusLabels = [
                'pending' => 'Menunggu Konfirmasi',
                'confirmed' => 'Dikonfirmasi',
                'in transit' => 'Motor Diantar',
                'in use' => 'Sedang Digunakan',
                'awaiting return' => 'Menunggu Pengembalian',
                'completed' => 'Selesai',
                'rejected' => 'Ditolak',
            ];
            $statusDescription = [
                'pending' => 'Pemesanan sedang menunggu konfirmasi',
                'confirmed' => 'Pemesanan telah dikonfirmasi',
                'in transit' => 'Motor sedang dalam perjalanan ke lokasi penjemputan',
                'in use' => 'Motor sedang digunakan oleh customer',
                'awaiting return' => 'Menunggu pengembalian motor',
                'completed' => 'Pemesanan telah selesai',
                'rejected' => 'Pemesanan ditolak',
            ];
        @endphp

        <div id="modal-{{ $booking['id'] }}"
            class="modal hidden fixed inset-0 bg-black bg-opacity-40 backdrop-blur-sm z-[100] flex items-center justify-center transition-opacity duration-300 p-4">
            <div
                class="modal-content bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto relative transition-transform duration-200">
                <!-- Header with gradient background -->
                <div
                    class="flex justify-between items-center p-6 sticky top-0 bg-gradient-to-r from-blue-600 to-blue-500 text-white rounded-t-2xl">
                    <div class="flex items-center gap-3">
                        <div class="p-2 bg-blue-700 rounded-full">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M8 7V3m8 4V3m-9 8h10m-9 4h10m-3 4h3a2 2 0 002-2v-5a2 2 0 00-2-2h-3M5 21h3a2 2 0 002-2v-5a2 2 0 00-2-2H5a2 2 0 00-2 2v5a2 2 0 002 2z" />
                            </svg>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold">Detail Pemesanan</h2>
                        </div>
                    </div>
                    <button
                        class="close-modal text-white hover:text-blue-200 text-3xl leading-none font-light transition-all duration-200">
                        &times;
                    </button>
                </div>

                <!-- Content -->
                <div class="p-6">
                    <div class="flex flex-col lg:flex-row gap-8">
                        <!-- Customer Photo with Frame -->
                        <div class="w-full lg:w-2/5 flex flex-col items-center">
                            <div class="relative mb-4">
                                <img src="{{ $customerPhotoUrl }}" alt="Foto Customer"
                                    class="w-40 h-40 object-cover rounded-xl border-4 border-white shadow-lg ring-2 ring-blue-200"
                                    onerror="this.onerror=null; this.src='{{ asset('img/user-placeholder.png') }}'">
                            </div>

                            <!-- Contact Info -->
                            <div class="w-full bg-gray-50 p-4 rounded-lg border border-gray-200 space-y-2">
                                <div class="flex items-center gap-2 text-gray-700">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M5.121 17.804A13.937 13.937 0 0112 15c2.761 0 5.304.804 7.879 2.196M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                    </svg>
                                    <span>{{ $extension['customer_name'] }}</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                                    </svg>
                                    <span>{{ $booking['customer_email'] ?? '-' }}</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                                    </svg>
                                    <span>{{ $booking['customer_phone'] ?? '-' }}</span>
                                </div>
                            </div>
                        </div>

                        <!-- Booking Details -->
                        <div class="w-full lg:w-3/5 space-y-5">
                            <!-- Date Cards -->
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div class="bg-blue-50 p-4 rounded-lg border border-blue-100">
                                    <p class="text-sm text-blue-600 font-medium">Tanggal Booking</p>
                                    <p class="text-lg font-semibold text-blue-800">
                                        {{ \Carbon\Carbon::parse($booking['booking_date'])->format('d-m-Y H:i') }}
                                    </p>
                                </div>
                                <div class="bg-green-50 p-4 rounded-lg border border-green-100">
                                    <p class="text-sm text-green-600 font-medium">Mulai Sewa</p>
                                    <p class="text-lg font-semibold text-green-800">
                                        {{ \Carbon\Carbon::parse($booking['start_date'])->format('d-m-Y') }}
                                    </p>
                                </div>
                                <div class="bg-red-50 p-4 rounded-lg border border-red-100">
                                    <p class="text-sm text-red-600 font-medium">Akhir Sewa</p>
                                    <p class="text-lg font-semibold text-red-800">
                                        {{ \Carbon\Carbon::parse($booking['end_date'])->format('d-m-Y') }}
                                    </p>
                                </div>
                            </div>

                            <!-- Booking Information Card -->
                            <div class="bg-gray-50 p-5 rounded-xl border border-gray-200 space-y-4">
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800 mb-3 flex items-center gap-2">
                                        <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                            viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                        </svg>
                                        Informasi Pemesanan
                                    </h3>
                                    <div class="space-y-3">
                                        <div>
                                            <p class="text-sm text-gray-500">Motor</p>
                                            <p class="font-medium text-gray-800">
                                                {{ $extension['motor_name'] }}
                                                ({{ $booking['motor']['plat_motor'] ?? '-' }})
                                            </p>
                                        </div>
                                        <div>
                                            <p class="text-sm text-gray-500">Lokasi Penjemputan</p>
                                            <p class="font-medium text-gray-800">{{ $booking['pickup_location'] }}</p>
                                        </div>
                                        <div>
                                            <p class="text-sm text-gray-500">Harga Perpanjangan</p>
                                            <p class="font-medium text-gray-800">
                                                Rp {{ number_format($extension['additional_price'], 0, ',', '.') }}
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Status Card -->
                            <div class="bg-white p-4 rounded-lg border border-gray-200">
                                <p class="text-sm text-gray-500 mb-2">Status Pemesanan</p>
                                <div class="flex items-center gap-2">
                                    <span
                                        class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold capitalize {{ $statusClasses[$status] ?? 'bg-gray-100 text-gray-800' }}">
                                        <span
                                            class="w-2 h-2 rounded-full 
                                        @if ($status === 'pending') bg-yellow-500
                                        @elseif($status === 'confirmed') bg-blue-500
                                        @elseif($status === 'in transit') bg-indigo-500
                                        @elseif($status === 'in use') bg-purple-500
                                        @elseif($status === 'awaiting return') bg-orange-500
                                        @elseif($status === 'completed') bg-green-500
                                        @elseif($status === 'rejected') bg-red-500
                                        @else bg-gray-500 @endif
                                        mr-2"></span>
                                        {{ $statusLabels[$status] ?? ucfirst($status) }}
                                    </span>
                                    <p class="text-sm text-gray-600">
                                        {{ $statusDescription[$status] ?? 'Status pemesanan tidak diketahui' }}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    @endforeach

    <script>
        // Improved Modal Functionality
        document.addEventListener('DOMContentLoaded', function() {
            // Open modal with event delegation
            document.addEventListener('click', function(e) {
                const openModalBtn = e.target.closest('.open-modal');
                if (openModalBtn) {
                    e.preventDefault();
                    const modalId = openModalBtn.getAttribute('data-modal-id');
                    const modal = document.getElementById(modalId);
                    if (modal) {
                        // Disable body scroll
                        document.body.style.overflow = 'hidden';
                        // Show modal
                        modal.classList.remove('hidden');
                    }
                }
            });

            // Close modal
            document.addEventListener('click', function(e) {
                // Close button
                if (e.target.classList.contains('close-modal') || e.target.closest('.close-modal')) {
                    const modal = e.target.closest('.modal');
                    if (modal) {
                        // Enable body scroll
                        document.body.style.overflow = '';
                        // Hide modal
                        modal.classList.add('hidden');
                    }
                }

                // Click outside modal content
                if (e.target.classList.contains('modal')) {
                    // Enable body scroll
                    document.body.style.overflow = '';
                    // Hide modal
                    e.target.classList.add('hidden');
                }
            });

            // SweetAlert for Approve & Reject
            document.querySelectorAll('.btn-approve').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    e.preventDefault();
                    Swal.fire({
                        title: 'Setujui perpanjangan?',
                        text: 'Tindakan ini tidak bisa dibatalkan!',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#16a34a',
                        cancelButtonColor: '#d33',
                        confirmButtonText: 'Ya, Setujui!',
                        cancelButtonText: 'Batal'
                    }).then(result => {
                        if (result.isConfirmed) {
                            document.getElementById(btn.dataset.formId).submit();
                        }
                    });
                });
            });

            document.querySelectorAll('.btn-reject').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    e.preventDefault();
                    Swal.fire({
                        title: 'Tolak perpanjangan?',
                        text: 'Pastikan alasan penolakan sudah jelas!',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#dc2626',
                        cancelButtonColor: '#6b7280',
                        confirmButtonText: 'Ya, Tolak!',
                        cancelButtonText: 'Batal'
                    }).then(result => {
                        if (result.isConfirmed) {
                            document.getElementById(btn.dataset.formId).submit();
                        }
                    });
                });
            });
        });
    </script>
@endsection
