@extends('layouts.app')

@section('title', 'Profil Admin')

@section('content')
    <div class="max-w-3xl mx-auto bg-white p-6 rounded-lg shadow-md">
        <h1 class="text-3xl font-semibold mb-6 text-gray-800">Profil Admin</h1>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Data Admin -->
            <div class="space-y-3">
                <p class="text-lg"><strong>Nama:</strong> {{ $adminData['name'] }}</p>
                <p class="text-lg"><strong>Email:</strong> {{ $adminData['email'] }}</p>
                <p class="text-lg"><strong>Telepon:</strong> {{ $adminData['phone'] }}</p>
                <p class="text-lg"><strong>Alamat:</strong> {{ $adminData['address'] }}</p>
                <p class="text-lg"><strong>Status:</strong> {{ $adminData['status'] }}</p>
                <p class="text-lg"><strong>Dibuat:</strong>
                    {{ \Carbon\Carbon::parse($adminData['created_at'])->format('d M Y, H:i') }}</p>
                <p class="text-lg"><strong>Diubah:</strong>
                    {{ \Carbon\Carbon::parse($adminData['updated_at'])->format('d M Y, H:i') }}</p>
            </div>
            <!-- Gambar Profil & KTP -->
            <div class="space-y-4">
                <div class="relative flex items-center justify-center">
                    <img src="{{ $adminData['profile_image'] ?? 'https://via.placeholder.com/150' }}" alt="Foto Profil"
                        class="w-40 h-40 rounded-full object-cover border">
                    <button onclick="document.getElementById('editPhotoModal').style.display='flex'"
                        class="absolute bottom-0 right-0 bg-blue-500 p-2 rounded-full shadow-lg hover:bg-blue-600">
                        <!-- Icon camera -->
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-white" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M3 7h4l2-3h6l2 3h4v13H3V7z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 11a4 4 0 100 8 4 4 0 000-8z" />
                        </svg>
                    </button>
                </div>
                {{-- @dd($adminData); --}}
                <div class="relative flex items-center justify-center">
                    <img src="{{ $adminData['ktp_image'] ?? 'https://via.placeholder.com/150' }}" alt="Foto KTP"
                        class="w-40 h-40 rounded object-cover border">
                    <button onclick="document.getElementById('editKtpModal').style.display='flex'"
                        class="absolute bottom-0 right-0 bg-blue-500 p-2 rounded-full shadow-lg hover:bg-blue-600">
                        <!-- Icon camera -->
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-white" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M3 7h4l2-3h6l2 3h4v13H3V7z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 11a4 4 0 100 8 4 4 0 000-8z" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
        <div class="mt-6">
            <button onclick="document.getElementById('editModal').style.display='flex'"
                class="px-5 py-2 bg-blue-500 text-white font-semibold rounded-lg hover:bg-blue-600 transition">
                Edit Profil
            </button>
        </div>
    </div>

    <!-- Modal Edit Profil (seluruh data kecuali foto) -->
    <div id="editModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50">
        <div class="bg-white p-6 rounded-lg shadow-lg w-96">
            <h2 class="text-2xl font-semibold mb-4">Edit Profil</h2>
            <form action="{{ route('admin.update') }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')
                <!-- Nama -->
                <label class="block mb-2">Nama:
                    <input type="text" name="name" value="{{ old('name', $adminData['name']) }}"
                        class="w-full p-2 border rounded-lg" required>
                </label>
                <!-- Email (readonly) -->
                <label class="block mb-2">Email:
                    <input type="email" name="email" value="{{ $adminData['email'] }}"
                        class="w-full p-2 border rounded-lg bg-gray-100" readonly>
                </label>
                <!-- Telepon -->
                <label class="block mb-2">Telepon:
                    <input type="text" name="phone" value="{{ old('phone', $adminData['phone']) }}"
                        class="w-full p-2 border rounded-lg" required>
                </label>
                <!-- Alamat -->
                <label class="block mb-2">Alamat:
                    <input type="text" name="address" value="{{ old('address', $adminData['address']) }}"
                        class="w-full p-2 border rounded-lg" required>
                </label>
                <!-- Password -->
                <label class="block mb-2">Password (kosongkan jika tidak diubah):
                    <input type="password" name="password" class="w-full p-2 border rounded-lg">
                </label>
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="document.getElementById('editModal').style.display='none'"
                        class="px-4 py-2 bg-gray-500 text-white rounded-lg">Batal</button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg">Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Edit Foto Profil -->
    <div id="editPhotoModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50">
        <div class="bg-white p-6 rounded-lg shadow-lg w-80">
            <h2 class="text-2xl font-semibold mb-4">Edit Foto Profil</h2>
            <form action="{{ route('admin.update') }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')
                <!-- Hanya kirim file gambar untuk profile_image -->
                <label class="block mb-4">Pilih Foto Profil:
                    <input type="file" name="profile_image" class="w-full p-2 border rounded-lg" required>
                </label>
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="document.getElementById('editPhotoModal').style.display='none'"
                        class="px-4 py-2 bg-gray-500 text-white rounded-lg">Batal</button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg">Simpan Foto</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Edit Foto KTP -->
    <div id="editKtpModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50">
        <div class="bg-white p-6 rounded-lg shadow-lg w-80">
            <h2 class="text-2xl font-semibold mb-4">Edit Foto KTP</h2>
            <form action="{{ route('admin.update') }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')
                <!-- Hanya kirim file gambar untuk ktp_image -->
                <label class="block mb-4">Pilih Foto KTP:
                    <input type="file" name="ktp_image" class="w-full p-2 border rounded-lg" required>
                </label>
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="document.getElementById('editKtpModal').style.display='none'"
                        class="px-4 py-2 bg-gray-500 text-white rounded-lg">Batal</button>
                    <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg">Simpan Foto</button>
                </div>
            </form>
        </div>
    </div>
@endsection
