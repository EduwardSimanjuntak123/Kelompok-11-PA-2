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
                            {{-- @dd($bookings) --}}
                            <tr class="border-b border-gray-200 hover:bg-gray-100" data-status="{{ $pesanan['status'] }}">
                                <td class="py-3 px-4 text-center align-top">{{ $loop->iteration }}</td>

                                <td class="py-4 px-6 text-left align-top">
                                    <a href="javascript:void(0)"
                                        class="text-blue-600 font-semibold hover:underline open-booking-modal"
                                        data-booking='@json(array_merge($pesanan, [
                                                'potoid' => $pesanan['potoid'] ? url("storage/{$pesanan['potoid']}") : null,
                                            ]),
                                            JSON_UNESCAPED_SLASHES)'>
                                        {{ $pesanan['customer_name'] ?? '-' }}
                                    </a>
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

        <!-- Modal Detail Pemesanan -->
        <div id="bookingDetailModal"
            class="fixed inset-0 z-50 hidden bg-black bg-opacity-50 flex items-center justify-center px-4">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-3xl p-6 overflow-y-auto max-h-[90vh] relative">
                <button type="button" onclick="closeBookingModal()"
                    class="absolute top-4 right-4 text-gray-600 hover:text-gray-800">×</button>
                <div class="flex flex-col md:flex-row gap-6">
                    <div class="w-full md:w-1/3">
                        <img id="modalCustomerPhoto" src="" alt="Foto Customer"
                            class="w-full h-auto object-cover rounded-lg shadow-md" />
                    </div>
                    <div class="w-full md:w-2/3 text-gray-700 space-y-3">
                        <h3 class="text-xl font-bold" id="modalCustomerName"></h3>
                        <p><strong>Booking:</strong> <span id="modalBookingDate"></span></p>
                        <p><strong>Mulai:</strong> <span id="modalStartDate"></span></p>
                        <p><strong>Akhir:</strong> <span id="modalEndDate"></span></p>
                        <p><strong>Jemput:</strong> <span id="modalPickup"></span></p>
                        <p><strong>Status:</strong> <span id="modalStatus"></span></p>
                        <div id="modalNoteContainer"></div>
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
                        <textarea name="pickup_location" id="pickup_location" rows="3"
                            placeholder="cth: Jalan Merdeka No. 12, Jakarta"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400 placeholder:text-sm placeholder-gray-500">{{ old('pickup_location') }}</textarea>
                        <small class="error-message text-red-500" data-field="pickup_location"></small>
                    </div>

                    <!-- Dropoff Location -->
                    <div class="mt-6">
                        <label for="dropoff_location" class="block text-gray-700 font-semibold mb-1">Dropoff Location
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

            // Utility
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

            function showConfirmation(t, txt, ok, cancel) {
                return Swal.fire({
                    title: t,
                    text: txt,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: ok,
                    cancelButtonText: cancel
                });
            }

            function showSuccessAlert(msg) {
                Swal.fire({
                    icon: 'success',
                    title: 'Berhasil!',
                    text: msg,
                    confirmButtonColor: '#3085d6'
                });
            }

            function showErrorAlert(msg) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: msg,
                    confirmButtonColor: '#d33'
                });
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

            // Main
            document.addEventListener('DOMContentLoaded', () => {
                // Format tanggal dalam .format-datetime
                document.querySelectorAll('.format-datetime').forEach(el => {
                    el.textContent = formatDateTime(el.textContent.trim());
                });

                // Set min date untuk date picker
                const dateInput = document.getElementById('start_date_date');
                if (dateInput) {
                    const today = new Date().toISOString().split('T')[0];
                    dateInput.setAttribute('min', today);
                    dateInput.addEventListener('change', function() {
                        const ti = document.getElementById('start_date_time');
                        if (this.value === new Date().toISOString().split('T')[0]) {
                            const now = new Date();
                            ti.min = now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes()
                                .toString().padStart(2, '0');
                        } else ti.removeAttribute('min');
                    });
                }

                // Filter status
                document.getElementById('statusFilter')?.addEventListener('change', function() {
                    document.querySelectorAll('tbody tr').forEach(r => {
                        r.style.display = (this.value === 'all' || r.dataset.status === this.value) ?
                            '' : 'none';
                    });
                });

                // Open booking-detail modal
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

                        // Debugging
                        console.log('RAW potoid:', data.potoid);

                        // Isi field modal
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
                        document.getElementById('modalStatus').textContent = data.status || '-';

                        // Gambar dengan handler onerror sekali saja
                        const imgEl = document.getElementById('modalCustomerPhoto');
                        imgEl.onerror = function() {
                            console.warn('Image load failed, fallback to default');
                            imgEl.onerror = null;
                            imgEl.src = '/images/default-user.png';
                        };
                        if (data.potoid) {
                            imgEl.src = data.potoid;
                        } else {
                            console.log('potoid kosong, langsung fallback');
                            imgEl.onerror();
                        }
                        console.log('SET img.src =', imgEl.src);

                        // Catatan
                        const noteEl = document.getElementById('modalNoteContainer');
                        noteEl.innerHTML = data.note ? `<p><strong>Catatan:</strong> ${data.note}</p>` :
                            '';

                        openModal('bookingDetailModal');
                    });
                });

                // Validasi manual booking
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
                    if (!f.motor_id.value) setError('motor_id', 'Pilih motor terlebih dahulu.');
                    if (!f.start_date_date.value) setError('start_date_date', 'Tanggal mulai harus diisi.');
                    if (!f.start_date_time.value) setError('start_date_time', 'Waktu mulai harus diisi.');
                    const dur = parseInt(f.duration.value);
                    if (!dur || dur <= 0) setError('duration', 'Durasi harus lebih dari 0.');
                    if (!f.pickup_location.value.trim()) setError('pickup_location',
                        'Lokasi penjemputan harus diisi.');

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
                                    "Authorization": `Bearer {{ session('token') }}`,
                                    "Content-Type": "application/json"
                                }
                            })
                            .then(r => r.json()).then(d => {
                                showSuccessAlert(d.message);
                                setTimeout(() => location.reload(), 1500);
                            })
                            .catch(err => showErrorAlert('Terjadi kesalahan: ' + err.message));
                    });
            }
        </script>

    @endsection
