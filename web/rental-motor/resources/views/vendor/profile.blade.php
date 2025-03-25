@extends('layouts.app')

@section('title', 'Profil Vendor')

@section('content')
    @php
        $vendor = $user['vendor'] ?? [];
    @endphp

    <div class="container mx-auto px-4 py-8">
        <div class="bg-white shadow-lg rounded-lg overflow-hidden">
            <div class="md:flex">
                <!-- Sidebar (Gambar dan Aksi) -->
                <div class="md:w-1/3 bg-gray-100 p-6 flex flex-col items-center">
                    <!-- Foto Profil -->
                    <div class="relative w-40 h-40 mb-4">
                        <img src="{{ 'http://localhost:8080' . ($user['profile_image'] ?: '/fileserver/vendor/placeholder.jpg') }}"
                            alt="Foto Profil" class="w-full h-full object-cover rounded-full border">
                        <button onclick="openPhotoModal('profile')"
                            class="absolute bottom-0 right-0 bg-blue-600 p-2 rounded-full shadow hover:bg-blue-700">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-white" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M3 7h4l2-3h6l2 3h4v13H3V7z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M12 11a4 4 0 100 8 4 4 0 000-8z" />
                            </svg>
                        </button>
                    </div>
                    <!-- Foto KTP -->
                    <div class="relative w-40 h-40 mb-4">
                        <img src="{{ 'http://localhost:8080' . ($user['ktp_image'] ?: '/fileserver/vendor/placeholder.jpg') }}"
                            alt="Foto KTP" class="w-full h-full object-cover rounded border">
                        <button onclick="openPhotoModal('ktp')"
                            class="absolute bottom-0 right-0 bg-blue-600 p-2 rounded-full shadow hover:bg-blue-700">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-white" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M3 7h4l2-3h6l2 3h4v13H3V7z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M12 11a4 4 0 100 8 4 4 0 000-8z" />
                            </svg>
                        </button>
                    </div>
                    <!-- Tombol Edit Profil -->
                    <button onclick="openModal('editModal')"
                        class="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition">
                        Edit Profil
                    </button>
                </div>
                <!-- Konten Utama (Data Vendor) -->
                <div class="md:w-2/3 p-6">
                    <h2 class="text-2xl font-bold mb-4 border-b pb-2">Informasi Vendor</h2>
                    <div class="grid grid-cols-1 gap-4">
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Nama</span>
                            <span class="flex-1">{{ $user['name'] }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Email</span>
                            <span class="flex-1">{{ $user['email'] }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Telepon</span>
                            <span class="flex-1">{{ $user['phone'] }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Alamat</span>
                            <span class="flex-1">{{ $user['address'] }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Nama Toko</span>
                            <span class="flex-1">{{ $vendor['ShopName'] ?? '-' }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Alamat Toko</span>
                            <span class="flex-1">{{ $vendor['ShopAddress'] ?? '-' }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Deskripsi Toko</span>
                            <span class="flex-1">{{ $vendor['ShopDescription'] ?? '-' }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">ID Kecamatan</span>
                            <span class="flex-1">{{ $vendor['IDKecamatan'] ?? '-' }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Status</span>
                            <span class="flex-1">{{ $user['status'] }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Dibuat</span>
                            <span class="flex-1">{{ $user['created_at'] }}</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-40 font-semibold">Diubah</span>
                            <span class="flex-1">{{ $user['updated_at'] }}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal Edit Profil (data user & vendor) -->
        <div id="editModal" class="modal hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50">
            <div class="bg-white p-6 rounded-lg shadow-lg w-96">
                <h2 class="text-2xl font-semibold mb-4">Edit Profil Vendor</h2>
                <form action="{{ route('vendor.profile.edit') }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    @method('PUT')
                    <!-- Data User -->
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">Nama</label>
                        <input type="text" name="name" value="{{ $user['name'] }}"
                            class="w-full p-2 border rounded-lg" required>
                    </div>
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">Email</label>
                        <input type="email" name="email" value="{{ $user['email'] }}"
                            class="w-full p-2 border rounded-lg bg-gray-100" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">Telepon</label>
                        <input type="text" name="phone" value="{{ $user['phone'] }}"
                            class="w-full p-2 border rounded-lg" required>
                    </div>
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">Alamat</label>
                        <input type="text" name="address" value="{{ $user['address'] }}"
                            class="w-full p-2 border rounded-lg" required>
                    </div>
                    <!-- Data Vendor -->
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">Nama Toko</label>
                        <input type="text" name="shop_name" value="{{ $vendor['ShopName'] ?? '' }}"
                            class="w-full p-2 border rounded-lg" required>
                    </div>
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">Alamat Toko</label>
                        <input type="text" name="shop_address" value="{{ $vendor['ShopAddress'] ?? '' }}"
                            class="w-full p-2 border rounded-lg" required>
                    </div>
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">Deskripsi Toko</label>
                        <textarea name="shop_description" class="w-full p-2 border rounded-lg" rows="3">{{ $vendor['ShopDescription'] ?? '' }}</textarea>
                    </div>
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">ID Kecamatan</label>
                        <input type="text" name="id_kecamatan" value="{{ $vendor['IDKecamatan'] ?? '' }}"
                            class="w-full p-2 border rounded-lg">
                    </div>
                    <div class="mb-3">
                        <label class="block font-semibold mb-1">Password (kosongkan jika tidak diubah)</label>
                        <input type="password" name="password" class="w-full p-2 border rounded-lg">
                    </div>
                    <div class="flex justify-end space-x-3 mt-4">
                        <button type="button" onclick="closeModal('editModal')"
                            class="px-4 py-2 bg-gray-500 text-white rounded-lg">Batal</button>
                        <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Modal Edit Foto (untuk profile_image dan ktp_image) -->
        <div id="editPhotoModal"
            class="modal hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50">
            <div class="bg-white p-6 rounded-lg shadow-lg w-80">
                <h2 id="photoModalTitle" class="text-2xl font-semibold mb-4"></h2>
                <form id="photoForm" action="{{ route('vendor.profile.edit') }}" method="POST"
                    enctype="multipart/form-data">
                    @csrf
                    @method('PUT')
                    <div class="mb-4">
                        <label class="block font-semibold mb-1">Pilih File</label>
                        <input type="file" name="" id="photoInput" class="w-full p-2 border rounded-lg"
                            required>
                    </div>
                    <div class="flex justify-end space-x-3">
                        <button type="button" onclick="closeModal('editPhotoModal')"
                            class="px-4 py-2 bg-gray-500 text-white rounded-lg">Batal</button>
                        <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg">Simpan Foto</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            // Fungsi membuka modal berdasarkan ID
            function openModal(modalId) {
                document.getElementById(modalId).classList.remove('hidden');
            }
            // Fungsi menutup modal berdasarkan ID
            function closeModal(modalId) {
                document.getElementById(modalId).classList.add('hidden');
            }
            // Fungsi untuk membuka modal edit foto
            // Parameter type: 'profile' atau 'ktp'
            function openPhotoModal(type) {
                var title = '';
                var inputName = '';
                if (type === 'profile') {
                    title = 'Edit Foto Profil';
                    inputName = 'profile_image';
                } else if (type === 'ktp') {
                    title = 'Edit Foto KTP';
                    inputName = 'ktp_image';
                }
                document.getElementById('photoModalTitle').innerText = title;
                document.getElementById('photoInput').name = inputName;
                openModal('editPhotoModal');
            }
        </script>
    @endsection
