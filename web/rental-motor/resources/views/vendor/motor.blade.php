@extends('layouts.app')

@section('title', 'Motor Vendor Rental')

@section('content')
    <!-- Sertakan SweetAlert2 dari CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

    {{-- Menampilkan pesan sukses atau error menggunakan SweetAlert2 --}}
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            @if (session()->has('message'))
                Swal.fire({
                    title: "{{ session('type') == 'success' ? 'Berhasil!' : 'Gagal!' }}",
                    text: {!! json_encode(session('message')) !!},
                    icon: "{{ session('type') }}",
                    confirmButtonText: 'OK',
                    confirmButtonColor: '#3085d6'
                });
            @endif
        });
    </script>

    <div class="p-3 sm:p-4 lg:p-6 bg-gray-100 min-h-screen">
        {{-- Toolbar --}}
        <div class="flex flex-col lg:flex-row items-start lg:items-center justify-between mb-4 sm:mb-6 space-y-4 lg:space-y-0">
            <div class="w-full lg:w-auto">
                <h1 class="text-xl sm:text-2xl font-semibold text-gray-800">Daftar Motor Vendor</h1>
                <p class="text-sm text-gray-500 mt-1">Kelola semua motor yang tersedia</p>
            </div>
            
            <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 w-full lg:w-auto">
                <div class="relative flex-1 sm:flex-none sm:w-64">
                    <!-- Icon kaca pembesar -->
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5 text-gray-400" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </div>

                    <!-- Input dengan padding-left untuk ikon -->
                    <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Cari motor..."
                        class="w-full border rounded-md px-3 py-2 pl-10 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>

                <button id="openAddModalBtn"
                    class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition text-sm sm:text-base whitespace-nowrap">
                    <i class="fas fa-plus mr-1 sm:mr-2"></i>Tambah Motor
                </button>
            </div>
        </div>

        <!-- Filter Section -->
        <form method="GET" class="flex flex-col sm:flex-row items-start sm:items-center gap-3 sm:gap-4 mb-4 sm:mb-6">
            <div class="flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5 text-gray-700" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L15 13.414V19a1 1 0 01-1.447.894l-4-2A1 1 0 019 17v-3.586L3.293 6.707A1 1 0 013 6V4z" />
                </svg>
                <span class="text-sm text-gray-700 font-medium">Status</span>
            </div>

            <div class="relative w-full sm:w-60">
                <select id="status" name="status" onchange="this.form.submit()"
                    class="block w-full pl-3 pr-8 py-2 bg-white border border-gray-300 rounded-lg text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm appearance-none">
                    <option value="all" {{ request('status', 'all') === 'all' ? 'selected' : '' }}>🔄 Semua</option>
                    <option value="available" {{ request('status') === 'available' ? 'selected' : '' }}>✅ Motor Tersedia</option>
                    <option value="booked" {{ request('status') === 'booked' ? 'selected' : '' }}>📦 Motor Sedang Dibooking</option>
                    <option value="unavailable" {{ request('status') === 'unavailable' ? 'selected' : '' }}>🛑 Motor Rusak</option>
                </select>

                <!-- Ikon panah bawah -->
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-gray-500" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                    </svg>
                </div>
            </div>
        </form>

        {{-- Desktop Table View --}}
        <div class="hidden xl:block overflow-x-auto w-full">
            <table id="motorTable" class="w-full table-auto bg-white divide-y divide-gray-200 shadow rounded-lg">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-3 sm:px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Gambar</th>
                        <th class="px-3 sm:px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Informasi Motor</th>
                        <th class="px-3 sm:px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipe</th>
                        <th class="px-3 sm:px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Rating</th>
                        <th class="px-3 sm:px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Harga</th>
                        <th class="px-3 sm:px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Aksi</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-100">
                    @forelse ($motors as $motor)
                        <tr class="hover:bg-gray-50">
                            {{-- Gambar --}}
                            <td class="px-3 sm:px-4 py-3 whitespace-nowrap">
                                @if (!empty($motor['image_url']))
                                    <img src="{{ $motor['image_url'] }}" alt="Motor"
                                        class="h-12 w-16 sm:h-16 sm:w-24 object-cover rounded-md">
                                @else
                                    <span class="text-gray-400 italic">–</span>
                                @endif
                            </td>

                            {{-- Informasi Motor --}}
                            <td class="px-3 sm:px-4 py-3 text-sm text-gray-700">
                                <div class="flex flex-col space-y-1">
                                    <span><strong>Nama Motor:</strong> {{ $motor['name'] }}</span>
                                    <span><strong>Merek Motor:</strong> {{ $motor['brand'] }}</span>
                                    <span><strong>Tahun:</strong> {{ $motor['year'] }}</span>
                                    <span><strong>Warna:</strong> {{ $motor['color'] }}</span>
                                    <span><strong>Plat Motor:</strong> {{ $motor['platmotor'] }}</span>
                                    <span><strong>Status Motor:</strong>
                                        @switch($motor['status'])
                                            @case('unavailable')
                                                <span class="inline-block px-2 py-1 text-xs font-semibold bg-red-100 text-red-700 rounded-full">Motor Rusak</span>
                                            @break
                                            @case('available')
                                                <span class="inline-block px-2 py-1 text-xs font-semibold bg-green-100 text-green-700 rounded-full">Motor Tersedia</span>
                                            @break
                                            @case('booked')
                                                <span class="inline-block px-2 py-1 text-xs font-semibold bg-yellow-100 text-yellow-700 rounded-full">Motor Sedang Dibooking</span>
                                            @break
                                            @default
                                                <span class="inline-block px-2 py-1 text-xs font-semibold bg-gray-100 text-gray-700 rounded-full">Status Tidak Diketahui</span>
                                        @endswitch
                                    </span>
                                    <span><strong>Deskripsi:</strong> {{ Str::limit($motor['description'], 50) }}</span>
                                </div>
                            </td>

                            {{-- Tipe --}}
                            <td class="px-3 sm:px-4 py-3 whitespace-nowrap">
                                <span class="inline-block bg-blue-100 text-blue-800 text-xs font-semibold px-2 py-1 rounded">
                                    @switch($motor['type'])
                                        @case('automatic') Matic @break
                                        @case('manual') Manual @break
                                        @case('clutch') Kopling @break
                                        @case('vespa') Vespa @break
                                        @default -
                                    @endswitch
                                </span>
                            </td>

                            {{-- Rating --}}
                            <td class="px-3 sm:px-4 py-3 text-center">
                                <div class="flex justify-center items-center space-x-1">
                                    @php $stars = intval($motor['rating'] ?? 0); @endphp
                                    @for ($i = 0; $i < $stars; $i++)
                                        <i class="bi bi-star-fill text-yellow-400 text-sm"></i>
                                    @endfor
                                    @for ($i = $stars; $i < 5; $i++)
                                        <i class="bi bi-star text-gray-300 text-sm"></i>
                                    @endfor
                                </div>
                            </td>

                            {{-- Harga --}}
                            <td class="px-3 sm:px-4 py-3 whitespace-nowrap text-right text-sm font-semibold text-green-600">
                                Rp {{ number_format($motor['price'], 0, ',', '.') }}
                            </td>

                            {{-- Aksi --}}
                            <td class="px-3 sm:px-4 py-3 whitespace-nowrap text-center text-sm font-medium">
                                <div class="flex justify-center space-x-2">
                                    <button onclick="openEditModal({{ json_encode($motor) }})"
                                        class="inline-flex items-center px-2 py-2 border border-blue-500 rounded hover:bg-blue-50">
                                        <svg class="h-4 w-4 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M15.232 5.232l3.536 3.536M9 11l3 3L21 5l-3-3L9 11z" />
                                        </svg>
                                    </button>
                                    <button onclick="openDeleteModal({{ json_encode($motor) }})"
                                        class="inline-flex items-center px-2 py-2 border border-red-500 rounded hover:bg-red-50">
                                        <svg class="h-4 w-4 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5-4h4m-4 0a1 1 0 00-1 1v1h6V4a1 1 0 00-1-1m-4 0h4" />
                                        </svg>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="py-12">
                                <div class="flex flex-col items-center justify-center text-center p-10 bg-white rounded-lg shadow-md">
                                    <div class="text-gray-400 text-5xl mb-4">
                                        <i class="fas fa-search-minus"></i>
                                    </div>
                                    <h2 class="text-2xl font-semibold text-gray-700">Tidak Ada Motor Ditemukan</h2>
                                    <p class="text-gray-600 mt-2">Sepertinya tidak ada motor yang sesuai dengan Status yang dipilih.</p>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        {{-- Mobile Card View --}}
        <div class="xl:hidden space-y-4">
            @forelse ($motors as $motor)
                <div class="bg-white rounded-lg shadow-md border border-gray-200 p-4">
                    <!-- Header -->
                    <div class="flex items-start gap-3 mb-3">
                        <!-- Motor Image -->
                        <div class="flex-shrink-0">
                            @if (!empty($motor['image_url']))
                                <img src="{{ $motor['image_url'] }}" alt="Motor"
                                    class="h-16 w-20 sm:h-20 sm:w-24 object-cover rounded-md">
                            @else
                                <div class="h-16 w-20 sm:h-20 sm:w-24 bg-gray-200 rounded-md flex items-center justify-center">
                                    <i class="fas fa-motorcycle text-gray-400"></i>
                                </div>
                            @endif
                        </div>

                        <!-- Motor Info -->
                        <div class="flex-1 min-w-0">
                            <h3 class="font-semibold text-gray-800 text-sm sm:text-base truncate">{{ $motor['name'] }}</h3>
                            <p class="text-xs sm:text-sm text-gray-600">{{ $motor['brand'] }} • {{ $motor['year'] }}</p>
                            <p class="text-xs sm:text-sm text-gray-600">{{ $motor['color'] }} • {{ $motor['platmotor'] }}</p>
                            
                            <!-- Status Badge -->
                            <div class="mt-2">
                                @switch($motor['status'])
                                    @case('unavailable')
                                        <span class="inline-block px-2 py-1 text-xs font-semibold bg-red-100 text-red-700 rounded-full">Motor Rusak</span>
                                    @break
                                    @case('available')
                                        <span class="inline-block px-2 py-1 text-xs font-semibold bg-green-100 text-green-700 rounded-full">Motor Tersedia</span>
                                    @break
                                    @case('booked')
                                        <span class="inline-block px-2 py-1 text-xs font-semibold bg-yellow-100 text-yellow-700 rounded-full">Motor Sedang Dibooking</span>
                                    @break
                                    @default
                                        <span class="inline-block px-2 py-1 text-xs font-semibold bg-gray-100 text-gray-700 rounded-full">Status Tidak Diketahui</span>
                                @endswitch
                            </div>
                        </div>

                        <!-- Price -->
                        <div class="text-right flex-shrink-0">
                            <p class="text-sm sm:text-base font-semibold text-green-600">
                                Rp {{ number_format($motor['price'], 0, ',', '.') }}
                            </p>
                        </div>
                    </div>

                    <!-- Details -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs sm:text-sm mb-3">
                        <div>
                            <span class="font-medium text-gray-600">Tipe:</span>
                            <span class="inline-block bg-blue-100 text-blue-800 text-xs font-semibold px-2 py-1 rounded ml-1">
                                @switch($motor['type'])
                                    @case('automatic') Matic @break
                                    @case('manual') Manual @break
                                    @case('clutch') Kopling @break
                                    @case('vespa') Vespa @break
                                    @default -
                                @endswitch
                            </span>
                        </div>
                        <div>
                            <span class="font-medium text-gray-600">Rating:</span>
                            <div class="inline-flex items-center ml-1">
                                @php $stars = intval($motor['rating'] ?? 0); @endphp
                                @for ($i = 0; $i < $stars; $i++)
                                    <i class="bi bi-star-fill text-yellow-400 text-xs"></i>
                                @endfor
                                @for ($i = $stars; $i < 5; $i++)
                                    <i class="bi bi-star text-gray-300 text-xs"></i>
                                @endfor
                            </div>
                        </div>
                        <div class="sm:col-span-2">
                            <span class="font-medium text-gray-600">Deskripsi:</span>
                            <p class="text-gray-800 mt-1">{{ $motor['description'] }}</p>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="flex gap-2">
                        <button onclick="openEditModal({{ json_encode($motor) }})"
                            class="flex-1 inline-flex items-center justify-center px-3 py-2 border border-blue-500 rounded hover:bg-blue-50 text-sm">
                            <svg class="h-4 w-4 text-blue-500 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M15.232 5.232l3.536 3.536M9 11l3 3L21 5l-3-3L9 11z" />
                            </svg>
                            Edit
                        </button>
                        <button onclick="openDeleteModal({{ json_encode($motor) }})"
                            class="flex-1 inline-flex items-center justify-center px-3 py-2 border border-red-500 rounded hover:bg-red-50 text-sm">
                            <svg class="h-4 w-4 text-red-500 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5-4h4m-4 0a1 1 0 00-1 1v1h6V4a1 1 0 00-1-1m-4 0h4" />
                            </svg>
                            Hapus
                        </button>
                    </div>
                </div>
            @empty
                <div class="flex flex-col items-center justify-center text-center p-6 sm:p-10 bg-white rounded-lg shadow-md">
                    <div class="text-gray-400 text-3xl sm:text-5xl mb-4">
                        <i class="fas fa-search-minus"></i>
                    </div>
                    <h2 class="text-lg sm:text-2xl font-semibold text-gray-700">Tidak Ada Motor Ditemukan</h2>
                    <p class="text-gray-600 mt-2 text-sm sm:text-base">Sepertinya tidak ada motor yang sesuai dengan Status yang dipilih.</p>
                </div>
            @endforelse
        </div>

        <!-- Modal Tambah/Edit/Hapus Motor -->
        @include('layouts.modal_motor_vendor')

        <script>
            // ========== FILTER TABLE ==========
            function filterTable() {
                const q = document.getElementById('searchInput').value.toLowerCase();
                document.querySelectorAll('#motorTable tbody tr, .xl\\:hidden > div').forEach(row => {
                    row.style.display = row.innerText.toLowerCase().includes(q) ? '' : 'none';
                });
            }

            // ========== MODAL: ADD ==========
            document.getElementById('openAddModalBtn').addEventListener('click', function() {
                const form = document.getElementById('addMotorForm');
                form.reset();
                form.querySelectorAll('.error-message').forEach(el => el.textContent = '');
                document.getElementById('addModal').style.display = 'flex';
            });

            function closeAddModal() {
                document.getElementById('addModal').style.display = 'none';
            }

            // ========== MODAL: EDIT ==========
            function openEditModal(motor) {
                document.getElementById('editModal').style.display = 'flex';

                // Isi semua field
                document.getElementById('editMotorName').value = motor.name;
                document.getElementById('editMotorBrand').value = motor.brand;
                document.getElementById('editMotorYear').value = motor.year;
                document.getElementById('editMotorColor').value = motor.color;
                document.getElementById('editMotorPrice').value = motor.price;
                document.getElementById('editMotorPlatMotor').value = motor.platmotor;
                document.getElementById('editMotortype').value = motor.type.toLowerCase();
                document.getElementById('editMotorDescription').value = motor.description;
                document.getElementById('editMotorStatus').value = motor.status;
                setEditFormAction(motor.id);

                // Reset semua opsi status
                const sel = document.getElementById('editMotorStatus');
                sel.querySelectorAll('option').forEach(opt => {
                    opt.disabled = false;
                    opt.style.display = '';
                });

                // Logic untuk status transitions
                if (motor.status === 'available') {
                    sel.querySelector('option[value="booked"]').style.display = 'none';
                } else if (motor.status === 'booked') {
                    sel.querySelector('option[value="available"]').disabled = true;
                    sel.querySelector('option[value="unavailable"]').disabled = true;
                } else if (motor.status === 'unavailable') {
                    sel.querySelector('option[value="booked"]').style.display = 'none';
                }
            }

            function closeEditModal() {
                document.getElementById('editModal').style.display = 'none';
            }

            function setEditFormAction(id) {
                document.getElementById('editMotorForm').action = `/vendor/motor/${id}`;
            }

            // ========== MODAL: DELETE ==========
            function openDeleteModal(motor) {
                Swal.fire({
                    title: 'Hapus Motor',
                    text: 'Apakah Anda yakin ingin menghapus motor ini?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, hapus!',
                    cancelButtonText: 'Batal',
                    reverseButtons: true
                }).then((result) => {
                    if (result.isConfirmed) {
                        setDeleteFormAction(motor.id);
                        document.getElementById('deleteMotorForm').submit();
                    }
                });
            }

            function setDeleteFormAction(id) {
                document.getElementById('deleteMotorForm').action = `/vendor/motor/${id}`;
            }

            // ========== VALIDASI & SUBMIT: ADD MOTOR ==========
            document.getElementById('addMotorForm')?.addEventListener('submit', function(event) {
                const form = event.target;
                form.querySelectorAll('.error-message').forEach(el => el.textContent = '');

                let hasError = false;
                const data = {
                    name: form.name.value.trim(),
                    brand: form.brand.value.trim(),
                    year: parseInt(form.year.value, 10),
                    type: form.type.value,
                    color: form.color.value.trim(),
                    price: parseFloat(form.price.value),
                    platmotor: form.platmotor.value.trim(),
                    description: form.description.value.trim(),
                };
                const image = form.image.files[0];

                function setError(field, msg) {
                    const el = form.querySelector(`.error-message[data-field="${field}"]`);
                    if (el) el.textContent = msg;
                    hasError = true;
                }

                if (!data.name) setError('name', 'Nama harus diisi.');
                if (!data.brand) setError('brand', 'Merek harus diisi.');
                if (!data.year || data.year < 1900 || data.year > new Date().getFullYear())
                    setError('year', 'Tahun tidak valid.');
                if (!['automatic', 'manual', 'clutch', 'vespa'].includes(data.type))
                    setError('type', 'Tipe harus dipilih.');
                if (!data.color) setError('color', 'Warna harus diisi.');
                if (isNaN(data.price)) setError('price', 'Harga harus diisi.');
                if (!data.platmotor) setError('platmotor', 'Plat Motor tidak boleh kosong.');
                if (!data.description) setError('description', 'Deskripsi tidak boleh kosong.');

                if (image) {
                    const allowed = ['image/jpeg', 'image/png', 'image/jpg'];
                    if (!allowed.includes(image.type)) setError('image', 'File harus JPG/PNG.');
                    if (image.size > 2 * 1024 * 1024) setError('image', 'Ukuran maksimal 2MB.');
                }

                if (hasError) {
                    event.preventDefault();
                    return;
                }

                event.preventDefault();
                Swal.fire({
                    title: 'Tambah Motor',
                    text: 'Apakah Anda yakin ingin menyimpan motor baru ini?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, simpan!',
                    cancelButtonText: 'Batal',
                    reverseButtons: true
                }).then((res) => {
                    if (res.isConfirmed) form.submit();
                });
            });

            document.getElementById('editMotorForm')?.addEventListener('submit', function(e) {
                e.preventDefault();
                Swal.fire({
                    title: 'Edit Motor',
                    text: 'Apakah Anda yakin ingin menyimpan perubahan pada motor ini?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, simpan!',
                    cancelButtonText: 'Batal',
                    reverseButtons: true
                }).then((res) => {
                    if (res.isConfirmed) this.submit();
                });
            });
        </script>
    </div>
@endsection