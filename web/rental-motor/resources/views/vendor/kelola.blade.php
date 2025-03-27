@extends('layouts.app')

@section('title', 'Kelola Pemesanan')

@section('content')
    <!-- Sertakan SweetAlert2 dari CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <div class="container mx-auto p-8">
        <h2 class="text-4xl font-extrabold mb-6 text-center text-gray-800">📋 Kelola Pemesanan</h2>
        
        <div class="mb-6 flex justify-center">
            <select id="filterStatus" class="border p-2 rounded-md">
                <option value="all">Semua</option>
                <option value="pending">Pending</option>
                <option value="confirmed">Confirmed</option>
                <option value="rejected">Rejected</option>
            </select>
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
                                    <button onclick='showMotorDetailsDirect(@json($pesanan["motor"]))' class="bg-gray-300 text-black px-3 py-1 rounded-lg">Motor</button>
                                </td>
                                <td class="py-3 px-6 text-center">
                                    <button onclick='showBookingDetails(@json($pesanan))' class="bg-gray-300 text-black px-3 py-1 rounded-lg">Pemesanan</button>
                                </td>
                                <td class="py-3 px-6 text-center">
                                    <strong class="{{ $pesanan['status'] == 'pending' ? 'text-yellow-600' : ($pesanan['status'] == 'rejected' ? 'text-red-600' : 'text-green-600') }}">
                                        {{ ucfirst($pesanan['status']) }}
                                    </strong>
                                </td>
                                <td class="py-3 px-6 text-center">
                                    @if ($pesanan['status'] == 'pending')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'confirm')" class="bg-green-600 text-white px-3 py-1 rounded-lg">Setujui</button>
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'reject')" class="bg-red-600 text-white px-3 py-1 rounded-lg">Tolak</button>
                                    @elseif ($pesanan['status'] == 'confirmed')
                                        <button onclick="handleCompleteBooking({{ $pesanan['id'] }})" class="bg-blue-600 text-white px-3 py-1 rounded-lg">Selesaikan</button>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>
    
    <!-- Modal Detail Pemesanan -->
    <div id="bookingDetailModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center">
        <div class="bg-white p-6 rounded-lg shadow-lg w-96">
            <h2 class="text-xl font-bold mb-4">Detail Pemesanan</h2>
            <p><strong>Nama Pelanggan:</strong> <span id="detailCustomer"></span></p>
            <p><strong>Booking Date:</strong> <span id="detailBookingDate"></span></p>
            <p><strong>Tanggal Mulai:</strong> <span id="detailStart"></span></p>
            <p><strong>Tanggal Selesai:</strong> <span id="detailEnd"></span></p>
            <p><strong>Lokasi Jemput:</strong> <span id="detailPickupLocation"></span></p>
            <button onclick="closeBookingModal()" class="mt-4 bg-red-500 text-white px-4 py-2 rounded">Tutup</button>
        </div>
    </div>

    <!-- Modal Detail Motor -->
    <div id="motorDetailModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center">
        <div class="bg-white p-6 rounded-lg shadow-lg w-96">
            <h2 class="text-xl font-bold mb-4">Detail Motor</h2>
            <img id="detailMotorImage" class="w-full h-40 object-cover rounded-lg mb-4" alt="Motor Image">
            <p><strong>Nama Motor:</strong> <span id="detailMotor"></span></p>
            <p><strong>Brand:</strong> <span id="detailBrand"></span></p>
            <p><strong>Model:</strong> <span id="detailModel"></span></p>
            <p><strong>Tahun:</strong> <span id="detailYear"></span></p>
            <p><strong>Harga/Hari:</strong> Rp<span id="detailPricePerDay"></span></p>
            <button onclick="closeMotorModal()" class="mt-4 bg-red-500 text-white px-4 py-2 rounded">Tutup</button>
        </div>
    </div>

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
            showConfirmation('Konfirmasi', `Apakah Anda yakin ingin ${actionText} booking ini?`, `Ya, ${actionText}!`, 'Batal')
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
            
            document.getElementById("bookingDetailModal").classList.remove("hidden");
        }

        function closeBookingModal() {
            document.getElementById("bookingDetailModal").classList.add("hidden");
        }

        // Modal Detail Motor menggunakan parameter motor secara langsung
        function showMotorDetailsDirect(motor) {
            if (!motor) return showErrorAlert("Data motor tidak tersedia.");
            document.getElementById("detailMotor").textContent = motor.name || ((motor.brand || "-") + " " + (motor.model || "-"));
            document.getElementById("detailBrand").textContent = motor.brand || "-";
            document.getElementById("detailModel").textContent = motor.model || "-";
            document.getElementById("detailYear").textContent = motor.year || "-";
            document.getElementById("detailPricePerDay").textContent = motor.price_per_day ? motor.price_per_day.toLocaleString() : "0";
            document.getElementById("detailMotorImage").src = motor.image || "https://via.placeholder.com/150";
            
            document.getElementById("motorDetailModal").classList.remove("hidden");
        }

        function closeMotorModal() {
            document.getElementById("motorDetailModal").classList.add("hidden");
        }
        
        // Filter berdasarkan status
        document.getElementById("filterStatus").addEventListener("change", function() {
            const filter = this.value;
            document.querySelectorAll("tbody tr").forEach(row => {
                row.style.display = filter === "all" || row.getAttribute("data-status") === filter ? "" : "none";
            });
        });
    </script>
@endsection
