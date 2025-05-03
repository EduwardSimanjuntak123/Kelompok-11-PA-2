@extends('layouts.app')

@section('title', 'Data Perpanjangan Sewa')

@section('content')
    <div class="container mx-auto px-4 py-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-6">Permintaan Perpanjangan Sewa</h1>

        @if (session('success'))
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                {{ session('success') }}
            </div>
        @endif
        @if (session('error'))
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                {{ session('error') }}
            </div>
        @endif

        <div class="overflow-x-auto">
            <table class="min-w-full bg-white border rounded-lg shadow-sm">
                <thead class="bg-gray-100 text-sm font-semibold text-gray-600">
                    <tr>
                        <th class="py-3 px-4 text-left">Customer</th>
                        <th class="py-3 px-4 text-left">Motor & Plat Motor</th>
                        <th class="py-3 px-4 text-left">Tanggal Diminta</th>
                        <th class="py-3 px-2 text-left w-1/12">Tanggal Perpanjangan</th>
                        <th class="py-3 px-2 text-left w-1/12">Harga Tambahan</th>
                        <th class="py-3 px-4 text-left">Status</th>
                        <th class="py-3 px-4 text-left">Foto Motor</th>
                        <th class="py-3 px-4 text-left">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($extens as $extension)
                        @php
                            $booking = collect($bookings)->firstWhere('id', $extension['booking_id']);
        // @dd($bookings);

                            // URL foto pelanggan (KTP/potoid)
                            $customerPhotoPath = $booking['ktpid'] ?? ($booking['potoid'] ?? null);
                            $customerPhotoUrl = $customerPhotoPath
                                ? rtrim($apiBaseUrl, '/') . '/' . ltrim($customerPhotoPath, '/')
                                : asset('img/user-placeholder.png');

                            // URL gambar motor
                            $motorPath = $booking['motor']['image'] ?? null;
                            $motorUrl = $motorPath
                                ? rtrim($apiBaseUrl, '/') . '/' . ltrim($motorPath, '/')
                                : asset('img/placeholder.png');
                        @endphp
                        <tr class="border-t hover:bg-gray-50 transition">
                            {{-- CUSTOMER --}}
                            <td class="py-3 px-4">
                                <a href="#" class="text-blue-600 font-medium hover:underline open-modal"
                                    data-modal-id="modal-{{ $booking['id'] }}">
                                    {{ $extension['customer_name'] }}
                                </a>
                            </td>

                            {{-- MOTOR --}}
                            <td class="py-3 px-4">{{ $extension['motor_name'] }}</td>

                            {{-- TANGGAL DIMINTA --}}
                            <td class="py-3 px-4 text-sm text-gray-700">
                                {{ \Carbon\Carbon::parse($extension['requested_at'])->format('d-m-Y H:i') }}
                            </td>

                            {{-- TANGGAL PERPANJANGAN --}}
                            <td class="py-3 px-2">
                                <span class="inline-block bg-blue-100 text-blue-800 text-sm font-medium px-2 py-1 rounded">
                                    {{ \Carbon\Carbon::parse($extension['requested_end_date'])->format('d-m-Y') }}
                                </span>
                            </td>

                            {{-- HARGA TAMBAHAN --}}
                            <td class="py-3 px-2">
                                <span
                                    class="inline-block bg-green-100 text-green-800 text-sm font-semibold px-2 py-1 rounded">
                                    Rp {{ number_format($extension['additional_price'], 0, ',', '.') }}
                                </span>
                            </td>

                            {{-- STATUS --}}
                            <td class="py-3 px-4">
                                <span
                                    class="px-2 py-1 rounded text-xs font-medium
                                {{ $extension['status'] == 'pending'
                                    ? 'bg-yellow-100 text-yellow-700'
                                    : ($extension['status'] == 'approved'
                                        ? 'bg-green-100 text-green-700'
                                        : 'bg-red-100 text-red-700') }}">
                                    {{ ucfirst($extension['status']) }}
                                </span>
                            </td>

                            {{-- FOTO MOTOR --}}
                            <td class="py-3 px-4">
                                <img src="{{ $motorUrl }}" alt="Gambar {{ $extension['motor_name'] }}"
                                    class="w-20 h-14 object-cover rounded shadow-sm">
                            </td>

                            <td class="py-3 px-4">
                                @if (in_array($extension['status'], ['pending','requested']))
                                  <div class="flex gap-2">
                                    {{-- APPROVE --}}
                                    <form action="{{ route('vendor.approveExtension', ['extension_id' => $extension['extension_id']]) }}"
                                          method="POST" class="flex-1">
                                      @csrf
                                      <button type="submit"
                                              class="w-full bg-green-500 hover:bg-green-600 text-white py-2 px-4 text-base rounded">
                                        Setujui
                                      </button>
                                    </form>
                              
                                    {{-- REJECT --}}
                                    <form action="{{ route('vendor.rejectExtension', ['extension_id' => $extension['extension_id']]) }}"
                                          method="POST" class="flex-1">
                                      @csrf
                                      <button type="submit"
                                              class="w-full bg-red-500 hover:bg-red-600 text-white py-2 px-4 text-base rounded">
                                        Tolak
                                      </button>
                                    </form>
                                  </div>
                                @else
                                  <span class="text-gray-400 text-sm">—</span>
                                @endif
                              </td>                              
                        </tr>

                        {{-- MODAL DETAIL BOOKING --}}
                        <div id="modal-{{ $booking['id'] }}"
                            class="modal hidden fixed inset-0 bg-black bg-opacity-50 backdrop-blur-sm z-50 flex items-center justify-center transition-opacity duration-200">
                            <div class="modal-content bg-white rounded-2xl shadow-2xl max-w-2xl w-11/12 p-6 transform scale-95 transition-transform duration-200"
                                onclick="event.stopPropagation()">
                                <div class="flex justify-between items-center mb-4">
                                    <h2 class="text-2xl font-semibold text-gray-800">Detail Booking</h2>
                                    <button class="close-modal text-gray-500 hover:text-gray-700 text-3xl leading-none">
                                        &times;
                                    </button>
                                </div>
                                <div class="flex gap-6">
                                    <div class="flex-shrink-0 w-2/5">
                                        <img src="{{ $customerPhotoUrl }}"
                                            alt="Foto KTP {{ $extension['customer_name'] }}"
                                            class="w-full h-64 object-cover rounded-lg shadow-md border">
                                    </div>
                                    <div class="w-3/5 max-h-72 overflow-y-auto">
                                        <ul class="space-y-2 text-gray-700 text-lg">
                                            <li><strong>Nama:</strong> {{ $extension['customer_name'] }}</li>
                                            <li><strong>Booking:</strong>
                                                {{ \Carbon\Carbon::parse($booking['booking_date'])->format('d-m-Y H:i') }}
                                            </li>
                                            <li><strong>Mulai:</strong>
                                                {{ \Carbon\Carbon::parse($booking['start_date'])->format('d-m-Y') }}</li>
                                            <li><strong>Akhir:</strong>
                                                {{ \Carbon\Carbon::parse($booking['end_date'])->format('d-m-Y') }}</li>
                                            <li><strong>Jemput:</strong> {{ $booking['pickup_location'] }}</li>
                                            <li><strong>Status:</strong> {{ ucfirst($booking['status']) }}</li>
                                            @if (!empty($booking['message']))
                                                <li><strong>Catatan:</strong> {{ $booking['message'] }}</li>
                                            @endif
                                        </ul>
                                    </div>
                                </div>
                                <div class="mt-6 text-right">
                                    <button
                                        class="close-modal bg-blue-500 hover:bg-blue-600 text-white py-2 px-5 rounded-lg text-lg transition-colors duration-200">
                                        Tutup
                                    </button>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>



    <script>
        // Buka modal
        document.querySelectorAll('.open-modal').forEach(btn => {
            btn.addEventListener('click', e => {
                e.preventDefault();
                const modal = document.getElementById(btn.dataset.modalId);
                modal.classList.remove('hidden');
                // play zoom-in
                setTimeout(() => modal.querySelector('.modal-content').classList.remove('scale-95'), 10);
            });
        });

        // Tutup modal: klik backdrop atau tombol
        document.querySelectorAll('.modal').forEach(modal => {
            modal.addEventListener('click', () => {
                modal.querySelector('.modal-content').classList.add('scale-95');
                modal.classList.add('hidden');
            });
            modal.querySelectorAll('.close-modal').forEach(btn => {
                btn.addEventListener('click', e => {
                    e.stopPropagation();
                    modal.querySelector('.modal-content').classList.add('scale-95');
                    modal.classList.add('hidden');
                });
            });
        });
    </script>
@endsection
