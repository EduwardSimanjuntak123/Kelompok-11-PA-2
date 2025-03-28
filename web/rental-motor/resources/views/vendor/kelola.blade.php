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
                <option value="rejected">Rejected</option>
            </select>
            <!-- Button to open manual booking modal -->
            <button onclick="openModal('addTransactionModal')"
                class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
                + Booking Manual
            </button>
        </div>

        @if (empty($bookings) || count($bookings) == 0)
            <p class="text-center text-gray-500">Tidak ada pemesanan untuk ditampilkan.</p>
        @else
            <div class="overflow-x-auto">
                <table class="min-w-full bg-white shadow-md rounded-lg">
                    <thead>
                        <tr class="bg-gray-200 text-gray-600 uppercase text-sm leading-normal">
                            <th class="py-3 px-6 text-center">Nomor</th>
                            <th class="py-3 px-6 text-center">Detail Motor</th>
                            <th class="py-3 px-6 text-center">Detail Pemesanan</th>
                            <th class="py-3 px-6 text-center">Status</th>
                            <th class="py-3 px-6 text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="text-gray-600 text-sm font-light">
                        @foreach ($bookings as $pesanan)
                            <tr class="border-b border-gray-200 hover:bg-gray-100" data-status="{{ $pesanan['status'] }}">
                                <td class="py-3 px-6 text-center">{{ $loop->iteration }}</td>
                                <td class="py-3 px-6 text-center">
                                    <button onclick='showMotorDetailsDirect(@json($pesanan['motor']))'
                                        class="bg-gray-300 text-black px-3 py-1 rounded-lg">Motor</button>
                                </td>
                                <td class="py-3 px-6 text-center">
                                    <button onclick='showBookingDetails(@json($pesanan))'
                                        class="bg-gray-300 text-black px-3 py-1 rounded-lg">Pemesanan</button>
                                </td>
                                <td class="py-3 px-6 text-center">
                                    <strong
                                        class="{{ $pesanan['status'] == 'pending' ? 'text-yellow-600' : ($pesanan['status'] == 'rejected' ? 'text-red-600' : 'text-green-600') }}">
                                        {{ ucfirst($pesanan['status']) }}
                                    </strong>
                                </td>
                                <td class="py-3 px-6 text-center">
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
    </div>

    <!-- Modal for Manual Booking -->
    <div id="addTransactionModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-lg w-1/2 p-6">
            <h2 class="text-2xl font-bold mb-4">Tambah Booking Manual</h2>
            <form action="{{ route('vendor.manual.booking.store') }}" method="POST" enctype="multipart/form-data">
                @csrf
                <!-- Dropdown Motor: only vendor's motors -->
                <div class="mb-4">
                    <label for="motor_id" class="block text-gray-700 font-semibold">Pilih Motor</label>
                    <select name="motor_id" id="motor_id" class="w-full p-2 border rounded" required>
                        <option value="">-- Pilih Motor --</option>
                        @foreach ($motors as $motor)
                            <option value="{{ $motor['id'] }}">
                                {{ $motor['name'] }} ({{ $motor['brand'] }})
                            </option>
                        @endforeach
                    </select>
                </div>
                <!-- Start Date using datetime-local -->
                <div class="mb-4">
                    <label for="start_date" class="block text-gray-700 font-semibold">Start Date</label>
                    <input type="datetime-local" name="start_date" id="start_date" class="w-full p-2 border rounded"
                        step="1" required>
                </div>
                <!-- End Date using datetime-local -->
                <div class="mb-4">
                    <label for="end_date" class="block text-gray-700 font-semibold">End Date</label>
                    <input type="datetime-local" name="end_date" id="end_date" class="w-full p-2 border rounded"
                        step="1" required>
                </div>
                <!-- Pickup Location -->
                <div class="mb-4">
                    <label for="pickup_location" class="block text-gray-700 font-semibold">Pickup Location</label>
                    <textarea name="pickup_location" id="pickup_location" class="w-full p-2 border rounded" required></textarea>
                </div>
                <!-- Customer Name (for manual booking without account) -->
                <div class="mb-4">
                    <label for="customer_name" class="block text-gray-700 font-semibold">Nama Pelanggan</label>
                    <input type="text" name="customer_name" id="customer_name" class="w-full p-2 border rounded"
                        required>
                </div>
                <!-- Optional Photo ID -->
                <div class="mb-4">
                    <label for="photo_id" class="block text-gray-700 font-semibold">Foto ID (Opsional)</label>
                    <input type="file" name="photo_id" id="photo_id" class="w-full p-2 border rounded">
                </div>
                <!-- Optional KTP ID -->
                <div class="mb-4">
                    <label for="ktp_id" class="block text-gray-700 font-semibold">Foto KTP (Opsional)</label>
                    <input type="file" name="ktp_id" id="ktp_id" class="w-full p-2 border rounded">
                </div>
                <div class="flex justify-end space-x-4">
                    <button type="button" onclick="closeModal('addTransactionModal')"
                        class="px-4 py-2 bg-gray-500 text-white rounded">
                        Batal
                    </button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded">
                        Simpan
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal untuk menampilkan detail booking -->
    <div id="bookingDetailModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-lg w-1/2 p-6">
            <h2 class="text-2xl font-bold mb-4">Detail Pemesanan</h2>
            <p><strong>Nama Pelanggan:</strong> <span id="detailCustomer"></span></p>
            <p><strong>Tanggal Booking:</strong> <span id="detailBookingDate"></span></p>
            <p><strong>Start Date:</strong> <span id="detailStart"></span></p>
            <p><strong>End Date:</strong> <span id="detailEnd"></span></p>
            <p><strong>Pickup Location:</strong> <span id="detailPickupLocation"></span></p>
            <div class="flex justify-end mt-4">
                <button onclick="closeBookingModal()" class="px-4 py-2 bg-gray-500 text-white rounded">Tutup</button>
            </div>
        </div>
    </div>

    <!-- Modal untuk menampilkan detail motor -->
    <div id="motorDetailModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-lg w-1/2 p-6">
            <h2 class="text-2xl font-bold mb-4">Detail Motor</h2>
            <p><strong>Nama Motor:</strong> <span id="detailMotor"></span></p>
            <p><strong>Brand:</strong> <span id="detailBrand"></span></p>
            <p><strong>Model:</strong> <span id="detailModel"></span></p>
            <p><strong>Tahun:</strong> <span id="detailYear"></span></p>
            <p><strong>Harga per Hari:</strong> <span id="detailPricePerDay"></span></p>
            <img id="detailMotorImage" src="https://via.placeholder.com/150" alt="Gambar Motor" class="w-32 h-32 mt-4">
            <div class="flex justify-end mt-4">
                <button onclick="closeMotorModal()" class="px-4 py-2 bg-gray-500 text-white rounded">Tutup</button>
            </div>
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

        // Modal Detail Pemesanan
        function showBookingDetails(pesanan) {
            document.getElementById("detailCustomer").textContent = pesanan.customer_name || "-";
            document.getElementById("detailBookingDate").textContent = pesanan.booking_date || "-";
            document.getElementById("detailStart").textContent = pesanan.start_date || "-";
            document.getElementById("detailEnd").textContent = pesanan.end_date || "-";
            document.getElementById("detailPickupLocation").textContent = pesanan.pickup_location || "-";
            openModal("bookingDetailModal");
        }

        function closeBookingModal() {
            closeModal("bookingDetailModal");
        }

        // Modal Detail Motor
        function showMotorDetailsDirect(motor) {
            if (!motor) return showErrorAlert("Data motor tidak tersedia.");
            document.getElementById("detailMotor").textContent = motor.name || ((motor.brand || "-") + " " + (motor.model ||
                "-"));
            document.getElementById("detailBrand").textContent = motor.brand || "-";
            document.getElementById("detailModel").textContent = motor.model || "-";
            document.getElementById("detailYear").textContent = motor.year || "-";
            document.getElementById("detailPricePerDay").textContent = motor.price_per_day ? motor.price_per_day
                .toLocaleString() : "0";
            document.getElementById("detailMotorImage").src = motor.image || "https://via.placeholder.com/150";
            openModal("motorDetailModal");
        }

        function closeMotorModal() {
            closeModal("motorDetailModal");
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
