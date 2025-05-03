@extends('layouts.app')

@section('title', 'Motor Vendor Rental')

@section('content')
    <!-- Sertakan SweetAlert2 dari CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

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
                <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="🔍 Cari motor..."
                    class="w-full sm:w-64 border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
                <button id="openAddModalBtn"
                    class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition">
                    Tambah Motor
                </button>
            </div>
        </div>

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
                    @foreach ($motors as $motor)
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
                            <td class="px-4 py-2 whitespace-nowrap">
                                <div class="flex items-center space-x-1">
                                    @for ($i = 0; $i < $motor['rating']; $i++)
                                        <svg class="h-5 w-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.96a1 1 0 00.95.69h4.162
                                             c.969 0 1.371 1.24.588 1.81l-3.37 2.448a1 1 0 00-.364 1.118l1.286
                                             3.96c.3.921-.755 1.688-1.54 1.118l-3.37-2.448a1 1 0 00-1.176
                                             0l-3.37 2.448c-.784.57-1.84-.197-1.54-1.118l1.286-3.96a1 1 0
                                             00-.364-1.118L2.063 9.387c-.783-.57-.38-1.81.588-1.81h4.162a1 1
                                             0 00.95-.69l1.286-3.96z" />
                                        </svg>
                                    @endfor
                                    @for ($i = $motor['rating']; $i < 5; $i++)
                                        <svg class="h-5 w-5 text-gray-300" fill="currentColor" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.96a1 1 0 00.95.69h4.162
                                             c.969 0 1.371 1.24.588 1.81l-3.37 2.448a1 1 0 00-.364 1.118l1.286
                                             3.96c.3.921-.755 1.688-1.54 1.118l-3.37-2.448a1 1 0 00-1.176
                                             0l-3.37 2.448c-.784.57-1.84-.197-1.54-1.118l1.286-3.96a1 1 0
                                             00-.364-1.118L2.063 9.387c-.783-.57-.38-1.81.588-1.81h4.162a1 1
                                             0 00.95-.69l1.286-3.96z" />
                                        </svg>
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
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0
                                               01-1.995-1.858L5 7m5-4h4m-4 0a1 1 0 00-1 1v1h6V4a1
                                               1 0 00-1-1m-4 0h4" />
                                    </svg>
                                </button>
                            </td>
                        </tr>
                    @endforeach
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

                // Reset form input
                form.reset();

                // Hapus semua pesan error
                form.querySelectorAll('.error-message').forEach(el => el.textContent = '');

                // Tampilkan modal
                document.getElementById('addModal').style.display = 'flex';
            });

            function closeAddModal() {
                document.getElementById('addModal').style.display = 'none';
            }

            // ========== MODAL: EDIT ==========
            function openEditModal(motor) {
                document.getElementById('editModal').style.display = 'flex';
                document.getElementById('editMotorName').value = motor.name;
                document.getElementById('editMotorBrand').value = motor.brand;
                document.getElementById('editMotorYear').value = motor.year;
                document.getElementById('editMotorColor').value = motor.color;
                document.getElementById('editMotorPrice').value = motor.price;
                document.getElementById('editMotorPlatMotor').value = motor.platmotor;
                document.getElementById('editMotorStatus').value = motor.status;
                document.getElementById('editMotortype').value = motor.type;
                document.getElementById('editMotorDescription').value = motor.description;
                setEditFormAction(motor.id);
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
                const errorMessages = form.querySelectorAll('.error-message');
                errorMessages.forEach(el => el.textContent = '');

                const name = form.name.value.trim();
                const brand = form.brand.value.trim();
                const year = parseInt(form.year.value);
                const type = form.type.value;
                const color = form.color.value.trim();
                const price = parseFloat(form.price.value);
                const platmotor = form.platmotor.value.trim();
                const description = form.description.value.trim();
                const image = form.image.files[0];

                let hasError = false;

                function setError(field, message) {
                    const el = form.querySelector(`.error-message[data-field="${field}"]`);
                    if (el) el.textContent = message;
                    hasError = true;
                }

                if (!name) setError('name', 'Nama harus diisi.');
                if (!brand) setError('brand', 'Merek harus diisi.');
                if (!year || year < 1900 || year > new Date().getFullYear()) setError('year', 'Tahun tidak valid.');
                if (!['matic', 'manual', 'kopling', 'vespa'].includes(type)) setError('type', 'Tipe harus dipilih.');
                if (!color) setError('color', 'Warna harus diisi.');
                if (isNaN(price)) setError('price', 'Harga harus diisi.');
                if (!platmotor) setError('platmotor', 'Plat Motor tidak boleh kosong.');
                if (!description) setError('description', 'Deskripsi tidak boleh kosong.');

                if (image) {
                    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
                    if (!allowedTypes.includes(image.type)) setError('image', 'File harus JPG/PNG.');
                    if (image.size > 2 * 1024 * 1024) setError('image', 'Ukuran maksimal 2MB.');
                }

                if (hasError) {
                    event.preventDefault();
                    return;
                }

                event.preventDefault(); // mencegah submit default
                Swal.fire({
                    title: 'Tambah Motor',
                    text: 'Apakah Anda yakin ingin menyimpan motor baru ini?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, simpan!',
                    cancelButtonText: 'Batal',
                    reverseButtons: true
                }).then((result) => {
                    if (result.isConfirmed) {
                        form.submit();
                    }
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
                }).then((result) => {
                    if (result.isConfirmed) {
                        this.submit();
                    }
                });
            });
        </script>
    @endsection
