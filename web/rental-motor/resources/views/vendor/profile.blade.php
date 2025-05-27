@extends('layouts.app')

@section('title', 'Profil Vendor')

@section('content')
    @php
        $vendor = $user['vendor'] ?? [];
    @endphp
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        @if (session('message_profile'))
            Swal.fire({
                icon: '{{ session('type_profile') ?? 'success' }}',
                title: 'Berhasil!',
                text: '{{ session('message_profile') }}',
                confirmButtonColor: '#3085d6',
            });
        @endif

        @if (session('message_photo'))
            Swal.fire({
                icon: '{{ session('type_photo') ?? 'success' }}',
                title: 'Foto Diperbarui!',
                text: '{{ session('message_photo') }}',
                confirmButtonColor: '#3085d6',
            });
        @endif
    </script>

    @if (session('success'))
        <script>
            // Alert menggunakan SweetAlert2
            document.addEventListener('DOMContentLoaded', function() {
                Swal.fire({
                    icon: 'success',
                    title: 'Sukses!',
                    text: '{{ session('success') }}',
                    confirmButtonColor: '#6366f1',
                    timer: 3000,
                    timerProgressBar: true
                });
            });
        </script>
    @endif

    <!-- Header Section -->
    <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 lg:mb-8 space-y-4 sm:space-y-0">
        <div>
            <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">Profil Vendor</h1>
            <p class="text-gray-600 text-sm sm:text-base">Kelola informasi profil dan akun Anda</p>
        </div>
        <div class="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-3">
            <button onclick="openModal('editModal')"
                class="flex items-center justify-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition text-sm sm:text-base">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5 mr-2" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                Edit Profil
            </button>
        </div>
    </div>

    <!-- Main Profile Card -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden mb-6 lg:mb-8">
        <div class="flex flex-col lg:flex-row">
            <!-- Sidebar (Images and Actions) -->
            <div
                class="lg:w-1/3 bg-gray-50 p-4 sm:p-6 flex flex-col items-center border-b lg:border-b-0 lg:border-r border-gray-200">
                <!-- Profile Image -->
                <div class="relative mb-4 sm:mb-6">
                    <div class="w-32 h-32 sm:w-40 sm:h-40 rounded-full overflow-hidden border-4 border-white shadow-lg">
                        <img id="profileImagePreview" src="{{ config('api.base_url') . $user['profile_image'] }}"
                            alt="Foto Profil" class="w-full h-full object-cover">
                    </div>
                    <button onclick="openPhotoModal('profile')"
                        class="absolute bottom-1 right-1 sm:bottom-2 sm:right-2 bg-blue-600 p-2 rounded-full shadow-md hover:bg-blue-700 transition transform hover:scale-105">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5 text-white" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                        </svg>
                    </button>
                </div>

                <!-- Status Badge -->
                <div
                    class="mt-2 sm:mt-4 px-3 sm:px-4 py-1 sm:py-2 rounded-full text-sm 
                        @if ($user['status'] === 'active') bg-green-100 text-green-800
                        @elseif($user['status'] === 'pending') bg-yellow-100 text-yellow-800
                        @else bg-red-100 text-red-800 @endif">
                    {{ ucfirst($user['status']) }}
                </div>
            </div>

            <!-- Main Content (Vendor Data) -->
            <div class="lg:w-2/3 p-4 sm:p-6">
                <h2 class="text-xl sm:text-2xl font-bold text-gray-800 mb-4 sm:mb-6 pb-2 border-b border-gray-200">Informasi
                    Vendor</h2>

                <!-- Personal Information Section -->
                <div class="mb-6 sm:mb-8">
                    <h3 class="text-base sm:text-lg font-semibold text-gray-700 mb-3 sm:mb-4 flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5 mr-2 text-blue-500"
                            fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                        Informasi Pribadi
                    </h3>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                        <div class="bg-gray-50 p-3 sm:p-4 rounded-lg">
                            <p class="text-xs sm:text-sm font-medium text-gray-500">Nama Lengkap</p>
                            <p class="text-sm sm:text-base text-gray-800 font-semibold break-words">
                                {{ $user['name'] ?? '-' }}</p>
                        </div>
                        <div class="bg-gray-50 p-3 sm:p-4 rounded-lg">
                            <p class="text-xs sm:text-sm font-medium text-gray-500">Email</p>
                            <p class="text-sm sm:text-base text-gray-800 font-semibold break-all">
                                {{ $user['email'] ?? '-' }}</p>
                        </div>
                        <div class="bg-gray-50 p-3 sm:p-4 rounded-lg">
                            <p class="text-xs sm:text-sm font-medium text-gray-500">Telepon</p>
                            <p class="text-sm sm:text-base text-gray-800 font-semibold">{{ $user['phone'] ?? '-' }}</p>
                        </div>
                        <div class="bg-gray-50 p-3 sm:p-4 rounded-lg">
                            <p class="text-xs sm:text-sm font-medium text-gray-500">Alamat</p>
                            <p class="text-sm sm:text-base text-gray-800 font-semibold break-words">
                                {{ $user['address'] ?? '-' }}</p>
                        </div>
                    </div>
                </div>

                <!-- Shop Information Section -->
                <div class="mb-6 sm:mb-8">
                    <h3 class="text-base sm:text-lg font-semibold text-gray-700 mb-3 sm:mb-4 flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5 mr-2 text-blue-500"
                            fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                        </svg>
                        Informasi Toko
                    </h3>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                        <div class="bg-gray-50 p-3 sm:p-4 rounded-lg">
                            <p class="text-xs sm:text-sm font-medium text-gray-500">Nama Toko</p>
                            <p class="text-sm sm:text-base text-gray-800 font-semibold break-words">
                                {{ $vendor['shop_name'] ?? '-' }}</p>
                        </div>
                        <div class="bg-gray-50 p-3 sm:p-4 rounded-lg">
                            <p class="text-xs sm:text-sm font-medium text-gray-500">Nama Kecamatan</p>
                            <p class="text-sm sm:text-base text-gray-800 font-semibold break-words">
                                {{ $vendor['kecamatan']['nama_kecamatan'] ?? '-' }}</p>
                        </div>
                        <div class="sm:col-span-2 bg-gray-50 p-3 sm:p-4 rounded-lg">
                            <p class="text-xs sm:text-sm font-medium text-gray-500">Alamat Toko</p>
                            <p class="text-sm sm:text-base text-gray-800 font-semibold break-words">
                                {{ $vendor['shop_address'] ?? '-' }}</p>
                        </div>
                        <div class="sm:col-span-2 bg-gray-50 p-3 sm:p-4 rounded-lg">
                            <p class="text-xs sm:text-sm font-medium text-gray-500">Deskripsi Toko</p>
                            <p class="text-sm sm:text-base text-gray-800 break-words">
                                {{ $vendor['shop_description'] ?? '-' }}</p>
                        </div>
                    </div>
                </div>

                <!-- Timestamps -->
                <div class="text-xs sm:text-sm text-gray-500 border-t border-gray-200 pt-3 sm:pt-4">
                    <div class="flex flex-col sm:flex-row sm:justify-between space-y-1 sm:space-y-0">
                        <span>Dibuat:
                            {{ \Carbon\Carbon::parse($user['created_at'])->translatedFormat('d F Y H:i') }}</span>
                        <span>Diubah:
                            {{ \Carbon\Carbon::parse($user['updated_at'])->translatedFormat('d F Y H:i') }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Security Card -->
    <div class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="p-4 sm:p-6">
            <h2 class="text-lg sm:text-xl font-bold text-gray-800 mb-3 sm:mb-4 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 sm:h-6 sm:w-6 mr-2 text-blue-500" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
                Keamanan Akun
            </h2>

            <div class="bg-blue-50 border-l-4 border-blue-500 p-3 sm:p-4 rounded-r-lg mb-3 sm:mb-4">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <svg class="h-4 w-4 sm:h-5 sm:w-5 text-blue-500" xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd"
                                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2h-1V9z"
                                clip-rule="evenodd" />
                        </svg>
                    </div>
                    <div class="ml-3">
                        <p class="text-xs sm:text-sm text-blue-700">
                            Untuk keamanan akun Anda, disarankan untuk mengganti kata sandi secara berkala.
                        </p>
                    </div>
                </div>
            </div>

            <div
                class="flex flex-col sm:flex-row sm:justify-between sm:items-center bg-gray-50 p-3 sm:p-4 rounded-lg space-y-3 sm:space-y-0">
                <div>
                    <h3 class="font-medium text-gray-800 text-sm sm:text-base">Kata Sandi</h3>
                    <p class="text-xs sm:text-sm text-gray-500">Terakhir diubah
                        {{ \Carbon\Carbon::parse($user['updated_at'])->diffForHumans() }}</p>
                </div>
                <a href="{{ route('vendor.otp.form') }}"
                    class="text-blue-600 hover:text-blue-800 font-medium flex items-center justify-center sm:justify-start text-sm sm:text-base">
                    Ubah Kata Sandi
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5 ml-1" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                    </svg>
                </a>
            </div>
        </div>
    </div>

    <!-- Edit Profile Modal -->
    <div id="editModal"
        class="modal hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50 z-50 p-4">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <!-- Header dengan Background Biru (Sticky) -->
            <div class="bg-blue-600 text-white rounded-t-xl px-4 sm:px-6 py-3 sm:py-4 sticky top-0 z-10 shadow-md">
                <div class="flex justify-between items-center">
                    <div>
                        <h2 class="text-xl sm:text-2xl font-bold">Edit Profil Vendor</h2>
                        <p class="text-xs sm:text-sm text-blue-100 mt-1">Perbarui informasi profil dan toko</p>
                    </div>
                    <button onclick="closeModal('editModal')" class="text-white hover:text-blue-200">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 sm:h-6 sm:w-6" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>
            <!-- Body Form -->
            <div class="p-4 sm:p-6">
                <form action="{{ route('vendor.profile.edit') }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    @method('PUT')

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6 mb-6">
                        <!-- Personal Information -->
                        <div class="space-y-4">
                            <h3 class="text-base sm:text-lg font-semibold text-gray-700 border-b pb-2">Informasi Pribadi
                            </h3>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Nama</label>
                                <input type="text" name="name" value="{{ $user['name'] }}"
                                    class="w-full px-3 py-2 text-sm sm:text-base border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                                <input type="email" name="email" value="{{ $user['email'] }}"
                                    class="w-full px-3 py-2 text-sm sm:text-base border border-gray-300 rounded-lg bg-gray-100 cursor-not-allowed"
                                    readonly>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Telepon</label>
                                <input type="text" name="phone" value="{{ $user['phone'] }}"
                                    class="w-full px-3 py-2 text-sm sm:text-base border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Alamat</label>
                                <input type="text" name="address" value="{{ $user['address'] }}"
                                    class="w-full px-3 py-2 text-sm sm:text-base border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300">
                            </div>
                        </div>

                        <!-- Shop Information -->
                        <div class="space-y-4">
                            <h3 class="text-base sm:text-lg font-semibold text-gray-700 border-b pb-2">Informasi Toko</h3>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Nama Toko</label>
                                <input type="text" name="shop_name" value="{{ $vendor['shop_name'] ?? '' }}"
                                    class="w-full px-3 py-2 text-sm sm:text-base border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Alamat Toko</label>
                                <input type="text" name="shop_address" value="{{ $vendor['shop_address'] ?? '' }}"
                                    class="w-full px-3 py-2 text-sm sm:text-base border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Nama Kecamatan</label>
                                <input type="text" name="nama_kecamatan"
                                    value="{{ $vendor['kecamatan']['nama_kecamatan'] ?? '' }}"
                                    class="w-full px-3 py-2 text-sm sm:text-base border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi Toko</label>
                                <textarea name="shop_description" rows="3"
                                    class="w-full px-3 py-2 text-sm sm:text-base border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300">{{ $vendor['shop_description'] ?? '' }}</textarea>
                            </div>
                        </div>
                    </div>

                    <!-- Form Actions -->
                    <div class="border-t border-gray-200 pt-4 sm:pt-6 mt-4 sm:mt-6">
                        <div class="flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3">
                            <button type="button" onclick="closeModal('editModal')"
                                class="px-4 py-2 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded-lg transition duration-300 text-sm sm:text-base">
                                Batal
                            </button>
                            <button type="submit"
                                class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg shadow-md transition duration-300 flex items-center justify-center text-sm sm:text-base">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 sm:h-5 sm:w-5 mr-2" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M5 13l4 4L19 7" />
                                </svg>
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
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-md">
            <div class="p-4 sm:p-6">
                <div class="flex justify-between items-center mb-4">
                    <h2 id="photoModalTitle" class="text-lg sm:text-xl font-bold text-gray-800"></h2>
                    <button onclick="closeModal('editPhotoModal')" class="text-gray-500 hover:text-gray-700">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 sm:h-6 sm:w-6" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <form id="photoForm" action="{{ route('vendor.profile.edit') }}" method="POST"
                    enctype="multipart/form-data">
                    @csrf
                    @method('PUT')

                    <div class="mb-4">
                        <div class="flex justify-center mb-4">
                            <div class="border-2 border-dashed border-gray-300 rounded-lg p-4 w-full text-center">
                                <div id="imagePreviewContainer" class="mb-3 hidden">
                                    <img id="imagePreview" src="#" alt="Preview"
                                        class="max-h-32 sm:max-h-40 mx-auto rounded-lg">
                                </div>
                                <label for="photoInput" class="cursor-pointer">
                                    <svg xmlns="http://www.w3.org/2000/svg"
                                        class="h-10 w-10 sm:h-12 sm:w-12 mx-auto text-gray-400" fill="none"
                                        viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                                    </svg>
                                    <p class="text-xs sm:text-sm text-gray-600 mt-2">Klik untuk mengunggah gambar</p>
                                    <p class="text-xs text-gray-500">Format: JPG, PNG (Maks. 2MB)</p>
                                </label>
                                <input type="file" name="" id="photoInput" class="hidden" accept="image/*">
                            </div>
                        </div>
                    </div>

                    <div
                        class="flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 pt-4 border-t border-gray-200">
                        <button type="button" onclick="closeModal('editPhotoModal')"
                            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition text-sm sm:text-base">
                            Batal
                        </button>
                        <button type="submit"
                            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition text-sm sm:text-base">
                            Simpan Foto
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Modal functions
        function openModal(modalId) {
            document.getElementById(modalId).classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.add('hidden');
            document.body.style.overflow = '';
        }

        // Photo modal function
        function openPhotoModal(type) {
            const title = type === 'profile' ? 'Edit Foto Profil' : 'Edit Foto KTP';
            const inputName = type === 'profile' ? 'profile_image' : 'ktp_image';

            document.getElementById('photoModalTitle').innerText = title;
            document.getElementById('photoInput').name = inputName;

            // Reset preview and file input
            document.getElementById('imagePreviewContainer').classList.add('hidden');
            document.getElementById('photoInput').value = '';

            openModal('editPhotoModal');
        }

        // Image preview for file input
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

        // Close modal when clicking outside
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                const modals = document.querySelectorAll('.modal');
                modals.forEach(modal => {
                    if (!modal.classList.contains('hidden')) {
                        modal.classList.add('hidden');
                        document.body.style.overflow = '';
                    }
                });
            }
        }
    </script>
@endsection
