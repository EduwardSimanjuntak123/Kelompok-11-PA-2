@extends('layouts.app')

@section('title', 'Kelola Pemesanan')

@section('content')
    <div class="container mx-auto p-8">
        <h2 class="text-4xl font-extrabold text-center text-gray-800 mb-8">📋 Kelola Pemesanan</h2>

        @if (empty($bookings) || count($bookings) == 0)
            <p class="text-center text-gray-500">Tidak ada pemesanan untuk ditampilkan.</p>
        @else
            <div class="overflow-x-auto">
                <table class="w-full border-collapse rounded-lg overflow-hidden shadow-md">
                    <thead>
                        <tr class="bg-gray-200 text-gray-700 uppercase text-sm leading-normal text-center">
                            <th class="py-2 px-4 border border-gray-200">No</th>
                            <th class="py-2 px-4 border border-gray-200">Detail Pesanan</th>
                            <th class="py-2 px-4 border border-gray-200">Detail Motor</th>
                            <th class="py-2 px-4 border border-gray-200">Status</th>
                            <th class="py-2 px-4 border border-gray-200">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($bookings as $index => $pesanan)
                            <tr class="hover:bg-gray-50 text-center">
                                <td class="py-2 px-4 border border-gray-200">{{ $index + 1 }}</td>
                                <td class="py-2 px-4 border border-gray-200">
                                    <div class="flex justify-center">
                                        <button onclick="showDetailPesanan({{ json_encode($pesanan) }})"
                                            class="bg-gray-600 text-white px-3 py-1 rounded flex items-center justify-center gap-2">
                                            Pesanan
                                        </button>
                                    </div>
                                </td>
                                <td class="py-2 px-4 border border-gray-200">
                                    <div class="flex justify-center">
                                        <button onclick="showDetailMotor({{ json_encode($pesanan['motor']) }})"
                                            class="bg-gray-600 text-white px-3 py-1 rounded flex items-center justify-center gap-2">
                                            Motor
                                        </button>
                                    </div>
                                </td>
                                <td class="py-2 px-4 border border-gray-200 text-center">
                                    <span class="{{ $pesanan['status'] == 'pending' ? 'text-yellow-600' : ($pesanan['status'] == 'rejected' ? 'text-red-600' : 'text-green-600') }}">
                                        {{ ucfirst($pesanan['status']) }}
                                    </span>
                                </td>
                                <td class="py-2 px-4 border border-gray-200 text-center">
                                    @if ($pesanan['status'] == 'pending')
                                        <button onclick="updateBooking({{ $pesanan['id'] }}, 'confirm')"
                                            class="bg-green-600 text-white px-3 py-1 rounded">Setujui</button>
                                        <button onclick="updateBooking({{ $pesanan['id'] }}, 'reject')"
                                            class="bg-red-600 text-white px-3 py-1 rounded">Tolak</button>
                                    @elseif ($pesanan['status'] == 'confirmed')
                                        <button onclick="completeBooking({{ $pesanan['id'] }})"
                                            class="bg-blue-600 text-white px-3 py-1 rounded">Selesaikan</button>
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

    <!-- Modal Detail Pesanan -->
    <div id="detailPesananModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-lg w-1/3 p-6">
            <h2 class="text-2xl font-bold flex items-center gap-2"><span>📄</span> Detail Pesanan</h2>
            <div id="detailPesananContent" class="mt-4"></div>
            <div class="flex justify-center">
                <button onclick="closeModal('detailPesananModal')" class="mt-4 px-4 py-2 bg-gray-500 text-white rounded">Tutup</button>
            </div>
        </div>
    </div>

 <!-- Modal Detail Motor -->
<div id="detailMotorModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center">
    <div class="bg-white rounded-lg shadow-lg w-[600px] p-6">
        <h2 class="text-2xl font-bold flex items-center gap-2 border-b pb-3"><span>🏍️</span> Detail Motor</h2>
        <div class="grid grid-cols-2 gap-6 items-center mt-4">
            <div class="space-y-3">
                <p class="text-lg"><strong>🔹 Name:</strong> <span id="motorName"></span></p>
                <p class="text-lg"><strong>🏷️ Brand:</strong> <span id="motorBrand"></span></p>
                <p class="text-lg"><strong>📄 Model:</strong> <span id="motorModel"></span></p>
                <p class="text-lg"><strong>📅 Year:</strong> <span id="motorYear"></span></p>
                <p class="text-lg"><strong>💰 Price/Day:</strong> <span id="motorPrice"></span></p>
            </div>
            <div class="rounded-lg overflow-hidden border shadow-md flex justify-center">
                <img id="motorImage" src="" alt="Gambar Motor" class="w-40 h-40 object-cover">
            </div>
        </div>
        <div class="flex justify-center mt-6">
            <button onclick="closeModal('detailMotorModal')" class="px-5 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-700 transition">
                Tutup
            </button>
        </div>
    </div>
</div>



    <script>
        function showDetailPesanan(pesanan) {
            let content = `
                <p><strong>📅 Booking Date:</strong> ${pesanan.booking_date}</p>
                <p><strong>👤 Customer:</strong> ${pesanan.customer_name}</p>
                <p><strong>📆 Start Date:</strong> ${pesanan.start_date}</p>
                <p><strong>📆 End Date:</strong> ${pesanan.end_date}</p>
                <p><strong>📍 Pickup Location:</strong> ${pesanan.pickup_location}</p>
            `;
            document.getElementById('detailPesananContent').innerHTML = content;
            openModal('detailPesananModal');
        }

        function showDetailMotor(motor) {
            document.getElementById('motorName').textContent = motor.name;
            document.getElementById('motorBrand').textContent = motor.brand;
            document.getElementById('motorModel').textContent = motor.model;
            document.getElementById('motorYear').textContent = motor.year;
            document.getElementById('motorPrice').textContent = motor.price_per_day.toLocaleString();
            document.getElementById('motorImage').src = motor.image;
            openModal('detailMotorModal');
        }

        function openModal(modalId) {
            document.getElementById(modalId).classList.remove('hidden');
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.add('hidden');
        }
    </script>
@endsection
