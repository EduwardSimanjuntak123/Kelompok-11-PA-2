@extends('layouts.app')

@section('title', 'Data Kecamatan')

@section('content')
    {{-- SweetAlert for success or error --}}
    @if (session('success') !== null)
        <script>
            let msg = '{{ session('message') }}';
            let action = '{{ session('action') }}';
            let icon = 'success';
            let title = 'Berhasil!';
            let text = '';

            if (action === 'tambah') {
                text = `Data kecamatan berhasil ditambahkan. ${msg}`;
            } else if (action === 'edit') {
                text = `Data kecamatan berhasil diperbaharui. ${msg}`;
            } else if (action === 'hapus') {
                text = `Data kecamatan berhasil dihapus. ${msg}`;
            } else if (action === 'gagal_hapus') {
                icon = 'error';
                title = 'Gagal Menghapus';
                text = msg || 'Data kecamatan gagal dihapus.';
            }

            Swal.fire({
                icon: icon,
                title: title,
                text: text,
                confirmButtonText: 'OK'
            });
        </script>
    @endif


    <div class="container mx-auto py-6">
        <div class="flex justify-between items-center mb-4">
            <h1 class="text-2xl font-bold text-gray-800">Daftar Kecamatan</h1>
            <button id="btn-add"
                class="bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105">
                Tambah Kecamatan
            </button>
        </div>

        <div class="overflow-x-auto bg-white rounded-lg shadow-lg">
            <table class="min-w-full table-auto text-sm">
                <thead class="bg-blue-100 text-gray-600">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium">ID</th>
                        <th class="px-6 py-3 text-left font-medium">Nama Kecamatan</th>
                        <th class="px-6 py-3 text-center font-medium">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @forelse ($kecamatans as $kecamatan)
                        <tr>
                            <td class="px-6 py-4 text-gray-700">{{ $kecamatan['id_kecamatan'] }}</td>
                            <td class="px-6 py-4 text-gray-700">{{ trim($kecamatan['nama_kecamatan']) }}</td>
                            <td class="px-6 py-4 text-center space-x-2">
                                <!-- Tombol Edit -->
                                <button type="button"
                                    class="edit-btn bg-yellow-400 hover:bg-yellow-500 text-white py-2 px-4 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105"
                                    data-id="{{ $kecamatan['id_kecamatan'] }}"
                                    data-name="{{ trim($kecamatan['nama_kecamatan']) }}">
                                    <i class="fas fa-edit"></i>
                                </button>

                                <!-- Tombol Hapus -->
                                <form id="delete-form-{{ $kecamatan['id_kecamatan'] }}"
                                    action="{{ url('/kecamatan/' . $kecamatan['id_kecamatan']) }}" method="POST"
                                    class="inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="button" onclick="confirmDelete({{ $kecamatan['id_kecamatan'] }})"
                                        class="bg-red-500 hover:bg-red-600 text-white py-2 px-4 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="3" class="py-12">
                                <div class="flex flex-col items-center justify-center text-center p-10 bg-white rounded-lg">
                                    <div class="text-gray-400 text-5xl mb-4">
                                        <i class="fas fa-map-marked-alt"></i>
                                    </div>
                                    <h2 class="text-2xl font-semibold text-gray-700">Belum Ada Data Kecamatan</h2>
                                    <p class="text-gray-600 mt-2">Data kecamatan belum tersedia. Silakan tambahkan kecamatan
                                        baru.</p>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    {{-- Modal Tambah --}}
    <div id="modal-add" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden">
        <div
            class="relative bg-white rounded-lg w-full max-w-md p-6 transform transition-all duration-300 ease-in-out scale-95 hover:scale-100">
            {{-- Close button --}}
            <button type="button" id="btn-add-close" class="absolute top-3 right-3 text-gray-400 hover:text-gray-600">
                {{-- Heroicon X --}}
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>

            <h2 class="text-2xl font-semibold text-gray-800 mb-4">Tambah Kecamatan</h2>
            <form action="{{ route('kecamatan.store') }}" method="POST">
                @csrf
                <div class="mb-4">
                    <label for="nama_kecamatan_add" class="block text-sm font-medium text-gray-700">Nama Kecamatan</label>
                    <input type="text" name="nama_kecamatan" id="nama_kecamatan_add"
                        class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-blue-400 focus:outline-none transition duration-300 ease-in-out">
                </div>
                <div class="flex justify-end space-x-2">
                    <button type="button" id="btn-add-cancel"
                        class="px-4 py-2 rounded bg-gray-300 hover:bg-gray-400 text-gray-800 font-semibold transition duration-300 ease-in-out transform hover:scale-105">
                        Batal
                    </button>
                    <button type="submit"
                        class="px-4 py-2 rounded bg-blue-500 hover:bg-blue-600 text-white font-semibold transition duration-300 ease-in-out transform hover:scale-105">
                        Simpan
                    </button>
                </div>
            </form>
        </div>
    </div>

    {{-- Modal Edit --}}
    <div id="modal-edit" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden">
        <div
            class="relative bg-white rounded-lg w-full max-w-md p-6 transform transition-all duration-300 ease-in-out scale-95 hover:scale-100">
            {{-- Close button --}}
            <button type="button" id="btn-edit-close" class="absolute top-3 right-3 text-gray-400 hover:text-gray-600">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>

            <h2 class="text-2xl font-semibold text-gray-800 mb-4">Edit Kecamatan</h2>
            <form id="form-edit" method="POST">
                @csrf
                @method('PUT')
                <div class="mb-4">
                    <label for="nama_kecamatan_edit" class="block text-sm font-medium text-gray-700">Nama Kecamatan</label>
                    <input type="text" name="nama_kecamatan" id="nama_kecamatan_edit"
                        class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-yellow-400 focus:outline-none transition duration-300 ease-in-out"
                        required>
                </div>
                <div class="flex justify-end space-x-2">
                    <button type="button" id="btn-edit-cancel"
                        class="px-4 py-2 rounded bg-gray-300 hover:bg-gray-400 text-gray-800 font-semibold transition duration-300 ease-in-out transform hover:scale-105">
                        Batal
                    </button>
                    <button type="submit"
                        class="px-4 py-2 rounded bg-yellow-400 hover:bg-yellow-500 text-white font-semibold transition duration-300 ease-in-out transform hover:scale-105">
                        Update
                    </button>
                </div>
            </form>
        </div>
    </div>


    {{-- SweetAlert CDN --}}
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>

        // Tombol close modal Tambah
        document.getElementById('btn-add-close').addEventListener('click', () => {
            document.getElementById('modal-add').classList.add('hidden');
        });

        // Tombol close modal Edit
        document.getElementById('btn-edit-close').addEventListener('click', () => {
            document.getElementById('modal-edit').classList.add('hidden');
        });

        // Fungsi Konfirmasi Hapus (untuk tombol "Hapus")
        window.confirmDelete = function(id) {
            Swal.fire({
                title: 'Hapus Kecamatan',
                text: 'Apakah Anda yakin ingin menghapus data ini?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Ya, hapus!',
                cancelButtonText: 'Batal',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    document.getElementById(`delete-form-${id}`).submit();
                }
            });
        };

        document.addEventListener('DOMContentLoaded', function() {
            // ========== MODAL TAMBAH ==========
            const modalAdd = document.getElementById('modal-add');
            const addForm = modalAdd.querySelector('form');

            document.getElementById('btn-add').addEventListener('click', () => {
                modalAdd.classList.remove('hidden');
            });

            document.getElementById('btn-add-cancel').addEventListener('click', () => {
                modalAdd.classList.add('hidden');
            });

            // ========== VALIDASI & SUBMIT TAMBAH ==========
            addForm.addEventListener('submit', function(event) {
                event.preventDefault();

                const namaInput = addForm.querySelector('#nama_kecamatan_add');
                const nama = namaInput.value.trim();

                let errorContainer = namaInput.nextElementSibling;
                if (errorContainer && errorContainer.classList.contains('error-message')) {
                    errorContainer.remove();
                }

                let hasError = false;
                if (!nama) {
                    const errorMsg = document.createElement('p');
                    errorMsg.classList.add('error-message', 'text-red-500', 'text-sm', 'mt-1');
                    errorMsg.textContent = 'Nama kecamatan harus diisi.';
                    namaInput.after(errorMsg);
                    hasError = true;
                }

                if (hasError) return;

                Swal.fire({
                    title: 'Tambah Kecamatan',
                    text: 'Apakah Anda yakin ingin menyimpan data kecamatan ini?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, simpan!',
                    cancelButtonText: 'Batal',
                    reverseButtons: true
                }).then((result) => {
                    if (result.isConfirmed) {
                        addForm.submit();
                    }
                });
            });

            // ========== MODAL EDIT ==========
            const modalEdit = document.getElementById('modal-edit');
            const formEdit = document.getElementById('form-edit');

            document.querySelectorAll('.edit-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    const id = btn.dataset.id;
                    const name = btn.dataset.name;

                    document.getElementById('nama_kecamatan_edit').value = name;
                    formEdit.action = `{{ url('/kecamatan') }}/${id}`;
                    modalEdit.classList.remove('hidden');
                });
            });

            document.getElementById('btn-edit-cancel').addEventListener('click', () => {
                modalEdit.classList.add('hidden');
            });

            // ========== VALIDASI & SUBMIT EDIT ==========
            formEdit?.addEventListener('submit', function(e) {
                e.preventDefault();

                const namaInput = formEdit.querySelector('#nama_kecamatan_edit');
                const nama = namaInput.value.trim();

                let errorContainer = namaInput.nextElementSibling;
                if (errorContainer && errorContainer.classList.contains('error-message')) {
                    errorContainer.remove();
                }

                let hasError = false;
                if (!nama) {
                    const errorMsg = document.createElement('p');
                    errorMsg.classList.add('error-message', 'text-red-500', 'text-sm', 'mt-1');
                    errorMsg.textContent = 'Nama kecamatan harus diisi.';
                    namaInput.after(errorMsg);
                    hasError = true;
                }

                if (hasError) return;

                Swal.fire({
                    title: 'Edit Kecamatan',
                    text: 'Simpan perubahan data ini?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, simpan!',
                    cancelButtonText: 'Batal',
                    reverseButtons: true
                }).then((result) => {
                    if (result.isConfirmed) {
                        formEdit.submit();
                    }
                });
            });
        });
    </script>

@endsection
