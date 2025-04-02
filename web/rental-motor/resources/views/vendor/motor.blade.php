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

    <!-- Tombol Tambah Motor -->
    <button id="openAddModalBtn" class="bg-green-500 text-white px-4 py-2 rounded-md hover:bg-green-600 transition mb-4">
        Tambah Motor
    </button>

    <!-- Tabel Motor -->
    <div class="overflow-x-auto">
        <table class="w-full border-collapse rounded-lg overflow-hidden shadow-md">
            <thead>
                <tr class="bg-gray-200 text-gray-700 uppercase text-sm leading-normal">
                    <th class="py-3 px-4 text-left">Gambar</th>
                    <th class="py-3 px-4 text-left">Nama</th>
                    <th class="py-3 px-4 text-left">Brand</th>
                    <th class="py-3 px-4 text-left">Model</th>
                    <th class="py-3 px-4 text-left">Tahun</th>
                    <th class="py-3 px-4 text-left">Warna</th>
                    <th class="py-3 px-4 text-left">Harga</th>
                    <th class="py-3 px-4 text-left">Aksi</th>
                </tr>
            </thead>
            {{-- @dd($motors) --}}
            <tbody>
                @foreach ($motors as $motor)
                    <tr class="border-b">
                        <td class="px-4 py-2">
                            @if (!empty($motor['image_url']))
                                <img src="{{ $motor['image_url'] }}" alt="Gambar Motor"
                                    class="w-24 h-16 object-cover rounded-md">
                            @else
                                <span class="text-gray-400 italic">Tidak ada gambar</span>
                            @endif
                        </td>
                        <td class="px-4 py-2">{{ $motor['name'] ?? '-' }}</td>
                        <td class="px-4 py-2">{{ $motor['brand'] }}</td>
                        <td class="px-4 py-2">{{ $motor['model'] }}</td>
                        <td class="px-4 py-2">{{ $motor['year'] ?? '-' }}</td>
                        <td class="px-4 py-2">{{ $motor['color'] }}</td>
                        <td class="px-4 py-2 font-bold text-green-600">
                            Rp {{ number_format($motor['price'], 0, ',', '.') }}
                        </td>
                        <td class="px-4 py-2 flex gap-2">
                            <button onclick="openEditModal({{ json_encode($motor) }})"
                                class="bg-blue-500 text-white px-3 py-1 rounded-md hover:bg-blue-600 transition">
                                Edit
                            </button>
                            <button onclick="openDeleteModal({{ json_encode($motor) }})"
                                class="bg-red-500 text-white px-3 py-1 rounded-md hover:bg-red-600 transition">
                                Hapus
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
        document.getElementById('openAddModalBtn').addEventListener('click', function() {
            document.getElementById('addModal').style.display = 'flex';
        });

        function closeAddModal() {
            document.getElementById('addModal').style.display = 'none';
        }

        // Modal Edit Motor
        function openEditModal(motor) {
            document.getElementById('editModal').style.display = 'flex';
            document.getElementById('editMotorName').value = motor.name;
            document.getElementById('editMotorBrand').value = motor.brand;
            document.getElementById('editMotorModel').value = motor.model;
            document.getElementById('editMotorYear').value = motor.year;
            document.getElementById('editMotorColor').value = motor.color;
            document.getElementById('editMotorPrice').value = motor.price;
            document.getElementById('editMotorStatus').value = motor.status;
            setEditFormAction(motor.id);
        }

        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
        }

        // Modal Hapus Motor
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

        function closeDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
        }

        // Set action URL untuk form edit dan delete
        function setEditFormAction(id) {
            document.getElementById('editMotorForm').action = `/vendor/motor/${id}`;
        }

        function setDeleteFormAction(id) {
            document.getElementById('deleteMotorForm').action = `/vendor/motor/${id}`;
        }

        // Event listener untuk form submit pada modal tambah
        if (document.getElementById('addMotorForm')) {
            document.getElementById('addMotorForm').addEventListener('submit', function(e) {
                e.preventDefault();
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
                        this.submit();
                    }
                });
            });
        }

        // Event listener untuk form submit pada modal edit
        if (document.getElementById('editMotorForm')) {
            document.getElementById('editMotorForm').addEventListener('submit', function(e) {
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
        }
    </script>
@endsection
