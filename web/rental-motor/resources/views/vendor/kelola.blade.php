@extends('layouts.app')

@section('title', 'Kelola Pemesanan')

@section('content')
    <!-- Include SweetAlert2 from CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <div class="container mx-auto p-8">
        <h2 class="text-4xl font-extrabold mb-6 text-center text-gray-800">📋 Kelola Pemesanan</h2>

        <div class="mb-6 flex justify-between items-center">
            <select id="filterStatus" class="border p-2 rounded-md">
                <option value="all">Semua</option>
                <option value="pending">Pending</option>
                <option value="confirmed">Confirmed</option>
                <option value="completed">Completed</option>
                <option value="rejected">Rejected</option>
            </select>
           <!-- Button untuk booking manual -->
<button onclick="openModal('addTransactionModal')"
class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
+ Booking Manual
</button>
</div>
{{-- @dd($bookings) --}}
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
                        @if(isset($pesanan['motor']))
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
                        @if(isset($pesanan['motor']['image']))
                            <img src="{{ $pesanan['motor']['image'] }}" alt="Motor"
                                class="w-30 h-30 object-cover rounded mx-auto">
                        @else
                            <span class="text-gray-400">-</span>
                        @endif
                    </td>

                    <!-- Status -->
                    <td class="py-3 px-4 text-center align-top">
                        <strong
                            class="{{ $pesanan['status'] == 'pending' ? 'text-yellow-600' : ($pesanan['status'] == 'rejected' ? 'text-red-600' : 'text-green-600') }}">
                            {{ ucfirst($pesanan['status']) }}
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
                            <button onclick="handleCompleteBooking({{ $pesanan['id'] }})"
                                class="bg-blue-600 text-white px-3 py-1 rounded-lg">Selesaikan</button>
                        @endif
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>

    </div>
@endif



    <!-- Modal for Manual Booking -->
    <div id="addTransactionModal"
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
                        <label for="start_date" class="block text-gray-700 font-semibold mb-1">Start Date</label>
                        <input type="datetime-local" name="start_date" id="start_date"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" step="1" required>
                    </div>

                    <!-- End Date -->
                    <div>
                        <label for="end_date" class="block text-gray-700 font-semibold mb-1">End Date</label>
                        <input type="datetime-local" name="end_date" id="end_date"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" step="1" required>
                    </div>

                    <!-- Foto ID -->
                    <div>
                        <label for="photo_id" class="block text-gray-700 font-semibold mb-1">Foto ID (Opsional)</label>
                        <input type="file" name="photo_id" id="photo_id"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                    </div>

                    <!-- Foto KTP -->
                    <div>
                        <label for="ktp_id" class="block text-gray-700 font-semibold mb-1">Foto KTP (Opsional)</label>
                        <input type="file" name="ktp_id" id="ktp_id"
                            class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400">
                    </div>
                </div>

                <!-- Pickup Location (Full Width) -->
                <div class="mt-6">
                    <label for="pickup_location" class="block text-gray-700 font-semibold mb-1">Pickup Location</label>
                    <textarea name="pickup_location" id="pickup_location"
                        class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" rows="3" required></textarea>
                </div>

                <!-- Buttons -->
                <div class="mt-8 flex justify-end gap-4">
                    <button type="button" onclick="closeModal('addTransactionModal')"
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




    <!-- JavaScript functions for modal and actions -->
    <script>
        const BASE_API = "http://localhost:8080";

        // Fungsi SweetAlert untuk konfirmasi dan alert hasil aksi
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

        // Update booking (confirm atau reject)
        function handleUpdateBooking(bookingId, action) {
            let actionText = action === 'confirm' ? 'setujui' : 'tolak';
            showConfirmation('Konfirmasi', `Apakah Anda yakin ingin ${actionText} booking ini?`, `Ya, ${actionText}!`,
                    'Batal')
                .then((result) => {
                    if (result.isConfirmed) {
                        fetch(`${BASE_API}/vendor/bookings/${bookingId}/${action}`, {
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

        // Complete booking
        function handleCompleteBooking(bookingId) {
            showConfirmation('Konfirmasi', "Apakah Anda yakin ingin menyelesaikan booking ini?", "Ya, selesaikan!", "Batal")
                .then((result) => {
                    if (result.isConfirmed) {
                        fetch(`${BASE_API}/vendor/bookings/complete/${bookingId}`, {
                                method: "PUT",
                                headers: {
                                    "Authorization": "Bearer {{ session('token') }}",
                                    "Content-Type": "application/json"
                                }
                            })
                            .then(response => response.json())
                            .then(data => {
                                showSuccessAlert("Booking berhasil diselesaikan!");
                                setTimeout(() => location.reload(), 1500);
                            })
                            .catch(error => showErrorAlert("Terjadi kesalahan: " + error.message));
                    }
                });
        }

        function showFullDetails(pesanan) {
        // Tampilkan detail pemesanan
        document.getElementById("detailCustomer").textContent = pesanan.customer_name || "-";
        document.getElementById("detailBookingDate").textContent = pesanan.booking_date || "-";
        document.getElementById("detailStart").textContent = pesanan.start_date || "-";
        document.getElementById("detailEnd").textContent = pesanan.end_date || "-";
        document.getElementById("detailPickupLocation").textContent = pesanan.pickup_location || "-";
        openModal("bookingDetailModal");

        // Tampilkan detail motor jika ada
        const motor = pesanan.motor;
        if (motor) {
            document.getElementById("detailMotor").textContent = motor.name || ((motor.brand || "-") + " " + (motor.model || "-"));
            document.getElementById("detailBrand").textContent = motor.brand || "-";
            document.getElementById("detailModel").textContent = motor.model || "-";
            document.getElementById("detailYear").textContent = motor.year || "-";
            document.getElementById("detailPricePerDay").textContent = motor.price_per_day ? motor.price_per_day.toLocaleString() : "0";
            document.getElementById("detailMotorImage").src = motor.image || "https://via.placeholder.com/150";
            openModal("motorDetailModal");
        } else {
            showErrorAlert("Data motor tidak tersedia.");
        }
    }

    function closeBookingModal() {
        closeModal("bookingDetailModal");
    }

    function closeMotorModal() {
        closeModal("motorDetailModal");
    }

    function openModal(modalId) {
        document.getElementById(modalId).classList.remove("hidden");
        document.body.style.overflow = "hidden";
    }

    function closeModal(modalId) {
        document.getElementById(modalId).classList.add("hidden");
        document.body.style.overflow = "";
    }

    function showErrorAlert(message) {
        Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: message,
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

        // Filter berdasarkan status
        document.getElementById("filterStatus").addEventListener("change", function() {
            const filter = this.value;
            document.querySelectorAll("tbody tr").forEach(row => {
                row.style.display = filter === "all" || row.getAttribute("data-status") === filter ? "" :
                    "none";
            });
        });
    </script>
@endsection
