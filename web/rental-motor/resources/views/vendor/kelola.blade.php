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
            <form method="GET" class="flex items-center gap-2">
                <label for="status" class="text-sm font-medium">Filter Status:</label>
                <div class="relative w-60">
                    
                    <select id="status" name="status" onchange="this.form.submit()"
                        class="block w-full pl-10 pr-4 py-2 border rounded bg-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
                        <option value="all" {{ request('status', 'all') == 'all' ? 'selected' : '' }}>
                            Semua Status
                        </option>
                        <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>
                            Menunggu Konfirmasi
                        </option>
                        <option value="confirmed" {{ request('status') == 'confirmed' ? 'selected' : '' }}>
                            Dikonfirmasi
                        </option>
                        <option value="in transit" {{ request('status') == 'in transit' ? 'selected' : '' }}>
                            Motor Sedang Diantar
                        </option>
                        <option value="in use" {{ request('status') == 'in use' ? 'selected' : '' }}>
                            Sedang Digunakan
                        </option>
                        <option value="awaiting return" {{ request('status') == 'awaiting return' ? 'selected' : '' }}>
                            Menunggu Pengembalian
                        </option>
                        <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>
                            Pesanan Selesai
                        </option>
                        <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>
                            Booking Ditolak
                        </option>
                    </select>
                </div>
            </form>

            <!-- Tombol Booking Manual -->
            <button onclick="openModal('addBookingModal')"
                class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
                + Booking Manual
            </button>
        </div>




        @if (empty($bookings) || count($bookings) == 0)
            <p class="text-center text-gray-500">Tidak ada pemesanan untuk ditampilkan.</p>
        @else
            <div class="overflow-x-auto">
                <table class="min-w-full bg-white shadow-md rounded-lg table-fixed">
                    <thead>
                        <tr class="bg-gray-200 text-gray-600 uppercase text-sm leading-normal">
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
                            <tr class="border-b border-gray-200 hover:bg-gray-100" data-status="{{ $pesanan['status'] }}">
                                <td class="py-3 px-4 text-center align-top">{{ $loop->iteration }}</td>

                                <td class="py-4 px-6 text-left align-top">
                                    <div class="space-y-2 text-gray-700">
                                        <div>
                                            <span class="font-bold text-gray-900">Customer:</span>
                                            <span
                                                class="text-blue-600 ; font-semibold">{{ $pesanan['customer_name'] ?? '-' }}</span>
                                        </div>

                                        <div>
                                            <span class="font-bold text-gray-900">Tanggal Booking:</span>
                                            <span class="format-datetime ">{{ $pesanan['booking_date'] ?? '-' }}</span>
                                        </div>

                                        <div>
                                            <span class="font-bold text-gray-900">Tanggal Mulai:</span>
                                            <span class="format-datetime ">{{ $pesanan['start_date'] ?? '-' }}</span>
                                        </div>

                                        <div>
                                            <span class="font-bold text-gray-900">Tanggal Selesai:</span>
                                            <span class="format-datetime">{{ $pesanan['end_date'] ?? '-' }}</span>
                                        </div>

                                        <div>
                                            <span class="font-bold text-gray-900">Lokasi Jemput:</span>
                                            <span>{{ $pesanan['pickup_location'] ?? '-' }}</span>
                                        </div>
                                    </div>
                                </td>

                                <!-- Detail Motor -->
                                <td class="py-3 px-4 text-left align-top">
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

                                <!-- Aksi -->
                                <td class="py-3 px-4 text-center">
                                    @if ($s == 'pending')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'confirm')"
                                            class="bg-green-600 text-white px-3 py-1 rounded-lg">Setujui</button>
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'reject')"
                                            class="bg-red-600 text-white px-3 py-1 rounded-lg">Tolak</button>
                                    @elseif ($s == 'confirmed')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'transit')"
                                            class="bg-blue-600 text-white px-3 py-1 rounded-lg">Antar Motor</button>
                                    @elseif ($s == 'in transit')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'inuse')"
                                            class="bg-indigo-600 text-white px-3 py-1 rounded-lg">Sedang
                                            Berlangsung</button>
                                    @elseif (in_array($s, ['in use', 'awaiting return']))
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'complete')"
                                            class="bg-green-600 text-white px-3 py-1 rounded-lg">Motor Kembali</button>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif

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
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12">
                        </path>
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
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400">
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
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
                                value="{{ old('customer_name') }}">
                            <small class="error-message text-red-500" data-field="customer_name"></small>
                        </div>

                        <!-- Start Date -->
                        <div>
                            <label for="start_date_date" class="block text-gray-700 font-semibold mb-1">Tanggal
                                Mulai</label>
                            <input type="date" name="start_date_date" id="start_date_date"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
                                value="{{ old('start_date_date') }}">
                            <small class="error-message text-red-500" data-field="start_date_date"></small>
                        </div>

                        <!-- Jam Mulai -->
                        <div>
                            <label for="start_date_time" class="block text-gray-700 font-semibold mb-1">Jam Mulai</label>
                            <input type="time" name="start_date_time" id="start_date_time"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
                                value="{{ old('start_date_time') }}">
                            <small class="error-message text-red-500" data-field="start_date_time"></small>
                        </div>

                        <!-- Duration -->
                        <div>
                            <label for="duration" class="block text-gray-700 font-semibold mb-1">Durasi (hari)</label>
                            <input type="number" name="duration" id="duration" min="1"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
                                value="{{ old('duration') }}">
                            <small class="error-message text-red-500" data-field="duration"></small>
                        </div>

                        <!-- Foto ID -->
                        <div>
                            <label for="photo_id" class="block text-gray-700 font-semibold mb-1">Foto ID
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
                        <label for="pickup_location" class="block text-gray-700 font-semibold mb-1">Pickup
                            Location</label>
                        <textarea name="pickup_location" id="pickup_location"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" rows="3">{{ old('pickup_location') }}</textarea>
                        <small class="error-message text-red-500" data-field="pickup_location"></small>
                    </div>

                    <!-- Dropoff Location -->
                    <div class="mt-6">
                        <label for="dropoff_location" class="block text-gray-700 font-semibold mb-1">Dropoff Location
                            (Opsional)</label>
                        <textarea name="dropoff_location" id="dropoff_location"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" rows="3">{{ old('dropoff_location') }}</textarea>
                        <small class="error-message text-red-500" data-field="dropoff_location"></small>
                    </div>

                    <!-- Buttons -->
                    <div class="mt-8 flex flex-col sm:flex-row justify-end gap-4">
                        <button type="button" onclick="closeModal('addBookingModal')"
                            class="px-5 py-2.5 bg-gray-400 hover:bg-gray-500 text-white rounded-lg transition">
                            Batal
                        </button>
                        <button type="submit"
                            class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg shadow transition">
                            Simpan
                        </button>
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


            document.addEventListener("DOMContentLoaded", function() {
                const dateInput = document.getElementById("start_date_date");
                const today = new Date();
                const todayString = today.toISOString().split('T')[0];
                dateInput.setAttribute("min", todayString);


                document.querySelectorAll('.format-datetime').forEach(el => {
                    const originalText = el.textContent.trim();
                    el.textContent = formatDateTime(originalText);
                });
            });


            document.getElementById("start_date_date").addEventListener("change", function() {
                const dateInput = this.value;
                const today = new Date();
                const todayString = today.toISOString().split('T')[0];
                const timeInput = document.getElementById("start_date_time");

                if (dateInput === todayString) {
                    let hours = today.getHours();
                    let minutes = today.getMinutes();
                    hours = hours < 10 ? "0" + hours : hours;
                    minutes = minutes < 10 ? "0" + minutes : minutes;
                    timeInput.min = `${hours}:${minutes}`;
                } else {
                    timeInput.removeAttribute("min");
                }
            });

            // SweetAlert Wrapper
            function showConfirmation(title, text, confirmText, cancelText) {
                return Swal.fire({
                    title: title,
                    text: text,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: confirmText,
                    cancelButtonText: cancelText
                });
            }

            function showSuccessAlert(message) {
                Swal.fire({
                    title: 'Berhasil!',
                    text: message,
                    icon: 'success',
                    confirmButtonColor: '#3085d6'
                });
            }

            function showErrorAlert(message) {
                Swal.fire({
                    title: 'Error!',
                    text: message,
                    icon: 'error',
                    confirmButtonColor: '#d33'
                });
            }

            function formatDateTime(dateTimeString) {
                if (!dateTimeString || dateTimeString === "-") return "-";

                const date = new Date(dateTimeString);
                if (isNaN(date.getTime())) return dateTimeString;

                const formattedDate = date.toLocaleDateString('id-ID', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                });

                const formattedTime = date.toLocaleTimeString('id-ID', {
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit'
                });

                return `${formattedDate} / ${formattedTime}`;
            }

            document.addEventListener('DOMContentLoaded', () => {
                document.querySelectorAll('.format-datetime').forEach(el => {
                    const originalText = el.textContent.trim();
                    el.textContent = formatDateTime(originalText);
                });
            });

            document.addEventListener('DOMContentLoaded', () => {
                document.querySelectorAll('.format-datetime').forEach(el => {
                    const originalText = el.textContent.trim();
                    el.textContent = formatDateTime(originalText);
                });
            });

            document.getElementById('statusFilter').addEventListener('change', function() {
                const selected = this.value;
                const rows = document.querySelectorAll('tbody tr');

                rows.forEach(row => {
                    const status = row.getAttribute('data-status');
                    if (selected === 'all' || status === selected) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });

            // Update Status Booking
            function handleUpdateBooking(bookingId, action) {
                let actionText = '';
                let endpoint = '';

                switch (action) {
                    case 'confirm':
                        actionText = 'setujui';
                        endpoint = `${BASE_API}/vendor/bookings/${bookingId}/confirm`;
                        break;
                    case 'reject':
                        actionText = 'tolak';
                        endpoint = `${BASE_API}/vendor/bookings/${bookingId}/reject`;
                        break;
                    case 'transit':
                        actionText = 'ubah status menjadi in transit';
                        endpoint = `${BASE_API}/vendor/bookings/transit/${bookingId}`;
                        break;
                    case 'inuse':
                        actionText = 'ubah status menjadi in use';
                        endpoint = `${BASE_API}/vendor/bookings/inuse/${bookingId}`;
                        break;
                    case 'complete':
                        actionText = 'selesaikan';
                        endpoint = `${BASE_API}/vendor/bookings/complete/${bookingId}`;
                        break;
                    default:
                        actionText = action;
                }

                showConfirmation('Konfirmasi', `Apakah Anda yakin ingin ${actionText} booking ini?`, `Ya, ${actionText}!`,
                        'Batal')
                    .then((result) => {
                        if (result.isConfirmed) {
                            fetch(endpoint, {
                                    method: "PUT",
                                    headers: {
                                        "Authorization": "Bearer {{ session('token') }}",
                                        "Content-Type": "application/json"
                                    }
                                })
                                .then(response => response.json())
                                .then(data => {
                                    showSuccessAlert(data.message);
                                    setTimeout(() => location.reload(), 1500);
                                })
                                .catch(error => {
                                    showErrorAlert("Terjadi kesalahan: " + error.message);
                                });
                        }
                    });
            }

            // Modal Control
            function openModal(modalId) {
                const modal = document.getElementById(modalId);

                // Hapus pesan error sebelum membuka modal
                const errorMessages = modal.querySelectorAll('.error-message');
                errorMessages.forEach(el => el.textContent = ''); // Clear error messages

                modal.classList.remove("hidden");
                document.body.style.overflow = "hidden";
            }

            function closeModal(modalId) {
                const modal = document.getElementById(modalId);
                modal.classList.add("hidden");
                document.body.style.overflow = "auto";

                const form = modal.querySelector("form");
                if (form) {
                    form.reset();
                }

                const errorMessages = modal.querySelectorAll(".error-message");
                errorMessages.forEach(el => el.textContent = '');

                const timeInput = modal.querySelector("#start_date_time");
                if (timeInput) {
                    timeInput.removeAttribute("min");
                }
            }


            // ========== VALIDASI & SUBMIT: MANUAL BOOKING ===========
            document.getElementById('manualBookingForm')?.addEventListener('submit', function(event) {
                const form = event.target;
                const errorMessages = form.querySelectorAll('.error-message');
                errorMessages.forEach(el => el.textContent = '');

                const customerName = form.customer_name.value.trim();
                const motorId = form.motor_id.value;
                const startDate = form.start_date_date.value;
                const startTime = form.start_date_time.value;
                const duration = parseInt(form.duration.value);
                const pickup = form.pickup_location.value.trim();
                const fileKTP = form.ktp_file?.files[0]; // optional
                const fileFoto = form.photo_file?.files[0]; // optional

                let hasError = false;

                function setError(field, message) {
                    const el = form.querySelector(`.error-message[data-field="${field}"]`);
                    if (el) el.textContent = message;
                    hasError = true;
                }

                if (!customerName) setError('customer_name', 'Nama pelanggan harus diisi.');
                else if (customerName.length < 3) setError('customer_name', 'Nama minimal 3 karakter.');

                if (!motorId) setError('motor_id', 'Pilih motor terlebih dahulu.');

                if (!startDate) setError('start_date_date', 'Tanggal mulai harus diisi.');
                if (!startTime) setError('start_date_time', 'Waktu mulai harus diisi.');

                if (!duration || duration <= 0) setError('duration', 'Durasi harus lebih dari 0.');

                if (!pickup) setError('pickup_location', 'Lokasi penjemputan harus diisi.');

                // Optional: Validasi file KTP dan Foto
                const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
                if (fileKTP) {
                    if (!allowedTypes.includes(fileKTP.type)) setError('ktp_file', 'File KTP harus JPG atau PNG.');
                    if (fileKTP.size > 2 * 1024 * 1024) setError('ktp_file', 'Ukuran KTP maksimal 2MB.');
                }

                if (fileFoto) {
                    if (!allowedTypes.includes(fileFoto.type)) setError('photo_file', 'File Foto harus JPG atau PNG.');
                    if (fileFoto.size > 2 * 1024 * 1024) setError('photo_file', 'Ukuran Foto maksimal 2MB.');
                }

                if (hasError) {
                    event.preventDefault();
                    return;
                }
            });
        </script>
    @endsection
