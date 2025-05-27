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

    <div class="container mx-auto py-4 lg:py-6 px-4 lg:px-0">
        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-4 lg:mb-6 gap-3">
            <h1 class="text-xl lg:text-2xl font-bold text-gray-800">Daftar Kecamatan</h1>
            <button id="btn-add"
                class="w-full sm:w-auto bg-blue-500 hover:bg-blue-600 text-white font-semibold py-3 px-4 lg:py-2 lg:px-4 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105">
                <i class="fas fa-plus mr-2"></i>Tambah Kecamatan
            </button>
        </div>

        <!-- Mobile Card View -->
        <div class="block sm:hidden space-y-3">
            @forelse ($kecamatans as $kecamatan)
                <div class="bg-white rounded-lg shadow-md p-4 border">
                    <div class="flex justify-between items-start mb-3">
                        <div class="flex-1">
                            <div class="text-sm text-gray-500 mb-1">ID: {{ $kecamatan['id_kecamatan'] }}</div>
                            <h3 class="font-semibold text-gray-800 text-lg">{{ trim($kecamatan['nama_kecamatan']) }}</h3>
                        </div>
                    </div>
                    <div class="flex gap-2 mt-3">
                        <button type="button"
                            class="edit-btn flex-1 bg-yellow-400 hover:bg-yellow-500 text-white py-2 px-3 rounded-lg shadow-md transition duration-300 ease-in-out"
                            data-id="{{ $kecamatan['id_kecamatan'] }}"
                            data-name="{{ trim($kecamatan['nama_kecamatan']) }}">
                            <i class="fas fa-edit mr-1"></i>Edit
                        </button>
                        <form id="delete-form-{{ $kecamatan['id_kecamatan'] }}"
                            action="{{ url('/kecamatan/' . $kecamatan['id_kecamatan']) }}" method="POST"
                            class="flex-1">
                            @csrf
                            @method('DELETE')
                            <button type="button" onclick="confirmDelete({{ $kecamatan['id_kecamatan'] }})"
                                class="w-full bg-red-500 hover:bg-red-600 text-white py-2 px-3 rounded-lg shadow-md transition duration-300 ease-in-out">
                                <i class="fas fa-trash-alt mr-1"></i>Hapus
                            </button>
                        </form>
                    </div>
                </div>
            @empty
                <div class="flex flex-col items-center justify-center text-center p-8 bg-white rounded-lg shadow-md">
                    <div class="text-gray-400 text-4xl mb-4">
                        <i class="fas fa-map-marked-alt"></i>
                    </div>
                    <h2 class="text-xl font-semibold text-gray-700">Belum Ada Data Kecamatan</h2>
                    <p class="text-gray-600 mt-2 text-sm">Data kecamatan belum tersedia. Silakan tambahkan kecamatan baru.</p>
                    <button id="btn-add-mobile"
                        class="mt-4 w-full bg-blue-500 hover:bg-blue-600 text-white font-medium py-3 px-4 rounded-lg shadow-md transition duration-300">
                        <i class="fas fa-plus mr-2"></i>Tambah Kecamatan
                    </button>
                </div>
            @endforelse
        </div>

        <!-- Desktop Table View -->
        <div class="hidden sm:block overflow-x-auto bg-white rounded-lg shadow-lg">
            <table class="min-w-full table-auto text-sm">
                <thead class="bg-blue-100 text-gray-600">
                    <tr>
                        <th class="px-4 lg:px-6 py-3 text-left font-medium">ID</th>
                        <th class="px-4 lg:px-6 py-3 text-left font-medium">Nama Kecamatan</th>
                        <th class="px-4 lg:px-6 py-3 text-center font-medium">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @forelse ($kecamatans as $kecamatan)
                        <tr>
                            <td class="px-4 lg:px-6 py-4 text-gray-700">{{ $kecamatan['id_kecamatan'] }}</td>
                            <td class="px-4 lg:px-6 py-4 text-gray-700">{{ trim($kecamatan['nama_kecamatan']) }}</td>
                            <td class="px-4 lg:px-6 py-4 text-center space-x-2">
                                <!-- Tombol Edit -->
                                <button type="button"
                                    class="edit-btn bg-yellow-400 hover:bg-yellow-500 text-white py-2 px-3 lg:px-4 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105"
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
                                        class="bg-red-500 hover:bg-red-600 text-white py-2 px-3 lg:px-4 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105">
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
    <div id="modal-add" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden z-50 p-4">
        <div
            class="relative bg-white rounded-lg w-full max-w-md transform transition-all duration-300 ease-in-out scale-95 hover:scale-100 max-h-screen overflow-y-auto">
            <!-- Header dengan Background Biru -->
            <div class="bg-blue-600 text-white rounded-t-lg px-4 lg:px-6 py-4">
                <div class="flex justify-between items-center">
                    <div>
                        <h2 class="text-xl lg:text-2xl font-bold">Tambah Kecamatan</h2>
                        <p class="text-sm text-blue-100 mt-1">Tambahkan data kecamatan baru</p>
                    </div>
                    <button type="button" id="btn-add-close" class="text-white hover:text-blue-200 p-1">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Body Form -->
            <form action="{{ route('kecamatan.store') }}" method="POST" class="p-4 lg:p-6">
                @csrf
                <div class="mb-4">
                    <label for="nama_kecamatan_add" class="block text-sm font-medium text-gray-700 mb-2">Nama
                        Kecamatan</label>
                    <input type="text" name="nama_kecamatan" id="nama_kecamatan_add"
                        class="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-400 focus:border-blue-400 transition duration-300 text-base">
                </div>

                <!-- Footer -->
                <div class="border-t border-gray-200 pt-4 lg:pt-6 mt-4 lg:mt-6">
                    <div class="flex flex-col sm:flex-row justify-end gap-2 sm:space-x-2 sm:gap-0">
                        <button type="button" id="btn-add-cancel"
                            class="w-full sm:w-auto px-4 py-3 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded-md font-semibold transition duration-300 order-2 sm:order-1">
                            Batal
                        </button>
                        <button type="submit"
                            class="w-full sm:w-auto px-4 py-3 bg-blue-500 hover:bg-blue-600 text-white rounded-md font-semibold transition duration-300 order-1 sm:order-2">
                            Simpan
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    {{-- Modal Edit --}}
    <div id="modal-edit" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden z-50 p-4">
        <div
            class="relative bg-white rounded-lg w-full max-w-md transform transition-all duration-300 ease-in-out scale-95 hover:scale-100 max-h-screen overflow-y-auto">
            <!-- Header dengan Background Biru -->
            <div class="bg-blue-600 text-white rounded-t-lg px-4 lg:px-6 py-4">
                <div class="flex justify-between items-center">
                    <div>
                        <h2 class="text-xl lg:text-2xl font-bold">Edit Kecamatan</h2>
                        <p class="text-sm text-blue-100 mt-1">Perbarui data kecamatan</p>
                    </div>
                    <button type="button" id="btn-edit-close" class="text-white hover:text-blue-200 p-1">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Body Form -->
            <form id="form-edit" method="POST" class="p-4 lg:p-6">
                @csrf
                @method('PUT')
                <div class="mb-4">
                    <label for="nama_kecamatan_edit" class="block text-sm font-medium text-gray-700 mb-2">Nama
                        Kecamatan</label>
                    <input type="text" name="nama_kecamatan" id="nama_kecamatan_edit"
                        class="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400 transition duration-300 text-base"
                        required>
                </div>

                <!-- Footer -->
                <div class="border-t border-gray-200 pt-4 lg:pt-6 mt-4 lg:mt-6">
                    <div class="flex flex-col sm:flex-row justify-end gap-2 sm:space-x-2 sm:gap-0">
                        <button type="button" id="btn-edit-cancel"
                            class="w-full sm:w-auto px-4 py-3 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded-md font-semibold transition duration-300 order-2 sm:order-1">
                            Batal
                        </button>
                        <button type="submit"
                            class="w-full sm:w-auto px-4 py-3 bg-yellow-400 hover:bg-yellow-500 text-white rounded-md font-semibold shadow-md transition duration-300 order-1 sm:order-2">
                            Update
                        </button>
                    </div>
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
            document.body.style.overflow = 'auto';
        });

        // Tombol close modal Edit
        document.getElementById('btn-edit-close').addEventListener('click', () => {
            document.getElementById('modal-edit').classList.add('hidden');
            document.body.style.overflow = 'auto';
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

            // Event listener untuk tombol tambah utama dan mobile
            document.getElementById('btn-add').addEventListener('click', () => {
                modalAdd.classList.remove('hidden');
                document.body.style.overflow = 'hidden';
            });

            // Event listener untuk tombol tambah di mobile empty state
            const btnAddMobile = document.getElementById('btn-add-mobile');
            if (btnAddMobile) {
                btnAddMobile.addEventListener('click', () => {
                    modalAdd.classList.remove('hidden');
                    document.body.style.overflow = 'hidden';
                });
            }

            document.getElementById('btn-add-cancel').addEventListener('click', () => {
                modalAdd.classList.add('hidden');
                document.body.style.overflow = 'auto';
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
                    document.body.style.overflow = 'hidden';
                });
            });

            document.getElementById('btn-edit-cancel').addEventListener('click', () => {
                modalEdit.classList.add('hidden');
                document.body.style.overflow = 'auto';
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

            // Close modal when clicking outside
            modalAdd.addEventListener('click', function(e) {
                if (e.target === modalAdd) {
                    modalAdd.classList.add('hidden');
                    document.body.style.overflow = 'auto';
                }
            });

            modalEdit.addEventListener('click', function(e) {
                if (e.target === modalEdit) {
                    modalEdit.classList.add('hidden');
                    document.body.style.overflow = 'auto';
                }
            });
        });
    </script>

@endsection