@extends('layouts.app')

@section('title', 'Kelola Pemesanan')

@section('content')
    <!-- Include SweetAlert2 dari CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-k6d4wzSIapyDyv1kpU366/PK5hCdSbCRGRCMv+eplOQJWyd1fbcAu9OCUj5zNLiq" crossorigin="anonymous">
    </script>


    <div class="container mx-auto p-8">
        <h2 class="text-4xl font-extrabold mb-6 text-center text-gray-800">Kelola Pemesanan</h2>
        {{-- @dd($bookings) --}}
        <!-- Filter dan Booking Manual dalam satu baris -->
        <div class="mb-6 flex items-center justify-between">
            <!-- Form Filter Status -->
            <form method="GET" class="flex items-center gap-4">
                <label for="status" class="text-sm font-medium text-gray-700">Filter Status:</label>
                <div class="relative w-60">
                    <!-- Icon di kiri -->
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 12h18M3 20h18" />
                        </svg>
                    </div>

                    <select id="status" name="status" onchange="this.form.submit()"
                        class="block w-full pl-10 pr-8 py-2 bg-white border border-gray-300 rounded-lg text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm appearance-none">
                        <option value="all" {{ request('status', 'all') == 'all' ? 'selected' : '' }}>Semua Status
                        </option>
                        <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>Menunggu Konfirmasi
                        </option>
                        <option value="confirmed" {{ request('status') == 'confirmed' ? 'selected' : '' }}>Dikonfirmasi
                        </option>
                        <option value="in transit" {{ request('status') == 'in transit' ? 'selected' : '' }}>Motor Sedang
                            Diantar
                        </option>
                        <option value="in use" {{ request('status') == 'in use' ? 'selected' : '' }}>Sedang Digunakan
                        </option>
                        <option value="awaiting return" {{ request('status') == 'awaiting return' ? 'selected' : '' }}>
                            Menunggu
                            Pengembalian</option>
                        <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>Pesanan Selesai
                        </option>
                        <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>Booking Ditolak
                        </option>
                    </select>

                    <!-- Arrow dropdown -->
                    <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-gray-500" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
                        </svg>
                    </div>
                </div>
            </form>


            <!-- Tombol Booking Manual -->
            <button onclick="openModal('addBookingModal')"
                class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
                + Booking Manual
            </button>
        </div>




        @if (empty($bookings) || count($bookings) == 0)
            <div class="flex flex-col items-center justify-center text-center p-10 bg-white rounded-lg shadow-md">
                <!-- Icon di atas teks -->
                <i class="fas fa-calendar-times fa-3x text-gray-400 mb-4"></i>

                <h2 class="text-2xl font-semibold text-gray-700">Belum Ada Pemesanan</h2>
                <p class="text-gray-600 mt-2">Tidak ada pemesanan untuk ditampilkan.</p>
            </div>
        @else
            <div class="overflow-x-auto">
                <table class="min-w-full bg-white shadow-md rounded-lg table-fixed">
                    <thead>
                        <tr class="bg-gray-200 text-gray-600 text-sm leading-normal">
                            <th class="py-3 px-4 text-center w-[5%]">No</th>
                            <th class="py-3 px-4 text-left align-top w-[28%]">Detail Pemesanan</th>
                            <th class="py-3 px-4 text-left align-top w-[20%]">Detail Motor</th>
                            <th class="py-3 px-4 text-center w-[17%]">Gambar</th>
                            <th class="py-3 px-4 text-center w-[10%]">Status</th>
                            <th class="py-3 px-4 text-center w-[15%]">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="text-gray-600 text-sm font-light">
                        @foreach ($bookings as $pesanan)
                            {{-- @dd($bookings) --}}
                            <tr class="border-b border-gray-200 hover:bg-gray-100" data-status="{{ $pesanan['status'] }}">
                                <td class="py-3 px-4 text-center align-middle">{{ $loop->iteration }}</td>

                                <td class="py-4 px-6 text-left align-middle">
                                    <a href="javascript:void(0)"
                                        class="open-booking-modal group text-blue-600 font-semibold underline hover:underline cursor-pointer flex items-center"
                                        data-booking='@json(array_merge($pesanan, ['potoid' => $pesanan['potoid'] ? config('api.base_url') . $pesanan['potoid'] : null]),
                                            JSON_UNESCAPED_SLASHES)'
                                        title="Klik untuk melihat detail pemesanan">
                                        <i class="fas fa-info-circle mr-1 text-gray-500 group-hover:text-blue-500"></i>
                                        <span>{{ $pesanan['customer_name'] }}</span>
                                    </a>
                                </td>

                                <!-- Detail Motor -->
                                <td class="py-3 px-4 text-left align-middle">
                                    @if (isset($pesanan['motor']))
                                        <div><strong class="font-bold">Nama Motor:</strong>
                                            {{ $pesanan['motor']['name'] ?? '-' }}
                                        </div>
                                        <div><strong class="font-bold">Merek Motor:</strong>
                                            {{ $pesanan['motor']['brand'] ?? '-' }}</div>
                                        <div><strong class="font-bold">Tahun:</strong>
                                            {{ $pesanan['motor']['year'] ?? '-' }}</div>
                                        <div><strong class="font-bold">Warna:</strong>
                                            {{ $pesanan['motor']['color'] ?? '-' }}</div>
                                        <div><strong class="font-bold">Plat Motor:</strong>
                                            {{ $pesanan['motor']['plat_motor'] ?? '-' }}</div>
                                    @else
                                        <div>Data motor tidak tersedia.</div>
                                    @endif
                                </td>
                                <!-- Gambar Motor -->
                                <td class="py-3 px-4 text-center align-top">
                                    @if (isset($pesanan['motor']['image']))
                                        <img src="{{ config('api.base_url') }}{{ $pesanan['motor']['image'] }}"
                                            alt="Motor" class="w-30 h-30 object-cover rounded mx-auto">
                                    @else
                                        <span class="text-gray-400">-</span>
                                    @endif
                                </td>

                                <!-- Status -->
                                <td class="py-3 px-4 text-center">
                                    @php $s = $pesanan['status']; @endphp
                                    <strong
                                        class="
              @if ($s == 'pending') text-yellow-600
              @elseif($s == 'confirmed') text-blue-600
              @elseif($s == 'in transit') text-indigo-600
              @elseif($s == 'in use') text-purple-600
              @elseif($s == 'awaiting return') text-orange-600
              @elseif($s == 'completed') text-green-600
              @elseif($s == 'rejected') text-red-600
              @else text-gray-600 @endif
            ">
                                        @if ($s == 'pending')
                                            Menunggu Konfirmasi
                                        @elseif($s == 'confirmed')
                                            Dikonfirmasi
                                        @elseif($s == 'in transit')
                                            Motor Sedang Diantar
                                        @elseif($s == 'in use')
                                            Sedang Digunakan
                                        @elseif($s == 'awaiting return')
                                            Menunggu Pengembalian
                                        @elseif($s == 'completed')
                                            Pesanan Selesai
                                        @elseif($s == 'rejected')
                                            Booking Ditolak
                                        @else
                                            {{ ucfirst($s) }}
                                        @endif
                                    </strong>
                                </td>

                                <td class="py-3 px-4 text-center">
                                    @if ($s == 'pending')
                                        <div class="flex justify-center gap-2">
                                            <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'confirm')"
                                                class="px-4 py-2 bg-green-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                                <i class="fas fa-check mr-1"></i> Setujui
                                            </button>
                                            <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'reject')"
                                                class="px-4 py-2 bg-red-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                                <i class="fas fa-times mr-1"></i> Tolak
                                            </button>
                                        </div>
                                    @elseif ($s == 'confirmed')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'transit')"
                                            class="px-4 py-2 bg-blue-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                            <i class="fas fa-motorcycle mr-1"></i> Antar Motor
                                        </button>
                                    @elseif ($s == 'in transit')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'inuse')"
                                            class="px-4 py-2 bg-indigo-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                            <i class="fas fa-play mr-1"></i> Sedang Berlangsung
                                        </button>
                                    @elseif ($s == 'awaiting return')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'complete')"
                                            class="px-4 py-2 bg-green-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                            <i class="fas fa-undo mr-1"></i> Motor Kembali
                                        </button>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif

        <!-- Modal Detail Pemesanan -->
        <div id="bookingDetailModal"
            class="fixed inset-0 z-50 hidden bg-black bg-opacity-50 backdrop-blur-sm flex items-center justify-center px-4">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-3xl p-6 overflow-y-auto max-h-[90vh] relative">
                <button type="button" onclick="closeBookingModal()"
                    class="close-modal absolute top-4 right-4 text-gray-500 hover:text-gray-700 text-3xl leading-none">
                    &times;
                </button>

                <div class="flex flex-row gap-6">
                    {{-- Kolom Foto di Kiri --}}
                    <div class="w-1/3 flex justify-center items-start">
                        <img id="modalCustomerPhoto" src="" alt="Foto Customer"
                            class="w-60 h-60 object-cover rounded-lg shadow-md"
                            onerror="this.onerror=null; this.src='{{ asset('images/default-user.png') }}'">
                    </div>

                    {{-- Kolom Data di Kanan --}}
                    <div class="w-2/3 flex flex-col space-y-4 text-gray-700">
                        {{-- Nama Customer --}}
                        <div>
                            <span class="font-semibold">Nama:</span>
                            <span id="modalCustomerName">–</span>
                        </div>

                        {{-- Booking Date (highlight) --}}
                        <div>
                            <span class="font-semibold">Tanggal Booking:</span>
                            <span id="modalBookingDate"
                                class="ml-2 px-2 py-1 bg-blue-100 text-blue-800 font-medium rounded">
                                –
                            </span>
                        </div>

                        {{-- Start Date (highlight) --}}
                        <div>
                            <span class="font-semibold">Tanggal Mulai:</span>
                            <span id="modalStartDate"
                                class="ml-2 px-2 py-1 bg-green-100 text-green-800 font-medium rounded">
                                –
                            </span>
                        </div>

                        {{-- End Date (highlight) --}}
                        <div>
                            <span class="font-semibold">Tanggal Berakhir:</span>
                            <span id="modalEndDate" class="ml-2 px-2 py-1 bg-red-100 text-red-800 font-medium rounded">
                                –
                            </span>
                        </div>

                        {{-- Pickup Location --}}
                        <div>
                            <span class="font-semibold">Jemput di:</span>
                            <span id="modalPickup">–</span>
                        </div>

                        {{-- Status --}}
                        <div>
                            <span class="font-semibold">Status:</span>
                            <span id="modalStatus" class="capitalize">–</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>


        <div class="mt-8 flex items-center justify-between">
            {{-- Kiri: info rangkuman --}}
            <div class="text-sm text-gray-600">
                Menampilkan {{ $bookings->firstItem() }}
                - {{ $bookings->lastItem() }} dari total
                {{ $bookings->total() }} data
            </div>

            {{-- Kanan: pagination --}}
            <div>
                {!! $bookings->links('layouts.pagination') !!}
            </div>
        </div>

        <!-- Modal untuk Booking Manual -->
        <div id="addBookingModal"
            class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 z-50 flex items-center justify-center px-4">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-4xl p-6 md:p-8 overflow-y-auto max-h-screen relative">
                <!-- Tombol Close -->
                <button type="button" onclick="closeModal('addBookingModal')"
                    class="absolute top-4 right-4 text-gray-600 hover:text-gray-800">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>

                <h2 class="text-2xl font-bold mb-6 text-gray-800">Tambah Booking Manual</h2>
                <form id="manualBookingForm" action="{{ route('vendor.manual.booking.store') }}" method="POST"
                    enctype="multipart/form-data">
                    @csrf
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Dropdown Motor -->
                        <div>
                            <label for="motor_id" class="block text-gray-700 font-semibold mb-1">Pilih Motor</label>
                            <select name="motor_id" id="motor_id"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400 placeholder:text-sm placeholder-gray-500">
                                <option value="">-- Pilih Motor --</option>
                                @foreach ($motors as $motor)
                                    <option value="{{ $motor['id'] }}"
                                        {{ old('motor_id') == $motor['id'] ? 'selected' : '' }}>
                                        {{ $motor['name'] }} ({{ $motor['brand'] }})
                                    </option>
                                @endforeach
                            </select>
                            <small class="error-message text-red-500" data-field="motor_id"></small>
                        </div>

                        <!-- Customer Name -->
                        <div>
                            <label for="customer_name" class="block text-gray-700 font-semibold mb-1">Nama
                                Pelanggan</label>
                            <input type="text" name="customer_name" id="customer_name"
                                placeholder="cth: Budi Santoso"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400 placeholder:text-sm placeholder-gray-500"
                                value="{{ old('customer_name') }}">
                            <small class="error-message text-red-500" data-field="customer_name"></small>
                        </div>

                        <!-- Start Date -->
                        <div>
                            <label for="start_date_date" class="block text-gray-700 font-semibold mb-1">Tanggal
                                Mulai</label>
                            <input type="date" name="start_date_date" id="start_date_date"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400 placeholder:text-sm placeholder-gray-500"
                                value="{{ old('start_date_date') }}">
                            <small class="error-message text-red-500" data-field="start_date_date"></small>
                        </div>

                        <!-- Jam Mulai -->
                        <div>
                            <label for="start_date_time" class="block text-gray-700 font-semibold mb-1">Jam Mulai</label>
                            <input type="time" name="start_date_time" id="start_date_time"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400 placeholder:text-sm placeholder-gray-500"
                                value="{{ old('start_date_time') }}">
                            <small class="error-message text-red-500" data-field="start_date_time"></small>
                        </div>

                        <!-- Duration -->
                        <div>
                            <label for="duration" class="block text-gray-700 font-semibold mb-1">Durasi (hari)</label>
                            <input type="number" name="duration" id="duration" placeholder="cth: 3" min="1"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400 placeholder:text-sm placeholder-gray-500"
                                value="{{ old('duration') }}">
                            <small class="error-message text-red-500" data-field="duration"></small>
                        </div>

                        <!-- Foto ID -->
                        <div>
                            <label for="photo_id" class="block text-gray-700 font-semibold mb-1">Foto Pelanggan
                                (Opsional)</label>
                            <input type="file" name="photo_id" id="photo_id"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                            <small class="error-message text-red-500" data-field="photo_id"></small>
                        </div>

                        <!-- Foto KTP -->
                        <div>
                            <label for="ktp_id" class="block text-gray-700 font-semibold mb-1">Foto KTP
                                (Opsional)</label>
                            <input type="file" name="ktp_id" id="ktp_id"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                            <small class="error-message text-red-500" data-field="ktp_id"></small>
                        </div>
                    </div>

                    <!-- Pickup Location -->
                    <div class="mt-6">
                        <label for="pickup_location" class="block text-gray-700 font-semibold mb-1">Lokasi Pengambilan</label>
                        <textarea name="pickup_location" id="pickup_location" rows="3"
                            placeholder="cth: Jalan Merdeka No. 12, Jakarta"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400 placeholder:text-sm placeholder-gray-500">{{ old('pickup_location') }}</textarea>
                        <small class="error-message text-red-500" data-field="pickup_location"></small>
                    </div>

                    <!-- Dropoff Location -->
                    <div class="mt-6">
                        <label for="dropoff_location" class="block text-gray-700 font-semibold mb-1">Lokasi Penjemputan
                            (Opsional)</label>
                        <textarea name="dropoff_location" id="dropoff_location" rows="3"
                            placeholder="cth: Jalan Sudirman No. 45, Bandung"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400 placeholder:text-sm placeholder-gray-500">{{ old('dropoff_location') }}</textarea>
                        <small class="error-message text-red-500" data-field="dropoff_location"></small>
                    </div>

                    <!-- Buttons -->
                    <div class="mt-8 flex flex-col sm:flex-row justify-end gap-4">
                        <button type="button" onclick="closeModal('addBookingModal')"
                            class="px-5 py-2.5 bg-gray-400 hover:bg-gray-500 text-white rounded-lg transition">Batal</button>
                        <button type="submit"
                            class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg shadow transition">Simpan</button>
                    </div>
                </form>
            </div>
        </div>


        <!-- CDN: SweetAlert & Bootstrap -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"
            integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous">
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.min.js"
            integrity="sha384-VQqxDN0EQCkWoxt/0vsQvZswzTHUVOImccYmSyhJTp7kGtPed0Qcx8rK9h9YEgx+" crossorigin="anonymous">
        </script>

        <script>
            const BASE_API = "{{ config('api.base_url') }}";

            // Menerjemahkan status ke Bahasa Indonesia
            function translateStatus(status) {
                switch (status) {
                    case 'pending':
                        return 'Menunggu Konfirmasi';
                    case 'confirmed':
                        return 'Dikonfirmasi';
                    case 'in transit':
                        return 'Motor Sedang Diantar';
                    case 'in use':
                        return 'Sedang Digunakan';
                    case 'awaiting return':
                        return 'Menunggu Pengembalian';
                    case 'completed':
                        return 'Pesanan Selesai';
                    case 'rejected':
                        return 'Booking Ditolak';
                    default:
                        return status.charAt(0).toUpperCase() + status.slice(1);
                }
            }

            // SweetAlert dari session
            @if (session('message'))
                Swal.fire({
                    icon: 'success',
                    title: 'Berhasil!',
                    text: '{{ session('message') }}',
                    confirmButtonColor: '#3085d6'
                });
            @endif

            @if (session('error'))
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: '{{ session('error') }}',
                    confirmButtonColor: '#d33'
                });
            @endif

            // Utility untuk format tanggal & waktu
            function formatDateTime(dt) {
                if (!dt) return '-';
                const d = new Date(dt);
                if (isNaN(d)) return dt;
                const date = d.toLocaleDateString('id-ID', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                });
                const time = d.toLocaleTimeString('id-ID', {
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: false
                }).replace(':', '.');
                return `${date} / ${time} WIB`;
            }

            function openModal(id) {
                const m = document.getElementById(id);
                if (m) {
                    m.classList.remove('hidden');
                    document.body.style.overflow = 'hidden';
                }
            }

            function closeModal(id) {
                const m = document.getElementById(id);
                if (m) {
                    m.classList.add('hidden');
                    document.body.style.overflow = 'auto';
                    m.querySelectorAll('.error-message').forEach(e => e.textContent = '');
                }
            }

            function closeBookingModal() {
                closeModal('bookingDetailModal');
            }

            // Tambahan fungsi notifikasi SweetAlert
            function showConfirmation(title, text, confirmText = 'Ya', cancelText = 'Batal') {
                return Swal.fire({
                    title: title,
                    text: text,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: confirmText,
                    cancelButtonText: cancelText
                });
            }

            function showSuccessAlert(message) {
                Swal.fire({
                    icon: 'success',
                    title: 'Berhasil!',
                    text: message,
                    confirmButtonColor: '#3085d6'
                });
            }

            function showErrorAlert(message) {
                Swal.fire({
                    icon: 'error',
                    title: 'Gagal!',
                    text: message,
                    confirmButtonColor: '#d33'
                });
            }

            // Update booking status
            function handleUpdateBooking(id, action) {
                let txt, url;
                switch (action) {
                    case 'confirm':
                        txt = 'setujui';
                        url = `${BASE_API}/vendor/bookings/${id}/confirm`;
                        break;
                    case 'reject':
                        txt = 'tolak';
                        url = `${BASE_API}/vendor/bookings/${id}/reject`;
                        break;
                    case 'transit':
                        txt = 'in transit';
                        url = `${BASE_API}/vendor/bookings/transit/${id}`;
                        break;
                    case 'inuse':
                        txt = 'in use';
                        url = `${BASE_API}/vendor/bookings/inuse/${id}`;
                        break;
                    case 'complete':
                        txt = 'selesaikan';
                        url = `${BASE_API}/vendor/bookings/complete/${id}`;
                        break;
                    default:
                        return showErrorAlert('Aksi tidak valid.');
                }

                showConfirmation('Konfirmasi', `Apakah Anda yakin ingin ${txt} booking ini?`, `Ya, ${txt}!`, 'Batal')
                    .then(res => {
                        if (!res.isConfirmed) return;
                        fetch(url, {
                                method: 'PUT',
                                headers: {
                                    "Authorization": "Bearer {{ session('token') }}",
                                    "Content-Type": "application/json"
                                }
                            })
                            .then(response => response.json())
                            .then(data => {
                                if (data.message) {
                                    showSuccessAlert(data.message);
                                } else {
                                    showSuccessAlert('Berhasil memperbarui status.');
                                }
                                setTimeout(() => location.reload(), 1500);
                            })
                            .catch(err => {
                                console.error(err);
                                showErrorAlert('Terjadi kesalahan: ' + err.message);
                            });
                    });
            }

            // Saat halaman siap
            document.addEventListener('DOMContentLoaded', () => {
                // Format semua elemen dengan class .format-datetime
                document.querySelectorAll('.format-datetime').forEach(el => {
                    el.textContent = formatDateTime(el.textContent.trim());
                });

                // Modal detail booking
                document.querySelectorAll('.open-booking-modal').forEach(link => {
                    link.addEventListener('click', e => {
                        e.preventDefault();
                        let data;
                        try {
                            data = JSON.parse(link.getAttribute('data-booking'));
                        } catch (err) {
                            console.error('JSON parse error:', err);
                            return;
                        }

                        document.getElementById('modalCustomerName').textContent = data.customer_name ||
                            '-';
                        document.getElementById('modalBookingDate').textContent = formatDateTime(data
                            .booking_date);
                        document.getElementById('modalStartDate').textContent = formatDateTime(data
                            .start_date);
                        document.getElementById('modalEndDate').textContent = formatDateTime(data
                            .end_date);
                        document.getElementById('modalPickup').textContent = data.pickup_location ||
                        '-';
                        // Gunakan translateStatus di sini
                        document.getElementById('modalStatus').textContent = translateStatus(data
                            .status || '-');

                        const imgEl = document.getElementById('modalCustomerPhoto');
                        imgEl.onerror = () => {
                            imgEl.onerror = null;
                            imgEl.src = '/images/default-user.png';
                        };
                        if (data.potoid) {
                            const isAbsolute = /^https?:\/\//i.test(data.potoid);
                            imgEl.src = isAbsolute ? data.potoid : `${BASE_API}${data.potoid}`;
                        } else {
                            imgEl.src = '/images/default-user.png';
                        }

                        openModal('bookingDetailModal');
                    });
                });

                // Validasi form manual booking
                document.getElementById('manualBookingForm')?.addEventListener('submit', e => {
                    const f = e.target;
                    f.querySelectorAll('.error-message').forEach(el => el.textContent = '');
                    let hasError = false;
                    const setError = (field, msg) => {
                        const el = f.querySelector(`.error-message[data-field="${field}"]`);
                        if (el) el.textContent = msg;
                        hasError = true;
                    };

                    const cn = f.customer_name.value.trim();
                    if (!cn) setError('customer_name', 'Nama pelanggan harus diisi.');
                    else if (cn.length < 3) setError('customer_name', 'Nama minimal 3 karakter.');
                    else if (!/^[a-zA-Z\s]+$/.test(cn)) setError('customer_name',
                        'Nama hanya boleh huruf dan spasi.');

                    if (!f.motor_id.value) setError('motor_id', 'Pilih motor terlebih dahulu.');
                    if (!f.start_date_date.value) setError('start_date_date', 'Tanggal mulai harus diisi.');
                    if (!f.start_date_time.value) setError('start_date_time', 'Waktu mulai harus diisi.');

                    const dur = parseInt(f.duration.value);
                    if (!dur || dur <= 0) setError('duration', 'Durasi harus lebih dari 0.');

                    if (!f.pickup_location.value.trim())
                        setError('pickup_location', 'Lokasi penjemputan harus diisi.');

                    [
                        ['ktp_file', 'KTP'],
                        ['photo_file', 'Foto']
                    ].forEach(([fld, label]) => {
                        const file = f[fld]?.files[0];
                        if (file) {
                            if (!['image/jpeg', 'image/png', 'image/jpg'].includes(file.type))
                                setError(fld, `File ${label} harus JPG atau PNG.`);
                            if (file.size > 2 * 1024 * 1024)
                                setError(fld, `Ukuran ${label} maksimal 2MB.`);
                        }
                    });

                    if (hasError) e.preventDefault();
                });
            });
        </script>

    @endsection
