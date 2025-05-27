@extends('layouts.app')

@section('title', 'Profil Admin')

@section('content')
    <!-- SweetAlert -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        @if (session('message'))
            Swal.fire({
                icon: '{{ session('type') === 'success' ? 'success' : 'error' }}',
                title: '{{ session('type') === 'success' ? 'Berhasil!' : 'Oops!' }}',
                text: '{{ session('message') }}',
                confirmButtonColor: '{{ session('type') === 'success' ? '#3085d6' : '#d33' }}',
                confirmButtonText: 'OK'
            });
        @endif
    </script>

    <div class="max-w-4xl mx-auto bg-white p-4 lg:p-8 rounded-xl shadow-lg">
        <!-- Header Section -->
        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 lg:mb-8 gap-4">
            <h1 class="text-2xl lg:text-3xl font-bold text-gray-800 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 lg:h-8 lg:w-8 mr-2 lg:mr-3 text-blue-600" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                Profil Admin
            </h1>
            <button onclick="openModal('editModal')"
                class="w-full sm:w-auto flex items-center justify-center px-4 py-3 lg:py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                Edit Profil
            </button>
        </div>

        <!-- Main Content -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 lg:gap-8">
            <!-- Profile Image Section -->
            <div class="flex flex-col items-center lg:items-center">
                <!-- Profile Picture -->
                <div class="relative group mb-6">
                    <div class="w-32 h-32 lg:w-40 lg:h-40 rounded-full overflow-hidden border-4 border-white shadow-lg">
                        <img id="profileImage" src="{{ $adminData['profile_image'] ?? 'https://via.placeholder.com/150' }}"
                            alt="Foto Profil" class="w-full h-full object-cover">
                    </div>
                    <button onclick="openPhotoModal('profile')"
                        class="absolute bottom-2 right-2 lg:bottom-3 lg:right-3 bg-blue-600 p-2 rounded-full shadow-lg hover:bg-blue-700 transition">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 lg:h-5 lg:w-5 text-white" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M3 7h4l2-3h6l2 3h4v13H3V7z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 11a4 4 0 100 8 4 4 0 000-8z" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Admin Information Section -->
            <div class="lg:col-span-2">
                <div class="bg-gray-50 p-4 lg:p-6 rounded-xl">
                    <h2 class="text-lg lg:text-xl font-semibold text-gray-800 mb-4 flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2 text-blue-600" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Informasi Admin
                    </h2>

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                        <!-- Personal Info -->
                        <div class="space-y-4">
                            <div>
                                <p class="text-sm font-medium text-gray-500">Nama Lengkap</p>
                                <p class="text-gray-800 font-semibold break-words">{{ isset($adminData['name']) ? $adminData['name'] : 'Tidak tersedia' }}</p>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-500">Email</p>
                                <p class="text-gray-800 font-semibold break-all">{{ $adminData['email'] }}</p>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-500">Telepon</p>
                                <p class="text-gray-800 font-semibold break-all">{{ $adminData['phone'] }}</p>
                            </div>
                        </div>

                        <!-- Additional Info -->
                        <div class="space-y-4">
                            <div>
                                <p class="text-sm font-medium text-gray-500">Alamat</p>
                                <p class="text-gray-800 break-words">{{ $adminData['address'] }}</p>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-500">Dibuat</p>
                                <p class="text-gray-800 text-sm lg:text-base">
                                    {{ \Carbon\Carbon::parse($adminData['created_at'])->format('d M Y, H:i') }}</p>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-500">Diubah</p>
                                <p class="text-gray-800 text-sm lg:text-base">
                                    {{ \Carbon\Carbon::parse($adminData['updated_at'])->format('d M Y, H:i') }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Data Modal -->
    <div id="editModal"
        class="modal hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50 z-50 p-4">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-xl max-h-screen overflow-y-auto">
            <!-- Header dengan Background Biru -->
            <div class="bg-blue-600 text-white rounded-t-xl px-4 lg:px-6 py-4">
                <div class="flex justify-between items-center">
                    <div>
                        <h2 class="text-lg lg:text-xl font-bold">Edit Data Profil</h2>
                        <p class="text-sm text-blue-100 mt-1">Perbarui informasi profil administrator</p>
                    </div>
                    <button onclick="closeModal('editModal')" class="text-white hover:text-blue-200 p-1">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Body Form -->
            <div class="p-4 lg:p-6">
                <form action="{{ route('admin.update') }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    @method('PUT')

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-600 mb-2">Nama Lengkap</label>
                            <input type="text" name="name" value="{{ isset($adminData['name']) ? $adminData['name'] : 'Tidak tersedia' }}"
                                class="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300 text-base">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-600 mb-2">Email</label>
                            <input type="email" name="email" value="{{ $adminData['email'] }}"
                                class="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300 text-base">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-600 mb-2">Telepon</label>
                            <input type="text" name="phone" value="{{ $adminData['phone'] }}"
                                class="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300 text-base">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-600 mb-2">Alamat</label>
                            <input type="text" name="address" value="{{ $adminData['address'] }}"
                                class="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300 text-base">
                        </div>
                    </div>

                    <!-- Footer -->
                    <div class="border-t border-gray-200 pt-4 lg:pt-6 mt-4 lg:mt-6">
                        <div class="flex flex-col sm:flex-row justify-end gap-2 sm:space-x-3 sm:gap-0">
                            <button type="button" onclick="closeModal('editModal')"
                                class="w-full sm:w-auto px-4 py-3 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded-lg transition duration-300 order-2 sm:order-1">
                                Batal
                            </button>
                            <button type="submit"
                                class="w-full sm:w-auto px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg shadow-md transition duration-300 order-1 sm:order-2">
                                Simpan Perubahan
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>  

    <!-- Edit Photo Modal -->
    <div id="editPhotoModal"
        class="modal hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50 z-50 p-4">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-md max-h-screen overflow-y-auto">
            <div class="p-4 lg:p-6">
                <div class="flex justify-between items-center mb-4">
                    <h2 id="photoModalTitle" class="text-lg lg:text-xl font-bold text-gray-800">Edit Foto</h2>
                    <button onclick="closeModal('editPhotoModal')" class="text-gray-500 hover:text-gray-700 p-1">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <form action="{{ route('admin.update') }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    @method('PUT')

                    <div class="mb-4">
                        <div class="flex justify-center mb-4">
                            <div class="border-2 border-dashed border-gray-300 rounded-lg p-4 w-full text-center">
                                <div id="imagePreviewContainer" class="mb-3 hidden">
                                    <img id="imagePreview" src="#" alt="Preview" class="max-h-32 lg:max-h-40 mx-auto rounded">
                                </div>
                                <label for="photoInput" class="cursor-pointer">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 lg:h-12 lg:w-12 mx-auto text-gray-400"
                                        fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                                    </svg>
                                    <p class="text-sm text-gray-600 mt-2">Klik untuk mengunggah gambar</p>
                                    <p class="text-xs text-gray-500">Format: JPG, PNG (Maks. 2MB)</p>
                                </label>
                                <input type="file" name="profile_image" id="photoInput" class="hidden"
                                    accept="image/*">
                            </div>
                        </div>
                    </div>

                    <div class="flex flex-col sm:flex-row justify-end gap-2 sm:space-x-3 sm:gap-0 pt-4 border-t border-gray-200">
                        <button type="button" onclick="closeModal('editPhotoModal')"
                            class="w-full sm:w-auto px-4 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition order-2 sm:order-1">
                            Batal
                        </button>
                        <button type="submit"
                            class="w-full sm:w-auto px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition order-1 sm:order-2">
                            Simpan Foto
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Fungsi untuk membuka modal berdasarkan id
        function openModal(modalId) {
            document.getElementById(modalId).classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        // Fungsi untuk menutup modal berdasarkan id
        function closeModal(modalId) {
            document.getElementById(modalId).classList.add('hidden');
            document.body.style.overflow = '';
        }

        // Fungsi untuk membuka modal edit foto
        // type: 'profile' atau 'ktp'
        function openPhotoModal(type) {
            let title = '';
            let inputName = '';
            if (type === 'profile') {
                title = 'Edit Foto Profil';
                inputName = 'profile_image';
            }
            document.getElementById('photoModalTitle').innerText = title;
            document.getElementById('photoInput').name = inputName;
            // Jika ada preview, reset preview
            document.getElementById('imagePreviewContainer').classList.add('hidden');
            document.getElementById('imagePreview').src = '#';
            openModal('editPhotoModal');
        }

        // Event listener untuk preview gambar
        document.getElementById('photoInput').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(event) {
                    const preview = document.getElementById('imagePreview');
                    preview.src = event.target.result;
                    document.getElementById('imagePreviewContainer').classList.remove('hidden');
                }
                reader.readAsDataURL(file);
            }
        });

        // Tutup modal ketika klik di luar konten modal
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                closeModal(event.target.id);
            }
        }
    </script>
@endsection