@extends('layouts.app')

@section('title', 'Transaksi Vendor Rental')

@section('content')
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    @if (session('message'))
        <script>
            Swal.fire({
                icon: 'success',
                title: 'Berhasil!',
                text: '{{ session('message') }}',
                confirmButtonText: 'OK'
            });
        </script>
    @endif

    @if (session('error'))
        <script>
            Swal.fire({
                icon: 'error',
                title: 'Gagal',
                text: '{{ session('error') }}',
                confirmButtonText: 'OK'
            });
        </script>
    @endif

    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-4xl font-extrabold text-gray-800">Data Transaksi Vendor</h1>
            <button onclick="openModal('printModal')" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                Cetak Laporan
            </button>
        </div>

        @if (session('error'))
            <div class="mb-4 p-4 bg-red-100 border border-red-300 text-red-700 rounded">
                {{ session('error') }}
            </div>
        @endif
        @if ($transactions->count())
            <div class="space-y-4">
                @foreach ($transactions as $t)
                    {{-- @dd($transactions) --}}
                    <div class="p-4 bg-white shadow rounded cursor-pointer hover:bg-gray-100 transition flex justify-between items-center"
                        onclick='showTransactionDetails(@json($t))'>
                        <div>
                            @php
                                // Mapping status ke Bahasa Indonesia
                                $statusMap = [
                                    'completed' => 'Pesanan Selesai',
                                ];
                                $raw = strtolower($t['status']);
                                $statusText = $statusMap[$raw] ?? ucfirst($raw);
                            @endphp

                            <h3 class="text-lg font-semibold">
                                {{ $t['customer_name'] }} –
                                <span class="text-blue-700 font-bold">
                                    {{ $statusText }}
                                </span>
                            </h3>

                            <p class="text-sm text-gray-500 flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                                Booking:
                                {{ \Carbon\Carbon::parse($t['booking_date'])->locale('id')->translatedFormat('j F Y') }}
                                <span class="ml-1">• Pukul
                                    {{ \Carbon\Carbon::parse($t['booking_date'])->translatedFormat('H:i') }} WIB</span>
                            </p>
                        </div>
                        <div class="text-green-700 font-bold">
                            Rp {{ number_format($t['total_price'], 0, ',', '.') }}
                        </div>
                    </div>
                @endforeach
            </div>

            <div class="mt-8 flex justify-between items-center text-sm text-gray-600">
                <div>
                    Menampilkan {{ $transactions->firstItem() }}–{{ $transactions->lastItem() }}
                    dari {{ $transactions->total() }} data
                </div>
                <div>{!! $transactions->links('layouts.pagination') !!}</div>
            </div>
        @else
            <div
                class="flex flex-col items-center justify-center text-center p-6 bg-yellow-100 text-yellow-800 rounded shadow">
                <i class="fas fa-file-invoice-dollar fa-3x mb-4"></i>
                <h2 class="text-xl font-semibold">Belum Ada Transaksi</h2>
                <p class="mt-2">Tidak ada data transaksi yang tersedia.</p>
            </div>
        @endif
    </div>

    <!-- Modal Detail Transaksi -->
    <div id="transactionDetailModal"
        class="fixed inset-0 z-50 hidden bg-black bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-2xl shadow-xl w-full max-w-3xl p-6 relative flex flex-col">
            <button onclick="closeModal('transactionDetailModal')"
                class="absolute top-4 right-4 text-gray-500 hover:text-red-500">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>
            <h2 class="text-xl font-bold mb-4 flex items-center gap-2 justify-start">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" stroke-width="2"
                    viewBox="0 0 24 24">
                    <path d="M5 13l4 4L19 7" />
                </svg>
                Transaction Details
            </h2>
            <div id="transactionDetailContent" class="flex flex-col sm:flex-row justify-center gap-4 text-sm text-gray-700">
                <!-- akan diisi oleh JS -->
            </div>
        </div>

    </div>
    <div id="printModal" class="fixed inset-0 hidden bg-gray-900 bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg shadow-xl overflow-hidden w-11/12 md:w-1/2 lg:w-1/3">
            <!-- Header dengan background biru -->
            <div class="bg-blue-600 text-white p-4">
                <div class="flex items-center justify-between">
                    <h2 class="text-xl md:text-2xl font-bold flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                        </svg>
                        Cetak Laporan Transaksi Bulanan
                    </h2>
                    <button onclick="closeModal('printModal')" class="text-white hover:text-gray-200">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
                <p class="text-blue-100 text-sm mt-1">Pilih periode laporan yang ingin dicetak</p>
            </div>

            <!-- Body Form -->
            <div class="p-6">
                @php
                    $bulan = [
                        1 => 'Januari',
                        2 => 'Februari',
                        3 => 'Maret',
                        4 => 'April',
                        5 => 'Mei',
                        6 => 'Juni',
                        7 => 'Juli',
                        8 => 'Agustus',
                        9 => 'September',
                        10 => 'Oktober',
                        11 => 'November',
                        12 => 'Desember',
                    ];
                @endphp
                <form action="{{ route('vendor.transactions.export') }}" method="GET">
                    <div class="mb-6">
                        <label for="month" class="block text-gray-700 font-medium mb-2">
                            Pilih Bulan & Tahun
                        </label>
                        <div class="grid grid-cols-2 gap-4">
                            <div class="relative">
                                <select name="month" id="month"
                                    class="block appearance-none w-full bg-gray-50 border border-gray-300 text-gray-700 py-2 px-4 pr-8 rounded-lg leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                    required>
                                    <option value="" disabled selected>Pilih Bulan</option>
                                    @for ($m = 1; $m <= 12; $m++)
                                        <option value="{{ $m }}">{{ $bulan[$m] }}</option>
                                    @endfor
                                </select>
                                <div
                                    class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                                    <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg"
                                        viewBox="0 0 20 20">
                                        <path
                                            d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" />
                                    </svg>
                                </div>
                            </div>
                            <div class="relative">
                                <select name="year" id="year"
                                    class="block appearance-none w-full bg-gray-50 border border-gray-300 text-gray-700 py-2 px-4 pr-8 rounded-lg leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                    required>
                                    <option value="" disabled selected>Pilih Tahun</option>
                                    @for ($y = now()->year; $y >= now()->year - 5; $y--)
                                        <option value="{{ $y }}">{{ $y }}</option>
                                    @endfor
                                </select>
                                <div
                                    class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                                    <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg"
                                        viewBox="0 0 20 20">
                                        <path
                                            d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" />
                                    </svg>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="flex justify-end space-x-3 mt-8">
                        <button type="button" onclick="closeModal('printModal')"
                            class="px-5 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition duration-200 font-medium">
                            Batal
                        </button>
                        <button type="submit" onclick="exportAlert()"
                            class="px-5 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition duration-200 font-medium flex items-center">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                            </svg>
                            Export Excel
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function exportAlert() {
            setTimeout(() => {
                Swal.fire({
                    icon: 'success',
                    title: 'Berhasil!',
                    text: 'Laporan transaksi berhasil diunduh.',
                    confirmButtonText: 'OK'
                }).then((result) => {
                    if (result.isConfirmed) {
                        // Tutup modal dan reset form
                        closeModal('printModal');
                        document.querySelector('#printModal form').reset();
                    }
                });
            }, 1000);
        }

        function openModal(id) {
            document.getElementById(id).classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeModal(id) {
            document.getElementById(id).classList.add('hidden');
            document.body.style.overflow = '';
        }

        function renderItem(label, value) {
            return `
                        <div class="flex flex-col">
                            <span class="text-gray-500 text-sm">${label}</span>
                            <span class="text-base font-semibold text-gray-900">${value}</span>
                        </div>`;
        }

        // Fungsi translate status ke Bahasa Indonesia
        function translateStatus(status) {
            if (!status) return '-';
            const map = {
                completed: 'Pesanan Selesai'
            };
            return map[status.toLowerCase()] || status;
        }

        function showTransactionDetails(transaction) {
            // Hanya completed yang punya warna khusus
            const statusColor = {
                completed: "bg-green-100 text-green-700"
            };
            const raw = (transaction.status || '').toLowerCase();
            const statusClass = statusColor[raw] || "bg-gray-100 text-gray-700";
            const statusText = translateStatus(raw);

            const detailTransaksi = `
                        <div class="w-full sm:w-1/2 px-4">
                            <h3 class="text-md font-semibold mb-3 text-blue-600 flex items-center gap-2">
                                <!-- icon -->
                                Detail Transaksi
                            </h3>
                            <div class="flex flex-col gap-3">
                                ${renderItem("Nama Customer", transaction.customer_name)}
                                ${renderItem("Tanggal Booking", formatTanggalDenganJam(transaction.booking_date))}
${renderItem("Tanggal Mulai", new Date(transaction.start_date).toLocaleDateString('id-ID', {
    day: 'numeric', month: 'long', year: 'numeric'
}))}
${renderItem("Tanggal Selesai", new Date(transaction.end_date).toLocaleDateString('id-ID', {
    day: 'numeric', month: 'long', year: 'numeric'
}))}

                                ${renderItem("Lokasi Jemput", transaction.pickup_location)}
                                <div class="flex flex-col">
                                    <span class="text-gray-500 text-sm">Status</span>
                                    <span class="inline-block mt-1 px-3 py-1 text-xs rounded-full font-semibold ${statusClass}">
                                        ${statusText}
                                    </span>
                                </div>
                                ${renderItem("Total Harga", `Rp ${transaction.total_price.toLocaleString('id-ID')}`)}
                            </div>
                        </div>`;

            const detailMotor = transaction.motor ? `
                        <div class="w-full sm:w-1/2 px-4 mt-8 sm:mt-0">
                            <h3 class="text-md font-semibold mb-3 text-indigo-600 flex items-center gap-2">
                                <!-- icon -->
                                Informasi Motor
                            </h3>
                            <div class="flex flex-col gap-3">
                                ${renderItem("Nama", transaction.motor.name)}
                                ${renderItem("Merek", transaction.motor.brand)}
                                ${renderItem("Tahun", transaction.motor.year)}
                                ${renderItem("Plat Motor", transaction.motor.platmotor)}
                                ${renderItem("Harga / Hari", `Rp ${transaction.motor.price_per_day.toLocaleString('id-ID')}`)}
                            </div>
                        </div>` : "";

            document.getElementById('transactionDetailContent').innerHTML =
                `<div class="flex flex-col sm:flex-row bg-white rounded-xl p-6 max-w-4xl shadow-xl w-full">
                            ${detailTransaksi}
                            ${detailMotor}
                        </div>`;

            openModal('transactionDetailModal');
        }

        function formatTanggalDenganJam(dateString) {
            const date = new Date(dateString);
            const tanggal = date.toLocaleDateString('id-ID', {
                day: 'numeric',
                month: 'long',
                year: 'numeric'
            });
            const jam = date.toLocaleTimeString('id-ID', {
                hour: '2-digit',
                minute: '2-digit',
                hour12: false
            }).replace('.', ':'); // Optional, kalau format jamnya misal 21.42 → 21:42

            return `${tanggal}, Pukul ${jam} WIB`;
        }
    </script>
@endsection
