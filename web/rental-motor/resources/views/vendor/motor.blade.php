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

    <div class="p-6 bg-gray-100 min-h-screen">
        {{-- Toolbar --}}
        <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-6 space-y-4 md:space-y-0">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Daftar Motor Vendor</h1>
                <p class="text-sm text-gray-500">Kelola semua motor yang tersedia</p>
            </div>
            <div class="flex flex-col sm:flex-row items-start sm:items-center gap-2 w-full sm:w-auto">
                <div class="relative w-full sm:w-64">
                    <!-- Icon kaca pembesar -->
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </div>

                    <!-- Input dengan padding-left untuk ikon -->
                    <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Cari motor..."
                        class="w-full border rounded-md px-3 py-2 pl-10 focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>

                <button id="openAddModalBtn"
                    class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition">
                    Tambah Motor
                </button>
            </div>
        </div>

        <form method="GET" class="flex items-center gap-4 mb-4">
            <div class="flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-700" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L15 13.414V19a1 1 0 01-1.447.894l-4-2A1 1 0 019 17v-3.586L3.293 6.707A1 1 0 013 6V4z" />
                </svg>
                <span class="text-sm text-gray-700 font-medium hidden sm:inline">Status</span>
            </div>

            <div class="relative w-60">
                <select id="status" name="status" onchange="this.form.submit()"
                    class="block w-full pl-3 pr-8 py-2 bg-white border border-gray-300 rounded-lg text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm appearance-none">
                    <option value="all" {{ request('status', 'all') === 'all' ? 'selected' : '' }}>🔄 Semua</option>
                    <option value="available" {{ request('status') === 'available' ? 'selected' : '' }}>✅ Motor Tersedia
                    </option>
                    <option value="booked" {{ request('status') === 'booked' ? 'selected' : '' }}>📦 Motor Sedang Dibooking
                    </option>
                    <option value="unavailable" {{ request('status') === 'unavailable' ? 'selected' : '' }}>🛑 Motor Rusak
                    </option>
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


        {{-- Tabel --}}
        <div class="overflow-x-auto w-full">
            <table id="motorTable" class="w-full table-auto bg-white divide-y divide-gray-200 shadow rounded-lg">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Gambar</th>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Informasi Motor</th>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Tipe</th>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Rating</th>
                        <th class="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase">Harga</th>
                        <th class="px-4 py-2 text-center text-xs font-medium text-gray-500 uppercase">Aksi</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-100">
                    @forelse ($motors as $motor)
                        {{-- @dd($motors) --}}
                        <tr class="hover:bg-gray-50">
                            {{-- Gambar --}}
                            <td class="px-4 py-2 whitespace-nowrap">
                                @if (!empty($motor['image_url']))
                                    <img src="{{ $motor['image_url'] }}" alt="Motor"
                                        class="h-12 w-16 sm:h-16 sm:w-24 object-cover rounded-md">
                                @else
                                    <span class="text-gray-400 italic">–</span>
                                @endif
                            </td>

                            {{-- Informasi Motor --}}
                            <td class="px-4 py-2 text-sm text-gray-700">
                                <div class="flex flex-col space-y-1">
                                    <span><strong>Nama Motor:</strong> {{ $motor['name'] }}</span>
                                    <span><strong>Merek Motor:</strong> {{ $motor['brand'] }}</span>
                                    <span><strong>Tahun:</strong> {{ $motor['year'] }}</span>
                                    <span><strong>Warna:</strong> {{ $motor['color'] }}</span>
                                    <span><strong>Plat Motor:</strong> {{ $motor['platmotor'] }}</span>
                                    <span><strong>Status Motor:</strong>
                                        @switch($motor['status'])
                                            @case('unavailable')
                                                <span
                                                    class="inline-block px-2 py-1 text-xs font-semibold bg-red-100 text-red-700 rounded-full">Motor
                                                    Rusak</span>
                                            @break

                                            @case('available')
                                                <span
                                                    class="inline-block px-2 py-1 text-xs font-semibold bg-green-100 text-green-700 rounded-full">Motor
                                                    Tersedia</span>
                                            @break

                                            @case('booked')
                                                <span
                                                    class="inline-block px-2 py-1 text-xs font-semibold bg-yellow-100 text-yellow-700 rounded-full">Motor
                                                    Sedang Dibooking</span>
                                            @break

                                            @default
                                                <span
                                                    class="inline-block px-2 py-1 text-xs font-semibold bg-gray-100 text-gray-700 rounded-full">Status
                                                    Tidak Diketahui</span>
                                        @endswitch
                                    </span>
                                    <span><strong>Deskripsi:</strong> {{ $motor['description'] }}</span>
                                </div>
                            </td>

                            {{-- Tipe --}}
                            <td class="px-4 py-2 whitespace-nowrap">
                                <span
                                    class="inline-block bg-blue-100 text-blue-800 text-xs font-semibold px-2 py-1 rounded">
                                    {{ $motor['type'] }}
                                </span>
                            </td>

                            {{-- Rating --}}
                            <td class="px-6 py-4 text-center">
                                <div class="flex justify-center items-center space-x-1">
                                    @php $stars = intval($motor['rating'] ?? 0); @endphp

                                    {{-- Full stars --}}
                                    @for ($i = 0; $i < $stars; $i++)
                                        <i class="bi bi-star-fill text-yellow-400 fs-5"></i>
                                    @endfor

                                    {{-- Empty stars --}}
                                    @for ($i = $stars; $i < 5; $i++)
                                        <i class="bi bi-star text-gray-300 fs-5"></i>
                                    @endfor
                                </div>
                            </td>



                            {{-- Harga --}}
                            <td class="px-4 py-2 whitespace-nowrap text-right text-sm font-semibold text-green-600">
                                Rp {{ number_format($motor['price'], 0, ',', '.') }}
                            </td>

                            {{-- Aksi --}}
                            <td class="px-4 py-2 whitespace-nowrap text-center text-sm font-medium space-x-2">
                                <button onclick="openEditModal({{ json_encode($motor) }})"
                                    class="inline-flex items-center px-3 py-2 border border-blue-500 rounded hover:bg-blue-50">
                                    <svg class="h-6 w-6 text-blue-500" fill="none" viewBox="0 0 24 24"
                                        stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M15.232 5.232l3.536 3.536M9 11l3 3L21 5l-3-3L9 11z" />
                                    </svg>
                                </button>
                                <button onclick="openDeleteModal({{ json_encode($motor) }})"
                                    class="inline-flex items-center px-3 py-2 border border-red-500 rounded hover:bg-red-50">
                                    <svg class="h-6 w-6 text-red-500" fill="none" viewBox="0 0 24 24"
                                        stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5-4h4m-4 0a1 1 0 00-1 1v1h6V4a1
                                                                                                                                                                                                                            1 0 00-1-1m-4 0h4" />
                                    </svg>
                                </button>
                            </td>
                        </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="py-12">
                                    <div
                                        class="flex flex-col items-center justify-center text-center p-10 bg-white rounded-lg shadow-md">
                                        <div class="text-gray-400 text-5xl mb-4">
                                            <i class="fas fa-search-minus"></i>
                                        </div>
                                        <h2 class="text-2xl font-semibold text-gray-700">Tidak Ada Motor Ditemukan</h2>
                                        <p class="text-gray-600 mt-2">Sepertinya tidak ada motor yang sesuai dengan Status yang
                                            dipilih.</p>
                                    </div>
                                </td>
                            </tr>
                        @endempty
                </tbody>
            </table>
        </div>


        <!-- Modal Tambah/Edit/Hapus Motor -->
        @include('layouts.modal_motor_vendor')

        <script>
            // ========== FILTER TABLE ==========
            function filterTable() {
                const q = document.getElementById('searchInput').value.toLowerCase();
                document.querySelectorAll('#motorTable tbody tr').forEach(row => {
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

                // Reset semua opsi status → pastikan tidak ada yang ter-disabled/ter-hide
                const sel = document.getElementById('editMotorStatus');
                sel.querySelectorAll('option').forEach(opt => {
                    opt.disabled = false;
                    opt.style.display = '';
                });

                // Hanya sembunyikan/disable opsi yang **tidak valid** untuk transisi
                // tetapi biarkan opsi yang dipilih tetap ada dan aktif
                if (motor.status === 'available') {
                    // dari available hanya boleh remain available atau ke unavailable
                    sel.querySelector('option[value="booked"]').style.display = 'none';
                } else if (motor.status === 'booked') {
                    // dari booked tidak boleh ke available atau unavailable
                    sel.querySelector('option[value="available"]').disabled = true;
                    sel.querySelector('option[value="unavailable"]').disabled = true;
                } else if (motor.status === 'unavailable') {
                    // dari unavailable hanya boleh remain unavailable atau ke available
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
                if (!['matic', 'manual', 'kopling', 'vespa'].includes(data.type))
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

            // ========== VALIDASI & SUBMIT: EDIT MOTOR ==========
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
    @endsection
