@extends('layouts.app')

@section('title', 'Kelola Pemesanan')

@section('content')
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
        {{-- @dd($bookings) --}}

        @if (empty($bookings) || count($bookings) == 0)
            <p class="text-center text-gray-500">Tidak ada pemesanan untuk ditampilkan.</p>
        @else
            <div id="bookingList" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                @foreach ($bookings as $pesanan)
                    <div class="booking-card bg-white shadow-lg rounded-xl p-6" data-status="{{ $pesanan['status'] }}">
                        <h3 class="text-lg font-semibold text-gray-800">
                            {{ $pesanan['motor']['brand'] ?? 'Unknown' }} {{ $pesanan['motor']['model'] ?? '' }}
                        </h3>
                        <p class="text-gray-600 text-sm">Status:
                            <strong
                                class="{{ $pesanan['status'] == 'pending' ? 'text-yellow-600' : ($pesanan['status'] == 'rejected' ? 'text-red-600' : 'text-green-600') }}">
                                {{ ucfirst($pesanan['status']) }}
                            </strong>
                        </p>
                        <p class="text-gray-600 text-sm">Mulai:
                            <strong>{{ \Carbon\Carbon::parse($pesanan['start_date'])->format('d M Y') }}</strong>
                        </p>
                        <p class="text-gray-600 text-sm">Selesai:
                            <strong>{{ \Carbon\Carbon::parse($pesanan['end_date'])->format('d M Y') }}</strong>
                        </p>

                        <div class="mt-4 flex space-x-2">
                            <button onclick='showDetails(@json($pesanan))'
                                class="bg-gray-600 text-white px-3 py-1 rounded-lg">Detail</button>
                            @if ($pesanan['status'] == 'pending')
                                <button onclick="updateBooking({{ $pesanan['id'] }}, 'confirm')"
                                    class="bg-green-600 text-white px-3 py-1 rounded-lg">Setujui</button>
                                <button onclick="updateBooking({{ $pesanan['id'] }}, 'reject')"
                                    class="bg-red-600 text-white px-3 py-1 rounded-lg">Tolak</button>
                            @elseif ($pesanan['status'] == 'confirmed')
                                <button onclick="completeBooking({{ $pesanan['id'] }})"
                                    class="bg-blue-600 text-white px-3 py-1 rounded-lg">Selesaikan</button>
                            @endif
                        </div>
                    </div>
                @endforeach
            </div>
        @endif
    </div>

    <div id="detailModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center">
        <div class="bg-white p-6 rounded-lg shadow-lg w-96">
            <h2 class="text-xl font-bold mb-4">Detail Pemesanan</h2>
            <p><strong>Nama Pelanggan:</strong> <span id="detailCustomer"></span></p>
            <p><strong>Nama Motor:</strong> <span id="detailMotor"></span></p>
            <p><strong>Harga per Hari:</strong> Rp<span id="detailPricePerDay"></span></p>
            <p><strong>Total Harga:</strong> Rp<span id="detailTotalPrice"></span></p>
            <p><strong>Lokasi Jemput:</strong> <span id="detailPickupLocation"></span></p>
            <p><strong>Status:</strong> <span id="detailStatus"></span></p>
            <p><strong>Tanggal Mulai:</strong> <span id="detailStart"></span></p>
            <p><strong>Tanggal Selesai:</strong> <span id="detailEnd"></span></p>
            <button onclick="closeModal()" class="mt-4 bg-red-500 text-white px-4 py-2 rounded">Tutup</button>
        </div>
    </div>

    <script>
        const BASE_API = "http://localhost:8080";

        function updateBooking(bookingId, action) {
            if (!confirm(`Apakah Anda yakin ingin ${action} booking ini?`)) return;
            fetch(`${BASE_API}/vendor/bookings/${bookingId}/${action}`, {
                    method: "PUT",
                    headers: {
                        "Authorization": "Bearer {{ session('token') }}",
                        "Content-Type": "application/json"
                    }
                }).then(response => response.json())
                .then(data => {
                    alert(data.message);
                    location.reload();
                })
                .catch(error => alert("Terjadi kesalahan: " + error.message));
        }

        function completeBooking(bookingId) {
            if (!confirm("Apakah Anda yakin ingin menyelesaikan booking ini?")) return;
            fetch(`${BASE_API}/vendor/bookings/complete/${bookingId}`, {
                    method: "PUT",
                    headers: {
                        "Authorization": "Bearer {{ session('token') }}",
                        "Content-Type": "application/json"
                    }
                }).then(response => response.json())
                .then(data => {
                    alert("Booking berhasil diselesaikan!");
                    location.reload();
                })
                .catch(error => alert("Terjadi kesalahan: " + error.message));
        }

        function showDetails(pesanan) {
            document.getElementById("detailCustomer").textContent = pesanan.customer_name || "-";
            document.getElementById("detailMotor").textContent = (pesanan.motor?.brand || "Unknown") + " " + (pesanan.motor
                ?.model || "");
            document.getElementById("detailPricePerDay").textContent = pesanan.motor?.price_per_day?.toLocaleString() ||
                "0";
            document.getElementById("detailTotalPrice").textContent = pesanan.motor?.total_price?.toLocaleString() || "0";
            document.getElementById("detailPickupLocation").textContent = pesanan.pickup_location || "-";
            document.getElementById("detailStatus").textContent = pesanan.status || "-";
            document.getElementById("detailStart").textContent = pesanan.start_date || "-";
            document.getElementById("detailEnd").textContent = pesanan.end_date || "-";
            document.getElementById("detailModal").classList.remove("hidden");
        }

        function closeModal() {
            document.getElementById("detailModal").classList.add("hidden");
        }
    </script>
@endsection
