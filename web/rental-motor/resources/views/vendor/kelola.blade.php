@extends('layouts.app')

@section('title', 'Kelola Pemesanan')

@section('content')
    <!-- Include SweetAlert2 dari CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-k6d4wzSIapyDyv1kpU366/PK5hCdSbCRGRCMv+eplOQJWyd1fbcAu9OCUj5zNLiq" crossorigin="anonymous">
    </script>

    <div class="container mx-auto p-4 sm:p-6 lg:p-8">
        <h2 class="text-2xl sm:text-3xl lg:text-4xl font-extrabold mb-4 sm:mb-6 text-center text-gray-800">Kelola Pemesanan
        </h2>

        <!-- Filter dan Booking Manual dalam satu baris - Responsive -->
        <div class="mb-4 sm:mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <!-- Form Filter Status -->
            <form method="GET"
                class="flex flex-col sm:flex-row items-start sm:items-center gap-2 sm:gap-4 w-full sm:w-auto">
                @csrf
                <label for="status" class="text-sm font-medium text-gray-700 whitespace-nowrap">Filter Status:</label>
                <div class="relative w-full sm:w-60">
                    <!-- Icon di kiri -->
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 12h18M3 20h18" />
                        </svg>
                    </div>

                    <select id="status" name="status" onchange="this.form.submit()"
                        class="block w-full pl-10 pr-8 py-2 bg-white border border-gray-300 rounded-lg text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm appearance-none">
                        <option value="all" {{ request('status', 'all') == 'all' ? 'selected' : '' }}>Semua Status
                        </option>
                        <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>Menunggu Konfirmasi
                        </option>
                        <option value="confirmed" {{ request('status') == 'confirmed' ? 'selected' : '' }}>Dikonfirmasi
                        </option>
                        <option value="in transit" {{ request('status') == 'in transit' ? 'selected' : '' }}>Motor Sedang
                            Diantar</option>
                        <option value="in use" {{ request('status') == 'in use' ? 'selected' : '' }}>Sedang Digunakan
                        </option>
                        <option value="awaiting return" {{ request('status') == 'awaiting return' ? 'selected' : '' }}>
                            Menunggu Pengembalian</option>
                        <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>Pesanan Selesai
                        </option>
                        <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>Booking Ditolak
                        </option>
                    </select>

                    <!-- Arrow dropdown -->
                    <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-gray-500" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
                        </svg>
                    </div>
                </div>
            </form>

            <!-- Tombol Booking Manual -->
            <button onclick="openModal('addBookingModal')"
                class="w-full sm:w-auto px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 text-sm sm:text-base whitespace-nowrap">
                Tambah Booking Manual
            </button>
        </div>

        @if (empty($bookings) || count($bookings) == 0)
            <div class="flex flex-col items-center justify-center text-center p-6 sm:p-10 bg-white rounded-lg shadow-md">
                <!-- Icon di atas teks -->
                <i class="fas fa-calendar-times fa-2x sm:fa-3x text-gray-400 mb-4"></i>
                <h2 class="text-xl sm:text-2xl font-semibold text-gray-700">Belum Ada Pemesanan</h2>
                <p class="text-gray-600 mt-2 text-sm sm:text-base">Tidak ada pemesanan untuk ditampilkan.</p>
            </div>
        @else
            <!-- Desktop Table View -->
            <div class="hidden lg:block overflow-x-auto ">
                <table class="min-w-full bg-white shadow-md rounded-lg table-fixed">
                    <thead>
                        <tr class="bg-blue-600 text-white text-sm leading-normal">
                            <th class="py-3 px-4 text-center w-[5%]">NO</th>
                            <th class="py-3 px-4 text-left align-top w-[28%]">DETAIL PEMESANAN</th>
                            <th class="py-3 px-4 text-left align-top w-[20%]">DETAIL MOTOR</th>
                            <th class="py-3 px-4 text-center w-[17%]">GAMBAR</th>
                            <th class="py-3 px-4 text-center w-[10%]">STATUS</th>
                            <th class="py-3 px-4 text-center w-[15%]">AKSI</th>
                        </tr>
                    </thead>
                    <tbody class="text-gray-600 text-sm font-light">
                        @foreach ($bookings as $pesanan)
                            <tr class="border-b border-gray-200 hover:bg-gray-100" data-status="{{ $pesanan['status'] }}">
                                <td class="py-3 px-4 text-center align-middle">{{ $loop->iteration }}</td>

                                <td class="py-4 px-6 text-left align-middle">
                                    <a href="javascript:void(0)"
                                        class="open-booking-modal group text-blue-600 font-reguler underline hover:underline cursor-pointer flex items-center"
                                        data-booking='@json(array_merge($pesanan, ['potoid' => $pesanan['potoid'] ? config('api.base_url') . $pesanan['potoid'] : null]),
                                            JSON_UNESCAPED_SLASHES)'
                                        title="Klik untuk melihat detail pemesanan">
                                        <span class="italic">lihat data pemesan &gt;</span>
                                    </a>
                                </td>


                                <!-- Detail Motor -->
                                <td class="py-3 px-4 text-left align-middle">
                                    @if (isset($pesanan['motor']))
                                        <div><strong class="font-bold">Nama Motor:</strong>
                                            {{ $pesanan['motor']['name'] ?? '-' }}</div>
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

                                <td class="py-3 px-4 text-center">
                                    @if ($s == 'pending')
                                        <div class="flex justify-center gap-2">
                                            <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'confirm')"
                                                class="px-4 py-2 bg-green-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                                <i class="fas fa-check mr-1"></i> Setujui
                                            </button>
                                            <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'reject')"
                                                class="px-4 py-2 bg-red-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                                <i class="fas fa-times mr-1"></i> Tolak
                                            </button>
                                        </div>
                                    @elseif ($s == 'confirmed')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'transit')"
                                            class="px-4 py-2 bg-blue-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                            <i class="fas fa-motorcycle mr-1"></i> Antar Motor
                                        </button>
                                    @elseif ($s == 'in transit')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'inuse')"
                                            class="px-4 py-2 bg-indigo-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                            <i class="fas fa-play mr-1"></i> Sedang Berlangsung
                                        </button>
                                    @elseif ($s == 'awaiting return')
                                        <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'complete')"
                                            class="px-4 py-2 bg-green-600 text-white font-medium text-sm rounded-lg shadow-sm hover:shadow-md transition-shadow duration-150">
                                            <i class="fas fa-undo mr-1"></i> Motor Kembali
                                        </button>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <!-- Mobile Card View -->
            <div class="lg:hidden space-y-4">
                @foreach ($bookings as $pesanan)
                    @php $s = $pesanan['status']; @endphp
                    <div class="bg-white rounded-lg shadow-md p-4 border border-gray-200">
                        <!-- Header Card -->
                        <div class="flex items-start justify-between mb-3">
                            <div class="flex-1">
                                <a href="javascript:void(0)"
                                    class="open-booking-modal group text-blue-600 font-reguler underline hover:underline cursor-pointer flex items-center"
                                    data-booking='@json(array_merge($pesanan, ['potoid' => $pesanan['potoid'] ? config('api.base_url') . $pesanan['potoid'] : null]),
                                        JSON_UNESCAPED_SLASHES)'
                                    title="Klik untuk melihat detail pemesanan">
                                    <span class="italic text-xs">lihat data pemesan &gt;</span>
                                </a>
                                <div class="text-sm text-gray-500 mt-1">Pesanan #{{ $loop->iteration }}</div>
                            </div>

                            <!-- Status Badge -->
                            <span
                                class="px-2 py-1 text-xs font-semibold rounded-full
                                @if ($s == 'pending') bg-yellow-100 text-yellow-800
                                @elseif($s == 'confirmed') bg-blue-100 text-blue-800
                                @elseif($s == 'in transit') bg-indigo-100 text-indigo-800
                                @elseif($s == 'in use') bg-purple-100 text-purple-800
                                @elseif($s == 'awaiting return') bg-orange-100 text-orange-800
                                @elseif($s == 'completed') bg-green-100 text-green-800
                                @elseif($s == 'rejected') bg-red-100 text-red-800
                                @else bg-gray-100 text-gray-800 @endif
                            ">
                                @if ($s == 'pending')
                                    Menunggu
                                @elseif($s == 'confirmed')
                                    Dikonfirmasi
                                @elseif($s == 'in transit')
                                    Diantar
                                @elseif($s == 'in use')
                                    Digunakan
                                @elseif($s == 'awaiting return')
                                    Menunggu Kembali
                                @elseif($s == 'completed')
                                    Selesai
                                @elseif($s == 'rejected')
                                    Ditolak
                                @else
                                    {{ ucfirst($s) }}
                                @endif
                            </span>
                        </div>

                        <!-- Motor Info & Image -->
                        <div class="flex gap-3 mb-3">
                            <!-- Motor Image -->
                            <div class="flex-shrink-0">
                                @if (isset($pesanan['motor']['image']))
                                    <img src="{{ config('api.base_url') }}{{ $pesanan['motor']['image'] }}"
                                        alt="Motor" class="w-16 h-16 sm:w-20 sm:h-20 object-cover rounded">
                                @else
                                    <div
                                        class="w-16 h-16 sm:w-20 sm:h-20 bg-gray-200 rounded flex items-center justify-center">
                                        <i class="fas fa-motorcycle text-gray-400"></i>
                                    </div>
                                @endif
                            </div>

                            <!-- Motor Details -->
                            <div class="flex-1 text-sm">
                                @if (isset($pesanan['motor']))
                                    <div class="font-semibold text-gray-800">{{ $pesanan['motor']['name'] ?? '-' }}</div>
                                    <div class="text-gray-600">{{ $pesanan['motor']['brand'] ?? '-' }} •
                                        {{ $pesanan['motor']['year'] ?? '-' }}</div>
                                    <div class="text-gray-600">{{ $pesanan['motor']['color'] ?? '-' }}</div>
                                    <div class="text-gray-600 font-mono">{{ $pesanan['motor']['plat_motor'] ?? '-' }}
                                    </div>
                                @else
                                    <div class="text-gray-500">Data motor tidak tersedia</div>
                                @endif
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="flex flex-col sm:flex-row gap-2">
                            @if ($s == 'pending')
                                <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'confirm')"
                                    class="flex-1 px-3 py-2 bg-green-600 text-white text-sm rounded-lg hover:bg-green-700 transition-colors">
                                    <i class="fas fa-check mr-1"></i> Setujui
                                </button>
                                <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'reject')"
                                    class="flex-1 px-3 py-2 bg-red-600 text-white text-sm rounded-lg hover:bg-red-700 transition-colors">
                                    <i class="fas fa-times mr-1"></i> Tolak
                                </button>
                            @elseif ($s == 'confirmed')
                                <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'transit')"
                                    class="w-full px-3 py-2 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700 transition-colors">
                                    <i class="fas fa-motorcycle mr-1"></i> Antar Motor
                                </button>
                            @elseif ($s == 'in transit')
                                <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'inuse')"
                                    class="w-full px-3 py-2 bg-indigo-600 text-white text-sm rounded-lg hover:bg-indigo-700 transition-colors">
                                    <i class="fas fa-play mr-1"></i> Sedang Berlangsung
                                </button>
                            @elseif ($s == 'awaiting return')
                                <button onclick="handleUpdateBooking({{ $pesanan['id'] }}, 'complete')"
                                    class="w-full px-3 py-2 bg-green-600 text-white text-sm rounded-lg hover:bg-green-700 transition-colors">
                                    <i class="fas fa-undo mr-1"></i> Motor Kembali
                                </button>
                            @endif
                        </div>
                    </div>
                @endforeach
            </div>
        @endif

        <!-- Modal Detail Pemesanan -->
        <div id="bookingDetailModal"
            class="modal hidden fixed inset-0 bg-black bg-opacity-40 backdrop-blur-sm z-50 flex items-center justify-center transition-opacity duration-300 p-4">
            <div
                class="modal-content bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto relative transition-transform duration-200">
                <!-- Header dengan background gradient -->
                <div
                    class="flex justify-between items-center p-6 sticky top-0 bg-gradient-to-r from-blue-600 to-blue-500 text-white rounded-t-2xl">
                    <div class="flex items-center gap-3">
                        <div class="p-2 bg-blue-700 rounded-full">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" stroke-width="2"
                                viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M8 7V3m8 4V3m-9 8h10m-9 4h10m-3 4h3a2 2 0 002-2v-5a2 2 0 00-2-2h-3M5 21h3a2 2 0 002-2v-5a2 2 0 00-2-2H5a2 2 0 00-2 2v5a2 2 0 002 2z" />
                            </svg>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold">Detail Pemesanan</h2>
                        </div>
                    </div>
                    <button type="button" onclick="closeBookingModal()"
                        class="close-modal close-btn text-white hover:text-blue-200 text-3xl leading-none font-light transition-all duration-200">
                        &times;
                    </button>
                </div>

                <!-- Content -->
                <div class="p-6">
                    <div class="flex flex-col lg:flex-row gap-8">
                        <!-- Foto Profil dengan Frame -->
                        <div class="w-full lg:w-2/5 flex flex-col items-center">
                            <div class="relative mb-4">
                                <img id="modalCustomerPhoto" src="/placeholder.svg" alt="Foto Customer"
                                    class="w-40 h-40 object-cover rounded-xl border-4 border-white shadow-lg ring-2 ring-blue-200"
                                    onerror="this.onerror=null; this.src='{{ asset('images/default-user.png') }}'">
                            </div>

                            <!-- Info Kontak -->
                            <div class="w-full bg-gray-50 p-4 rounded-lg border border-gray-200 space-y-2">
                                <div class="flex items-center gap-2 text-gray-700">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M5.121 17.804A13.937 13.937 0 0112 15c2.761 0 5.304.804 7.879 2.196M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                    </svg>
                                    <span id="modalCustomerName">-</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                                    </svg>
                                    <span id="modalCustomerEmail">-</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                                    </svg>
                                    <span id="modalCustomerPhone">-</span>
                                </div>
                            </div>
                        </div>

                        <!-- Detail Pemesanan -->
                        <div class="w-full lg:w-3/5 space-y-5">
                            <!-- Card Tanggal -->
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div class="bg-blue-50 p-4 rounded-lg border border-blue-100">
                                    <p class="text-sm text-blue-600 font-medium">Tanggal Booking</p>
                                    <p id="modalBookingDate" class="text-lg font-semibold text-blue-800">-</p>
                                </div>
                                <div class="bg-green-50 p-4 rounded-lg border border-green-100">
                                    <p class="text-sm text-green-600 font-medium">Mulai Sewa</p>
                                    <p id="modalStartDate" class="text-lg font-semibold text-green-800">-</p>
                                </div>
                                <div class="bg-red-50 p-4 rounded-lg border border-red-100">
                                    <p class="text-sm text-red-600 font-medium">Akhir Sewa</p>
                                    <p id="modalEndDate" class="text-lg font-semibold text-red-800">-</p>
                                </div>
                            </div>

                            <!-- Card Informasi -->
                            <div class="bg-gray-50 p-5 rounded-xl border border-gray-200 space-y-4">
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800 mb-3 flex items-center gap-2">
                                        <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                            viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                        </svg>
                                        Informasi Pemesanan
                                    </h3>
                                    <div class="space-y-3">
                                        <div>
                                            <p class="text-sm text-gray-500">Tujuan Booking</p>
                                            <p id="modalPurpose" class="font-medium text-gray-800">-</p>
                                        </div>
                                        <div>
                                            <p class="text-sm text-gray-500">Lokasi Penjemputan</p>
                                            <p id="modalPickup" class="font-medium text-gray-800">-</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {{-- @dd($bookings) --}}
                            <!-- Status -->
                            <div class="bg-white p-4 rounded-lg border border-gray-200">
                                <p class="text-sm text-gray-500 mb-2">Status Pemesanan</p>
                                <div class="flex items-center gap-2">
                                    <span id="modalStatus"
                                        class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold capitalize bg-blue-100 text-blue-800">
                                        <span class="w-2 h-2 rounded-full bg-blue-600 mr-2"></span>
                                        -
                                    </span>
                                    <p id="modalStatusDescription" class="text-sm text-gray-600">Pemesanan sedang diproses
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Pagination Section -->
        <div class="mt-6 sm:mt-8 flex flex-col sm:flex-row items-center justify-between gap-4">
            <!-- Info rangkuman -->
            <div class="text-sm text-gray-600 order-2 sm:order-1">
                Menampilkan {{ $bookings->firstItem() }} - {{ $bookings->lastItem() }} dari total
                {{ $bookings->total() }} data
            </div>

            <!-- Pagination -->
            <div class="order-1 sm:order-2">
                {!! $bookings->links('layouts.pagination') !!}
            </div>
        </div>

        <!-- Modal untuk Booking Manual -->
        <div id="addBookingModal"
            class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 z-50 flex items-center justify-center p-4">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[95vh] overflow-y-auto">
                <!-- Header - Perbaikan -->
                <div class="bg-blue-600 text-white rounded-t-2xl px-4 sm:px-6 py-4 sticky top-0 z-10 shadow-md">
                    <div class="flex justify-between items-center">
                        <div>
                            <h2 class="text-xl sm:text-2xl font-bold">Tambah Booking Manual</h2>
                            <p class="text-sm text-blue-100 mt-1">Lengkapi data booking pelanggan</p>
                        </div>
                        <button type="button" onclick="closeModal('addBookingModal')"
                            class="text-white hover:text-blue-200">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Body Form -->
                <form id="manualBookingForm" action="{{ route('vendor.manual.booking.store') }}" method="POST"
                    enctype="multipart/form-data" class="p-4 sm:p-6 md:p-8">
                    @csrf
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <!-- Kolom Kiri -->
                        <div class="space-y-6">
                            <!-- Dropdown Motor -->
                            <div>
                                <label for="motor_id" class="block text-gray-700 font-semibold mb-1">Pilih Motor <span
                                        class="text-red-500">*</span></label>
                                <select name="motor_id" id="motor_id"
                                    class="w-full p-3 border rounded-lg focus:ring-2 focus:ring-blue-500">
                                    <option value="">-- Pilih Motor --</option>
                                    <!-- Opsi motor akan diisi oleh JavaScript -->
                                </select>
                                <small class="error-message text-red-500" data-field="motor_id"></small>
                            </div>

                            <!-- Nama Pelanggan -->
                            <div>
                                <label for="customer_name" class="block text-gray-700 font-semibold mb-1">Nama
                                    Pelanggan <span class="text-red-500">*</span></label>
                                <input type="text" name="customer_name" id="customer_name"
                                    class="w-full p-3 border rounded-lg">
                                <small class="error-message text-red-500" data-field="customer_name"></small>
                            </div>

                            <!-- Tanggal & Jam Mulai -->
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                <div>
                                    <label for="start_date_date" class="block text-gray-700 font-semibold mb-1">Tanggal
                                        Mulai <span class="text-red-500">*</span></label>
                                    <input type="date" name="start_date_date" id="start_date_date"
                                        class="w-full p-3 border rounded-lg">
                                    <small class="error-message text-red-500" data-field="start_date_date"></small>
                                </div>

                                <div>
                                    <label for="start_date_time" class="block text-gray-700 font-semibold mb-1">Jam
                                        Mulai <span class="text-red-500">*</span></label>
                                    <input type="time" name="start_date_time" id="start_date_time"
                                        class="w-full p-3 border rounded-lg">
                                    <small class="error-message text-red-500" data-field="start_date_time"></small>
                                </div>
                            </div>

                            <!-- Durasi -->
                            <div>
                                <label for="duration" class="block text-gray-700 font-semibold mb-1">Durasi (hari) <span
                                        class="text-red-500">*</span></label>
                                <input type="number" name="duration" id="duration"
                                    class="w-full p-3 border rounded-lg" min="1" placeholder="cth : 1">
                                <small class="error-message text-red-500" data-field="duration"></small>
                            </div>

                        </div>

                        <!-- Kolom Kanan - Upload File -->
                        <div class="space-y-6">
                            <!-- Tujuan Booking (Baru Ditambahkan) -->
                            <div>
                                <label for="purpose" class="block text-gray-700 font-semibold mb-1">Tujuan Booking <span
                                        class="text-red-500">*</span></label>
                                <input type="text" name="booking_purpose" id="booking_purpose"
                                    placeholder="cth : Liburan, Tour, dll" class="w-full p-3 border rounded-lg">
                                <small class="error-message text-red-500" data-field="booking_purpose"></small>
                            </div>
                            <!-- Foto Diri -->
                            <div>
                                <label for="photo_id" class="block text-gray-700 font-semibold mb-1">Foto Pelanggan
                                    (Opsional)</label>
                                <div class="relative group">
                                    <input type="file" name="photo_id" id="photo_id"
                                        class="w-full p-3 border rounded-lg file:transition-colors file:border-0 file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 file:rounded-md file:px-4 file:py-2">
                                </div>
                                <small class="error-message text-red-500" data-field="photo_id"></small>
                                <div id="photo_preview" class="mt-2 hidden">
                                    <img src="/placeholder.svg" alt="Preview Foto"
                                        class="w-32 h-32 object-cover rounded">
                                </div>
                            </div>

                            <!-- Foto KTP -->
                            <div>
                                <label for="ktp_id" class="block text-gray-700 font-semibold mb-1">Foto KTP
                                    (Opsional)</label>
                                <div class="relative group">
                                    <input type="file" name="ktp_id" id="ktp_id"
                                        class="w-full p-3 border rounded-lg file:transition-colors file:border-0 file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 file:rounded-md file:px-4 file:py-2">
                                </div>
                                <small class="error-message text-red-500" data-field="ktp_id"></small>
                                <div id="ktp_preview" class="mt-2 hidden">
                                    <img src="/placeholder.svg" alt="Preview KTP" class="w-32 h-32 object-cover rounded">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Lokasi Pengambilan & Penjemputan -->
                    <div class="mt-6 space-y-6">
                        <div>
                            <label for="pickup_location" class="block text-gray-700 font-semibold mb-1">Lokasi
                                Pengambilan <span class="text-red-500">*</span></label>
                            <textarea name="pickup_location" id="pickup_location" rows="3" class="w-full p-3 border rounded-lg"
                                placeholder="cth : Balige, Porsea, Laguboti, dll.."></textarea>
                            <small class="error-message text-red-500" data-field="pickup_location"></small>
                        </div>

                        <div>
                            <label for="dropoff_location" class="block text-gray-700 font-semibold mb-1">Lokasi
                                Penjemputan (Opsional)</label>
                            <textarea name="dropoff_location" id="dropoff_location" rows="3" class="w-full p-3 border rounded-lg"
                                placeholder="cth : Balige, Porsea, Laguboti, dll.."></textarea>
                            <small class="error-message text-red-500" data-field="dropoff_location"></small>
                        </div>
                    </div>

                    <!-- Hidden fields for additional data -->
                    <input type="hidden" name="type" value="manual">
                    <input type="hidden" name="status" value="confirmed">

                    <!-- Footer -->
                    <div class="bg-gray-50 px-4 sm:px-6 py-4 mt-8 border-t border-gray-200 rounded-b-2xl sticky bottom-0">
                        <div class="flex flex-col sm:flex-row justify-end gap-4">
                            <button type="button" onclick="closeModal('addBookingModal')"
                                class="px-5 py-2.5 bg-gray-400 hover:bg-gray-500 text-white rounded-lg order-2 sm:order-1">
                                Batal
                            </button>
                            <button type="submit" id="submitBtn"
                                class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg shadow order-1 sm:order-2">
                                Simpan Booking
                            </button>
                        </div>
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

            // Menerjemahkan status ke Bahasa Indonesia
            function translateStatus(status) {
                switch (status) {
                    case 'pending':
                        return 'Menunggu Konfirmasi';
                    case 'confirmed':
                        return 'Dikonfirmasi';
                    case 'in transit':
                        return 'Motor Sedang Diantar';
                    case 'in use':
                        return 'Sedang Digunakan';
                    case 'awaiting return':
                        return 'Menunggu Pengembalian';
                    case 'completed':
                        return 'Pesanan Selesai';
                    case 'rejected':
                        return 'Booking Ditolak';
                    default:
                        return status.charAt(0).toUpperCase() + status.slice(1);
                }
            }

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

            // Utility untuk format tanggal & waktu
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

            function openModal(id) {
                const m = document.getElementById(id);
                if (m) {
                    m.classList.remove('hidden');
                    document.body.style.overflow = 'hidden';

                    // Jika modal yang dibuka adalah modal tambah booking, muat data motor
                    if (id === 'addBookingModal') {
                        loadMotorData();

                        // Set tanggal default ke hari ini
                        // const today = new Date().toISOString().split('T')[0];
                        document.getElementById('start_date_date');

                        // Set waktu default ke jam sekarang
                        // const now = new Date();
                        // const hours = String(now.getHours()).padStart(2, '0');
                        // const minutes = String(now.getMinutes()).padStart(2, '0');
                        // document.getElementById('start_date_time').value = `${hours}:${minutes}`;
                    }
                }
            }

            function closeModal(id) {
                const m = document.getElementById(id);
                if (m) {
                    m.classList.add('hidden');
                    document.body.style.overflow = 'auto';
                    m.querySelectorAll('.error-message').forEach(e => e.textContent = '');

                    // Reset form jika modal booking
                    if (id === 'addBookingModal') {
                        document.getElementById('manualBookingForm').reset();
                        document.getElementById('photo_preview').classList.add('hidden');
                        document.getElementById('ktp_preview').classList.add('hidden');
                    }
                }
            }

            function closeBookingModal() {
                closeModal('bookingDetailModal');
            }

            // Tambahan fungsi notifikasi SweetAlert
            function showConfirmation(title, text, confirmText = 'Ya', cancelText = 'Batal') {
                return Swal.fire({
                    title: title,
                    text: text,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: confirmText,
                    cancelButtonText: cancelText
                });
            }

            function showSuccessAlert(message) {
                Swal.fire({
                    icon: 'success',
                    title: 'Berhasil!',
                    text: message,
                    confirmButtonColor: '#3085d6'
                });
            }

            function showErrorAlert(message) {
                Swal.fire({
                    icon: 'error',
                    title: 'Gagal!',
                    text: message,
                    confirmButtonColor: '#d33'
                });
            }

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
                        txt = 'antarkan motor';
                        url = `${BASE_API}/vendor/bookings/transit/${id}`;
                        break;
                    case 'inuse':
                        txt = 'gunakan motor';
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
                        console.log("URL:", url);
                        console.log("Token:", "{{ session('token') }}");

                        fetch(url, {
                                method: 'PUT',
                                headers: {
                                    "Authorization": "Bearer {{ session('token') }}",
                                    "Content-Type": "application/json"
                                }
                            })
                            .then(response => {
                                console.log("Status:", response.status);
                                return response.json();
                            })
                            .then(data => {
                                console.log("Response Data:", data);
                                if (data.message) {
                                    showSuccessAlert(data.message);
                                } else {
                                    showSuccessAlert('Berhasil memperbarui status.');
                                }
                                setTimeout(() => location.reload(), 1500);
                            })
                            .catch(err => {
                                console.error("Fetch Error:", err);
                                showErrorAlert('Terjadi kesalahan: ' + err.message);
                            });
                    });
            }

            // Saat halaman siap
            document.addEventListener('DOMContentLoaded', () => {
                // Format semua elemen dengan class .format-datetime
                document.querySelectorAll('.format-datetime').forEach(el => {
                    el.textContent = formatDateTime(el.textContent.trim());
                });

                // 1. Definisikan mapping kelas warna untuk tiap status
                const statusClasses = {
                    'pending': 'bg-yellow-100 text-yellow-800',
                    'confirmed': 'bg-blue-100 text-blue-800',
                    'in transit': 'bg-indigo-100 text-indigo-800',
                    'in use': 'bg-purple-100 text-purple-800',
                    'awaiting return': 'bg-orange-100 text-orange-800',
                    'completed': 'bg-green-100 text-green-800',
                    'rejected': 'bg-red-100 text-red-800',
                };

                // 2. Fungsi terjemahan label status
                function translateStatus(status) {
                    const labels = {
                        'pending': 'Menunggu Konfirmasi',
                        'confirmed': 'Dikonfirmasi',
                        'in transit': 'Motor Diantar',
                        'in use': 'Sedang Digunakan',
                        'awaiting return': 'Menunggu Pengembalian',
                        'completed': 'Selesai',
                        'rejected': 'Ditolak',
                    };
                    return labels[status] || status.charAt(0).toUpperCase() + status.slice(1);
                }

                // 3. Event listener untuk buka modal
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

                        // Set teks-teks lain...
                        document.getElementById('modalCustomerName').textContent = data.customer_name ||
                            '-';
                        document.getElementById('modalCustomerEmail').textContent = data
                            .customer_email ||
                            '-';
                        document.getElementById('modalCustomerPhone').textContent = data
                            .customer_phone ||
                            '-';
                        document.getElementById('modalBookingDate').textContent = formatDateTime(data
                            .booking_date);
                        document.getElementById('modalStartDate').textContent = formatDateTime(data
                            .start_date);
                        document.getElementById('modalEndDate').textContent = formatDateTime(data
                            .end_date);
                        document.getElementById('modalPurpose').textContent = data.booking_purpose ||
                            '-';
                        document.getElementById('modalPickup').textContent = data.pickup_location ||
                            '-';

                        // 4. Set teks dan kelas badge status
                        const statusEl = document.getElementById('modalStatus');
                        const statusKey = data.status || 'pending';
                        statusEl.textContent = translateStatus(statusKey);
                        // Reset dulu kelas dasar
                        statusEl.className = [
                            'inline-block',
                            'ml-2',
                            'px-3',
                            'py-1',
                            'text-sm',
                            'font-semibold',
                            'rounded-full',
                            'capitalize',
                            // tambahkan warna sesuai status, atau abu-abu jika tidak ada mapping
                            statusClasses[statusKey] || 'bg-gray-100 text-gray-800'
                        ].join(' ');

                        // Set foto
                        const imgEl = document.getElementById('modalCustomerPhoto');
                        imgEl.onerror = () => {
                            imgEl.onerror = null;
                            imgEl.src = '/images/default-user.png';
                        };
                        if (data.potoid) {
                            const isAbsolute = /^https?:\/\//i.test(data.potoid);
                            imgEl.src = isAbsolute ? data.potoid : `${BASE_API}${data.potoid}`;
                        } else {
                            imgEl.src = '/images/default-user.png';
                        }

                        openModal('bookingDetailModal');
                    });
                });

                // Preview foto yang diupload
                document.getElementById('photo_id')?.addEventListener('change', function(e) {
                    const file = e.target.files[0];
                    if (file) {
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            const preview = document.getElementById('photo_preview');
                            preview.querySelector('img').src = e.target.result;
                            preview.classList.remove('hidden');
                        }
                        reader.readAsDataURL(file);
                    }
                });

                document.getElementById('ktp_id')?.addEventListener('change', function(e) {
                    const file = e.target.files[0];
                    if (file) {
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            const preview = document.getElementById('ktp_preview');
                            preview.querySelector('img').src = e.target.result;
                            preview.classList.remove('hidden');
                        }
                        reader.readAsDataURL(file);
                    }
                });

                // Form submission
                const form = document.getElementById('manualBookingForm');
                if (form) {
                    form.addEventListener('submit', function(e) {
                        e.preventDefault();

                        // Clear previous errors
                        form.querySelectorAll('.error-message').forEach(el => el.textContent = '');

                        // Validasi form
                        const errors = validateForm(form);
                        if (Object.keys(errors).length > 0) {
                            // Tampilkan error
                            for (const [field, message] of Object.entries(errors)) {
                                const errorEl = form.querySelector(`.error-message[data-field="${field}"]`);
                                if (errorEl) errorEl.textContent = message;
                            }
                            return;
                        }

                        // Tampilkan loading
                        const submitBtn = document.getElementById('submitBtn');
                        const originalText = submitBtn.textContent;
                        submitBtn.disabled = true;
                        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Menyimpan...';

                        // Submit form
                        const formData = new FormData(form);

                        // Kirim ke server
                        fetch(form.action, {
                                method: 'POST',
                                body: formData,
                                headers: {
                                    'X-Requested-With': 'XMLHttpRequest',
                                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')
                                        ?.getAttribute('content') ||
                                        form.querySelector('input[name="_token"]').value
                                }
                            })
                            .then(async response => {
                                const contentType = response.headers.get('content-type');
                                let data;

                                if (contentType && contentType.includes('application/json')) {
                                    data = await response.json();
                                } else {
                                    data = {
                                        error: 'Response tidak dalam format JSON'
                                    };
                                }

                                if (response.ok && data.message && !data.error) {
                                    // Sukses
                                    showSuccessAlert(data.message);
                                    closeModal('addBookingModal');
                                    setTimeout(() => location.reload(), 1500);
                                } else {
                                    // Error - prioritaskan error dari API
                                    if (data.error) {
                                        showErrorAlert(data.error);
                                    } else if (data.errors) {
                                        // Validation errors
                                        let errorMessages = [];
                                        for (const [field, messages] of Object.entries(data.errors)) {
                                            const errorEl = form.querySelector(
                                                `.error-message[data-field="${field}"]`);
                                            if (errorEl) {
                                                errorEl.textContent = Array.isArray(messages) ?
                                                    messages[0] : messages;
                                            }
                                            errorMessages.push(Array.isArray(messages) ? messages[0] :
                                                messages);
                                        }
                                        if (errorMessages.length > 0) {
                                            showErrorAlert('Terdapat kesalahan pada form: ' +
                                                errorMessages.join(', '));
                                        }
                                    } else if (data.message) {
                                        showErrorAlert(data.message);
                                    } else {
                                        showErrorAlert('Terjadi kesalahan saat menyimpan booking');
                                    }
                                }
                            })
                            .catch(error => {
                                console.error('Network Error:', error);
                                showErrorAlert('Terjadi kesalahan jaringan: ' + error.message);
                            })
                            .finally(() => {
                                // Reset button
                                submitBtn.disabled = false;
                                submitBtn.innerHTML = originalText;
                            });
                    });
                }
            });

            // Validasi form
            function validateForm(form) {
                const errors = {};

                // Validasi field wajib
                const requiredFields = [{
                        name: 'motor_id',
                        label: 'Motor'
                    },
                    {
                        name: 'customer_name',
                        label: 'Nama Pelanggan'
                    },
                    {
                        name: 'booking_purpose',
                        label: 'Tujuan Booking'
                    },
                    {
                        name: 'start_date_date',
                        label: 'Tanggal Mulai'
                    },
                    {
                        name: 'start_date_time',
                        label: 'Jam Mulai'
                    },
                    {
                        name: 'duration',
                        label: 'Durasi'
                    },
                    {
                        name: 'pickup_location',
                        label: 'Lokasi Pengambilan'
                    }
                ];

                requiredFields.forEach(field => {
                    const value = form[field.name].value.trim();
                    if (!value) {
                        errors[field.name] = `${field.label} harus diisi`;
                    }
                });

                // Validasi tambahan
                const purpose = form.booking_purpose.value.trim();
                if (purpose && purpose.length < 5) {
                    errors.booking_purpose = 'Tujuan booking minimal 5 karakter';
                }

                const customerName = form.customer_name.value.trim();
                if (customerName && customerName.length < 3) {
                    errors.customer_name = 'Nama minimal 3 karakter';
                }

                const durationRaw = form.duration.value.trim();
                if (!durationRaw) {
                    errors.duration = 'Durasi harus diisi';
                } else {
                    const duration = parseInt(durationRaw);
                    if (isNaN(duration) || duration <= 0) {
                        errors.duration = 'Durasi harus lebih dari 0';
                    }
                }


                const startDateValue = form.start_date_date.value.trim();
                const startTimeValue = form.start_date_time.value.trim();

                if (!startDateValue) {
                    errors.start_date_date = 'Tanggal mulai harus diisi';
                } else {
                    const startDate = new Date(startDateValue);
                    const today = new Date();
                    today.setHours(0, 0, 0, 0);
                    if (startDate < today) {
                        errors.start_date_date = 'Tanggal tidak boleh kurang dari hari ini';
                    }
                }

                if (!startTimeValue) {
                    errors.start_date_time = 'Jam mulai harus diisi';
                }



                // Validasi file
                ['photo_id', 'ktp_id'].forEach(fieldName => {
                    const file = form[fieldName]?.files[0];
                    if (file) {
                        if (!['image/jpeg', 'image/png', 'image/jpg'].includes(file.type)) {
                            errors[fieldName] = 'File harus JPG atau PNG';
                        }
                        if (file.size > 2 * 1024 * 1024) {
                            errors[fieldName] = 'Ukuran file maksimal 2MB';
                        }
                    }
                });

                return errors;
            }

            // Fungsi untuk memuat data motor
            async function loadMotorData() {
                try {
                    const response = await fetch(`${BASE_API}/motor/vendor/`, {
                        method: 'GET',
                        headers: {
                            "Authorization": "Bearer {{ session('token') }}",
                            "Content-Type": "application/json"
                        }
                    });

                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }

                    const result = await response.json();

                    if (result.data && Array.isArray(result.data)) {
                        populateMotorDropdown(result.data);
                    } else {
                        console.error('Format data motor tidak sesuai:', result);
                        showErrorAlert('Gagal memuat data motor: Format data tidak sesuai');
                    }
                } catch (error) {
                    console.error('Error loading motor data:', error);
                    showErrorAlert('Gagal memuat data motor: ' + error.message);
                }
            }

            // Fungsi untuk mengisi dropdown motor
            function populateMotorDropdown(motors) {
                const motorSelect = document.getElementById('motor_id');

                // Hapus opsi yang ada kecuali opsi default
                motorSelect.innerHTML = '<option value="">-- Pilih Motor --</option>';

                // Tambahkan opsi motor
                motors.forEach(motor => {
                    const option = document.createElement('option');
                    option.value = motor.id;

                    const statusText = motor.status === 'available' ? '' : ` (${motor.status})`;
                    option.textContent =
                        `${motor.name} - ${motor.brand} (${motor.year}) - Rp ${motor.price.toLocaleString('id-ID')}/hari - ${motor.platmotor}${statusText}`;
                    option.setAttribute('data-motor', JSON.stringify(motor));

                    if (motor.status !== 'available') {
                        option.style.color = '#6B7280';
                        option.style.fontStyle = 'italic';
                    }

                    motorSelect.appendChild(option);
                });
            }
        </script>
    </div>
@endsection
