@extends('layouts.app')

@section('title', 'Kelola Pemesanan')

@section('content')
    <div class="container mx-auto p-8">
        <h2 class="text-4xl font-extrabold text-center text-gray-800 mb-8">📋 Kelola Pemesanan</h2>

        @if (empty($bookings) || count($bookings) == 0)
            <p class="text-center text-gray-500">Tidak ada pemesanan untuk ditampilkan.</p>
        @else
            <div class="overflow-x-auto">
                <table class="min-w-full border-collapse border border-gray-200">
                    <thead>
                        <tr class="bg-gray-100">
                            <th class="py-2 px-4 border border-gray-200">ID</th>
                            <th class="py-2 px-4 border border-gray-200">Booking Date</th>
                            <th class="py-2 px-4 border border-gray-200">Customer</th>
                            <th class="py-2 px-4 border border-gray-200">Start Date</th>
                            <th class="py-2 px-4 border border-gray-200">End Date</th>
                            <th class="py-2 px-4 border border-gray-200">Status</th>
                            <th class="py-2 px-4 border border-gray-200">Pickup Location</th>
                            <th class="py-2 px-4 border border-gray-200">Motor Details</th>
                            <th class="py-2 px-4 border border-gray-200">Gambar Motor</th>
                            <th class="py-2 px-4 border border-gray-200">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($bookings as $pesanan)
                            <tr class="hover:bg-gray-50">
                                <td class="py-2 px-4 border border-gray-200">{{ $pesanan['id'] }}</td>
                                <td class="py-2 px-4 border border-gray-200">
                                    {{ \Carbon\Carbon::parse($pesanan['booking_date'])->format('Y-m-d H:i:s') }}
                                </td>
                                <td class="py-2 px-4 border border-gray-200">{{ $pesanan['customer_name'] }}</td>
                                <td class="py-2 px-4 border border-gray-200">
                                    {{ \Carbon\Carbon::parse($pesanan['start_date'])->format('Y-m-d H:i:s') }}
                                </td>
                                <td class="py-2 px-4 border border-gray-200">
                                    {{ \Carbon\Carbon::parse($pesanan['end_date'])->format('Y-m-d H:i:s') }}
                                </td>
                                <td class="py-2 px-4 border border-gray-200">
                                    <span
                                        class="{{ $pesanan['status'] == 'pending' ? 'text-yellow-600' : ($pesanan['status'] == 'rejected' ? 'text-red-600' : 'text-green-600') }}">
                                        {{ ucfirst($pesanan['status']) }}
                                    </span>
                                </td>
                                <td class="py-2 px-4 border border-gray-200">{{ trim($pesanan['pickup_location']) }}</td>
                                <td class="py-2 px-4 border border-gray-200">
                                    <ul class="list-disc list-inside text-sm">
                                        <li><strong>ID:</strong> {{ $pesanan['motor']['id'] }}</li>
                                        <li><strong>Name:</strong> {{ $pesanan['motor']['name'] }}</li>
                                        <li><strong>Brand:</strong> {{ $pesanan['motor']['brand'] }}</li>
                                        <li><strong>Model:</strong> {{ $pesanan['motor']['model'] }}</li>
                                        <li><strong>Year:</strong> {{ $pesanan['motor']['year'] }}</li>
                                        <li><strong>Price/Day:</strong>
                                            {{ number_format($pesanan['motor']['price_per_day'], 0, ',', '.') }}</li>
                                        <li><strong>Total Price:</strong>
                                            {{ number_format($pesanan['motor']['total_price'], 0, ',', '.') }}</li>
                                    </ul>
                                </td>
                                <td class="py-2 px-4 border border-gray-200">
                                    <img src="{{ $pesanan['motor']['image'] }}" alt="Gambar Motor"
                                        class="w-16 h-16 object-cover">
                                </td>
                                <td class="py-2 px-4 border border-gray-200">
                                    @if ($pesanan['status'] == 'pending')
                                        <button onclick="updateBooking({{ $pesanan['id'] }}, 'confirm')"
                                            class="bg-green-600 text-white px-2 py-1 rounded">Setujui</button>
                                        <button onclick="updateBooking({{ $pesanan['id'] }}, 'reject')"
                                            class="bg-red-600 text-white px-2 py-1 rounded">Tolak</button>
                                    @elseif ($pesanan['status'] == 'confirmed')
                                        <button onclick="completeBooking({{ $pesanan['id'] }})"
                                            class="bg-blue-600 text-white px-2 py-1 rounded">Selesaikan</button>
                                    @else
                                        -
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>

    <!-- Skrip (tidak diubah) -->
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
    </script>
@endsection
