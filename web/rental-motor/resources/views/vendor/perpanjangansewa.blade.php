@extends('layouts.app')

@section('title', 'Data Perpanjangan Sewa')

@section('content')
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
                <p class="text-gray-600 mt-2 text-sm sm:text-base">Tidak ada permintaan perpanjangan sewa untuk ditampilkan.</p>
            </div>
        @else
            <!-- Desktop Table View -->
            <div class="hidden xl:block overflow-x-auto">
                <table class="min-w-full bg-white border rounded-lg shadow-sm">
                    <thead class="bg-gray-100 text-sm font-semibold text-gray-600">
                        <tr>
                            <th class="py-3 px-4 text-left">Customer</th>
                            <th class="py-3 px-4 text-left">Motor & Plat Motor</th>
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
                                <td class="py-3 px-4">
                                    <a href="#"
                                        class="open-modal group text-blue-600 font-medium underline hover:underline cursor-pointer flex items-center"
                                        data-modal-id="modal-{{ $booking['id'] }}"
                                        title="Klik untuk melihat detail pemesanan">
                                        <i class="fas fa-info-circle mr-1 text-gray-500 group-hover:text-blue-500"></i>
                                        {{ $extension['customer_name'] }}
                                    </a>
                                </td>
                                <td class="py-3 px-4">{{ $extension['motor_name'] }} & {{ $platmotor }}</td>
                                <td class="py-3 px-4 text-sm text-gray-700">
                                    {{ \Carbon\Carbon::parse($extension['requested_at'])->format('d-m-Y H:i') }}
                                </td>
                                <td class="py-3 px-2">
                                    <span class="inline-block bg-blue-100 text-blue-800 text-sm font-medium px-2 py-1 rounded">
                                        {{ \Carbon\Carbon::parse($extension['requested_end_date'])->format('d-m-Y') }}
                                    </span>
                                </td>
                                <td class="py-3 px-2">
                                    <span class="inline-block bg-green-100 text-green-800 text-sm font-semibold px-2 py-1 rounded">
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
                                    <span class="inline-flex justify-center items-center px-2 py-1 rounded text-xs font-medium {{ $badgeClasses }}">
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
                                <a href="#"
                                    class="open-modal text-blue-600 font-semibold text-lg"
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
                                    <span class="text-gray-800">{{ \Carbon\Carbon::parse($extension['requested_at'])->format('d/m/Y H:i') }}</span>
                                </div>
                                <div>
                                    <span class="font-medium text-gray-600">Perpanjang sampai:</span>
                                    <span class="inline-block bg-blue-100 text-blue-800 text-xs font-medium px-2 py-1 rounded ml-1">
                                        {{ \Carbon\Carbon::parse($extension['requested_end_date'])->format('d/m/Y') }}
                                    </span>
                                </div>
                                <div>
                                    <span class="font-medium text-gray-600">Biaya tambahan:</span>
                                    <span class="inline-block bg-green-100 text-green-800 text-xs font-semibold px-2 py-1 rounded ml-1">
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

                    <!-- Modal for each booking -->
                    <div id="modal-{{ $booking['id'] }}"
                        class="modal hidden fixed inset-0 bg-black bg-opacity-40 backdrop-blur-sm z-50 flex items-center justify-center transition-opacity duration-300 p-4"
                        data-modal-id="modal-{{ $booking['id'] }}">
                        <div class="modal-content bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto relative scale-95 transition-transform duration-200">
                            <!-- Header -->
                            <div class="flex justify-between items-center border-b p-4 sm:p-6 sticky top-0 bg-white rounded-t-2xl">
                                <h2 class="text-xl sm:text-2xl md:text-3xl font-bold text-gray-800 flex items-center gap-2">
                                    <svg class="w-5 h-5 sm:w-6 sm:h-6 text-blue-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 7V3m8 4V3m-9 8h10m-9 4h10m-3 4h3a2 2 0 002-2v-5a2 2 0 00-2-2h-3M5 21h3a2 2 0 002-2v-5a2 2 0 00-2-2H5a2 2 0 00-2 2v5a2 2 0 002 2z" />
                                    </svg>
                                    Detail Booking
                                </h2>
                                <button class="close-modal close-btn text-gray-500 hover:text-red-600 text-2xl sm:text-3xl leading-none font-light transition-all duration-200">
                                    &times;
                                </button>
                            </div>

                            <!-- Content -->
                            <div class="p-4 sm:p-6">
                                <div class="flex flex-col lg:flex-row gap-6">
                                    <!-- Image -->
                                    <div class="w-full lg:w-1/2 flex justify-center">
                                        <img src="{{ $customerPhotoUrl }}" alt="Foto KTP {{ $extension['customer_name'] }}"
                                            class="w-full max-w-sm h-48 sm:h-64 lg:h-60 object-cover rounded-xl border shadow">
                                    </div>
                                    
                                    <!-- Info -->
                                    <div class="w-full lg:w-1/2 space-y-3 text-sm sm:text-base text-gray-700">
                                        <p class="flex flex-col sm:flex-row">
                                            <span class="font-semibold mb-1 sm:mb-0 sm:mr-2">Nama:</span>
                                            <span>{{ $extension['customer_name'] }}</span>
                                        </p>
                                        <p class="flex flex-col sm:flex-row">
                                            <span class="font-semibold mb-1 sm:mb-0 sm:mr-2">Tanggal Booking:</span>
                                            <span>{{ \Carbon\Carbon::parse($booking['booking_date'])->format('d-m-Y H:i') }}</span>
                                        </p>
                                        <p class="flex flex-col sm:flex-row">
                                            <span class="font-semibold mb-1 sm:mb-0 sm:mr-2">Mulai Sewa:</span>
                                            <span>{{ \Carbon\Carbon::parse($booking['start_date'])->format('d-m-Y') }}</span>
                                        </p>
                                        <p class="flex flex-col sm:flex-row">
                                            <span class="font-semibold mb-1 sm:mb-0 sm:mr-2">Akhir Sewa:</span>
                                            <span>{{ \Carbon\Carbon::parse($booking['end_date'])->format('d-m-Y') }}</span>
                                        </p>
                                        <p class="flex flex-col">
                                            <span class="font-semibold mb-1">Lokasi Jemput:</span>
                                            <span class="break-words">{{ $booking['pickup_location'] }}</span>
                                        </p>
                                        <p class="flex flex-col sm:flex-row sm:items-center">
                                            <span class="font-semibold mb-1 sm:mb-0 sm:mr-2">Status:</span>
                                            @php
                                                $status = $booking['status'];
                                                $classes = [
                                                    'pending' => 'bg-yellow-100 text-yellow-800',
                                                    'confirmed' => 'bg-blue-100 text-blue-800',
                                                    'in transit' => 'bg-indigo-100 text-indigo-800',
                                                    'in use' => 'bg-purple-100 text-purple-800',
                                                    'awaiting return' => 'bg-orange-100 text-orange-800',
                                                    'completed' => 'bg-green-100 text-green-800',
                                                    'rejected' => 'bg-red-100 text-red-800',
                                                ];
                                                $label = [
                                                    'pending' => 'Menunggu Konfirmasi',
                                                    'confirmed' => 'Dikonfirmasi',
                                                    'in transit' => 'Motor Diantar',
                                                    'in use' => 'Sedang Digunakan',
                                                    'awaiting return' => 'Menunggu Pengembalian',
                                                    'completed' => 'Selesai',
                                                    'rejected' => 'Ditolak',
                                                ];
                                            @endphp
                                            <span class="inline-block px-3 py-1 text-sm font-semibold rounded-full {{ $classes[$status] ?? 'bg-gray-100 text-gray-800' }}">
                                                {{ $label[$status] ?? ucfirst($status) }}
                                            </span>
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        @endif
    </div>

    <script>
        // Modal functionality
        function closeModal(modal) {
            modal.querySelector('.modal-content').classList.add('scale-95');
            setTimeout(() => modal.classList.add('hidden'), 200);
        }

        document.querySelectorAll('.open-modal').forEach(btn => {
            btn.addEventListener('click', e => {
                e.preventDefault();
                const modal = document.getElementById(btn.dataset.modalId);
                modal.classList.remove('hidden');
                setTimeout(() => modal.querySelector('.modal-content').classList.remove('scale-95'), 10);
            });
        });

        document.querySelectorAll('.modal').forEach(modal => {
            modal.addEventListener('click', e => {
                if (e.target === modal) {
                    closeModal(modal);
                }
            });
            modal.querySelectorAll('.close-btn').forEach(btn => {
                btn.addEventListener('click', e => {
                    e.stopPropagation();
                    closeModal(modal);
                });
            });
        });

        // SweetAlert for Approve & Reject
        document.querySelectorAll('.btn-approve').forEach(btn => {
            btn.addEventListener('click', () => {
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
            btn.addEventListener('click', () => {
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
    </script>
@endsection