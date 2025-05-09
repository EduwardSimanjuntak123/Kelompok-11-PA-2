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


    <div class="max-w-4xl mx-auto bg-white p-8 rounded-xl shadow-lg">
        <!-- Header Section -->
        <div class="flex justify-between items-center mb-8">
            <h1 class="text-3xl font-bold text-gray-800 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mr-3 text-blue-600" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                Profil Admin
            </h1>
            <button onclick="openModal('editModal')"
                class="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                
            </button>
        </div>

        <!-- Main Content -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Profile Image Section -->
            <div class="flex flex-col items-center">
                <!-- Profile Picture -->
                <div class="relative group mb-6">
                    <div class="w-40 h-40 rounded-full overflow-hidden border-4 border-white shadow-lg">
                        <img id="profileImage" src="{{ $adminData['profile_image'] ?? 'https://via.placeholder.com/150' }}"
                            alt="Foto Profil" class="w-full h-full object-cover">
                    </div>
                    <button onclick="openPhotoModal('profile')"
                        class="absolute bottom-3 right-3 bg-blue-600 p-2 rounded-full shadow-lg hover:bg-blue-700 transition">

                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-white" fill="none"
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
            <div class="md:col-span-2">
                <div class="bg-gray-50 p-6 rounded-xl">
                    <h2 class="text-xl font-semibold text-gray-800 mb-4 flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2 text-blue-600" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Informasi Admin
                    </h2>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <!-- Personal Info -->
                        <div class="space-y-4">
                            <div>
                                <p class="text-sm font-medium text-gray-500">Nama Lengkap</p>
                                <p class="text-gray-800 font-semibold">{{ $adminData['name'] }}</p>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-500">Email</p>
                                <p class="text-gray-800 font-semibold">{{ $adminData['email'] }}</p>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-500">Telepon</p>
                                <p class="text-gray-800 font-semibold">{{ $adminData['phone'] }}</p>
                            </div>
                        </div>

                        <!-- Additional Info -->
                        <div class="space-y-4">
                            <div>
                                <p class="text-sm font-medium text-gray-500">Alamat</p>
                                <p class="text-gray-800">{{ $adminData['address'] }}</p>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-500">Dibuat</p>
                                <p class="text-gray-800">
                                    {{ \Carbon\Carbon::parse($adminData['created_at'])->format('d M Y, H:i') }}</p>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-500">Diubah</p>
                                <p class="text-gray-800">
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
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-xl">
            <div class="p-6">
                <div class="flex justify-between items-center mb-4">
                    <h2 class="text-xl font-bold text-gray-800">Edit Data Profil</h2>
                    <button onclick="closeModal('editModal')" class="text-gray-500 hover:text-gray-700">
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

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-600">Nama Lengkap</label>
                            <input type="text" name="name" value="{{ $adminData['name'] }}"
                                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring focus:ring-blue-200">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-600">Email</label>
                            <input type="email" name="email" value="{{ $adminData['email'] }}"
                                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring focus:ring-blue-200">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-600">Telepon</label>
                            <input type="text" name="phone" value="{{ $adminData['phone'] }}"
                                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring focus:ring-blue-200">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-600">Alamat</label>
                            <input type="text" name="address" value="{{ $adminData['address'] }}"
                                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring focus:ring-blue-200">
                        </div>
                    </div>

                    <div class="flex justify-end mt-6 space-x-3 pt-4 border-t border-gray-200">
                        <button type="button" onclick="closeModal('editModal')"
                            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition">
                            Batal
                        </button>
                        <button type="submit"
                            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition">
                            Simpan Perubahan
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>


    <!-- Edit Photo Modal -->
    <div id="editPhotoModal"
        class="modal hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50 z-50 p-4">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-md">
            <div class="p-6">
                <div class="flex justify-between items-center mb-4">
                    <h2 id="photoModalTitle" class="text-xl font-bold text-gray-800">Edit Foto</h2>
                    <button onclick="closeModal('editPhotoModal')" class="text-gray-500 hover:text-gray-700">
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
                                    <img id="imagePreview" src="#" alt="Preview" class="max-h-40 mx-auto">
                                </div>
                                <label for="photoInput" class="cursor-pointer">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400"
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

                    <div class="flex justify-end space-x-3 pt-4 border-t border-gray-200">
                        <button type="button" onclick="closeModal('editPhotoModal')"
                            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition">
                            Batal
                        </button>
                        <button type="submit"
                            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition">
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
