@extends('layouts.app')

@section('title', 'Kelola Pemesanan')

@section('content')
    <!-- Include SweetAlert2 dari CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-k6d4wzSIapyDyv1kpU366/PK5hCdSbCRGRCMv+eplOQJWyd1fbcAu9OCUj5zNLiq" crossorigin="anonymous">
    </script>


    <div class="container mx-auto p-8">
        <h2 class="text-4xl font-extrabold mb-6 text-center text-gray-800">📋 Kelola Pemesanan</h2>

        <!-- Nav Filter Menggunakan Bootstrap Nav-Pills -->
        <ul class="nav nav-pills justify-content-center mb-4" id="statusTabs">
            <li class="nav-item">
                <a class="nav-link active" data-filter="all" href="#">Semua</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-filter="pending" href="#">Menunggu Konfirmasi</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-filter="confirmed" href="#">Dikonfirmasi</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-filter="in transit" href="#">Motor Sedang Diantar</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-filter="in use" href="#">Sedang Digunakan</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-filter="awaiting return" href="#">Menunggu Pengembalian</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-filter="completed" href="#">Pesanan Selesai</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-filter="rejected" href="#">Booking Ditolak</a>
            </li>
        </ul>

        <!-- Button untuk Booking Manual -->
        <div class="mb-6 flex justify-end">
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

                                <!-- Detail Pemesanan -->
                                <td class="py-3 px-4 text-left align-top">
                                    <div><strong>Customer:</strong> {{ $pesanan['customer_name'] ?? '-' }}</div>
                                    <div><strong>Tanggal Booking:</strong> {{ $pesanan['booking_date'] ?? '-' }}</div>
                                    <div><strong>Tanggal Mulai:</strong> {{ $pesanan['start_date'] ?? '-' }}</div>
                                    <div><strong>Tanggal Selesai:</strong> {{ $pesanan['end_date'] ?? '-' }}</div>
                                    <div><strong>Lokasi Jemput:</strong> {{ $pesanan['pickup_location'] ?? '-' }}</div>
                                </td>

                                <!-- Detail Motor -->
                                <td class="py-3 px-4 text-left align-top">
                                    @if (isset($pesanan['motor']))
                                        <div><strong>Nama:</strong> {{ $pesanan['motor']['name'] ?? '-' }}</div>
                                        <div><strong>Brand:</strong> {{ $pesanan['motor']['brand'] ?? '-' }}</div>
                                        <div><strong>Model:</strong> {{ $pesanan['motor']['model'] ?? '-' }}</div>
                                        <div><strong>Tahun:</strong> {{ $pesanan['motor']['year'] ?? '-' }}</div>
                                        <div><strong>Warna:</strong> {{ $pesanan['motor']['warna'] ?? '-' }}</div>
                                    @else
                                        <div>Data motor tidak tersedia.</div>
                                    @endif
                                </td>

                                <!-- Gambar Motor -->
                                <td class="py-3 px-4 text-center align-top">
                                    @if (isset($pesanan['motor']['image']))
                                        <img src="{{ $pesanan['motor']['image'] }}" alt="Motor"
                                            class="w-30 h-30 object-cover rounded mx-auto">
                                    @else
                                        <span class="text-gray-400">-</span>
                                    @endif
                                </td>

                                <!-- Status -->
                                <td class="py-3 px-4 text-center align-top">
                                    <strong
                                        class="
                                        @if ($pesanan['status'] == 'pending') text-yellow-600
                                        @elseif($pesanan['status'] == 'confirmed') text-blue-600
                                        @elseif($pesanan['status'] == 'in transit') text-indigo-600
                                        @elseif($pesanan['status'] == 'in use') text-purple-600
                                        @elseif($pesanan['status'] == 'awaiting return') text-orange-600
                                        @elseif($pesanan['status'] == 'completed') text-green-600
                                        @elseif($pesanan['status'] == 'rejected') text-red-600
                                        @else text-gray-600 @endif
                                    ">
                                        @if ($pesanan['status'] == 'pending')
                                            Menunggu Konfirmasi
                                        @elseif($pesanan['status'] == 'confirmed')
                                            Dikonfirmasi
                                        @elseif($pesanan['status'] == 'in transit')
                                            Motor Sedang Diantar
                                        @elseif($pesanan['status'] == 'in use')
                                            Sedang Digunakan
                                        @elseif($pesanan['status'] == 'awaiting return')
                                            Menunggu Pengembalian
                                        @elseif($pesanan['status'] == 'completed')
                                            Pesanan Selesai
                                        @elseif($pesanan['status'] == 'rejected')
                                            Booking Ditolak
                                        @else
                                            {{ ucfirst($pesanan['status']) }}
                                        @endif
                                    </strong>
                                </td>

                                <!-- Aksi -->
                                <td class="py-3 px-4 text-center align-top">
                                    @if ($pesanan['status'] == 'pending')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'confirm')"
                                            class="bg-green-600 text-white px-3 py-1 rounded-lg">Setujui</button>
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'reject')"
                                            class="bg-red-600 text-white px-3 py-1 rounded-lg">Tolak</button>
                                    @elseif ($pesanan['status'] == 'confirmed')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'transit')"
                                            class="bg-blue-600 text-white px-3 py-1 rounded-lg">Antar Motor</button>
                                    @elseif ($pesanan['status'] == 'in transit')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'inuse')"
                                            class="bg-indigo-600 text-white px-3 py-1 rounded-lg">Sedang
                                            Berlangsung</button>
                                    @elseif ($pesanan['status'] == 'in use' || $pesanan['status'] == 'awaiting return')
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

        <!-- Modal untuk Booking Manual -->
        <div id="addBookingModal"
            class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center z-50">
            <div class="bg-white rounded-xl shadow-xl w-full max-w-3xl p-8 relative">
                <h2 class="text-2xl font-bold mb-6 text-gray-800">Tambah Booking Manual</h2>
                <form action="{{ route('vendor.manual.booking.store') }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Dropdown Motor -->
                        <div>
                            <label for="motor_id" class="block text-gray-700 font-semibold mb-1">Pilih Motor</label>
                            <select name="motor_id" id="motor_id"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required>
                                <option value="">-- Pilih Motor --</option>
                                @foreach ($motors as $motor)
                                    <option value="{{ $motor['id'] }}">
                                        {{ $motor['name'] }} ({{ $motor['brand'] }})
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Customer Name -->
                        <div>
                            <label for="customer_name" class="block text-gray-700 font-semibold mb-1">Nama Pelanggan</label>
                            <input type="text" name="customer_name" id="customer_name"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required>
                        </div>

                        <!-- Start Date -->
                        <div>
                            <label for="start_date_date" class="block text-gray-700 font-semibold mb-1">Tanggal
                                Mulai</label>
                            <input type="date" name="start_date_date" id="start_date_date"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required>
                        </div>

                        <!-- Jam Mulai -->
                        <div>
                            <label for="start_date_time" class="block text-gray-700 font-semibold mb-1">Jam Mulai</label>
                            <input type="time" name="start_date_time" id="start_date_time"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required>
                        </div>

                        <!-- Duration -->
                        <div>
                            <label for="duration" class="block text-gray-700 font-semibold mb-1">Durasi (hari)</label>
                            <input type="number" name="duration" id="duration" min="1"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required>
                        </div>

                        <!-- Foto ID -->
                        <div>
                            <label for="photo_id" class="block text-gray-700 font-semibold mb-1">Foto ID
                                (Opsional)</label>
                            <input type="file" name="photo_id" id="photo_id"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                        </div>

                        <!-- Foto KTP -->
                        <div>
                            <label for="ktp_id" class="block text-gray-700 font-semibold mb-1">Foto KTP
                                (Opsional)</label>
                            <input type="file" name="ktp_id" id="ktp_id"
                                class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                        </div>
                    </div>

                    <!-- Pickup Location -->
                    <div class="mt-6">
                        <label for="pickup_location" class="block text-gray-700 font-semibold mb-1">Pickup
                            Location</label>
                        <textarea name="pickup_location" id="pickup_location"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" rows="3" required></textarea>
                    </div>

                    <!-- Dropoff Location -->
                    <div class="mt-6">
                        <label for="dropoff_location" class="block text-gray-700 font-semibold mb-1">Dropoff Location
                            (Opsional)</label>
                        <textarea name="dropoff_location" id="dropoff_location"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" rows="3"></textarea>
                    </div>

                    <!-- Buttons -->
                    <div class="mt-8 flex justify-end gap-4">
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
    </div>

    <!-- SweetAlert Notifikasi -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    @if (session('message'))
        <script>
            Swal.fire({
                icon: 'success',
                title: 'Berhasil!',
                text: '{{ session('message') }}',
                confirmButtonColor: '#3085d6'
            });
        </script>
    @endif

    @if (session('error'))
        <script>
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: '{{ session('error') }}',
                confirmButtonColor: '#d33'
            });
        </script>
    @endif

    <!-- JavaScript functions untuk modal, aksi, dan filter menggunakan nav -->
    <script>
        // Pengaturan waktu minimal untuk start_date_time jika tanggal hari ini dipilih
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
                timeInput.min = hours + ":" + minutes;
            } else {
                timeInput.removeAttribute("min");
            }
        });

        const BASE_API = "http://localhost:8080";

        // Fungsi SweetAlert untuk konfirmasi dan notifikasi
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

        // Fungsi update booking untuk semua aksi: confirm, reject, transit, inuse, complete
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
                            .catch(error => showErrorAlert("Terjadi kesalahan: " + error.message));
                    }
                });
        }

        // Fungsi untuk membuka dan menutup modal
        function openModal(modalId) {
            document.getElementById(modalId).classList.remove("hidden");
            document.body.style.overflow = "hidden";
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.add("hidden");
            document.body.style.overflow = "";
        }

        // Filter menggunakan nav Bootstrap
        const statusTabs = document.querySelectorAll("#statusTabs a");
        statusTabs.forEach(tab => {
            tab.addEventListener("click", function(e) {
                e.preventDefault();
                // Hapus kelas active dari semua tab
                statusTabs.forEach(t => t.classList.remove("active"));
                // Tambahkan kelas active pada tab yang diklik
                this.classList.add("active");

                const filter = this.getAttribute("data-filter");
                document.querySelectorAll("tbody tr").forEach(row => {
                    row.style.display = filter === "all" || row.getAttribute("data-status") ===
                        filter ? "" : "none";
                });
            });
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"
        integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous">
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.min.js"
        integrity="sha384-VQqxDN0EQCkWoxt/0vsQvZswzTHUVOImccYmSyhJTp7kGtPed0Qcx8rK9h9YEgx+" crossorigin="anonymous">
    </script>
@endsection
