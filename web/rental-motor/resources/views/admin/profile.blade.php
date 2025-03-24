@extends('layouts.app')

@section('title', 'Profil Admin')

@section('content')

    <div class="max-w-3xl mx-auto bg-white p-6 rounded-lg shadow-md" x-data="profileData()">

        <h1 class="text-3xl font-semibold mb-6 text-gray-800">Profil Admin</h1>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <p class="text-lg"><strong>Nama:</strong> <span x-text="user.name"></span></p>
                <p class="text-lg"><strong>Email:</strong> <span x-text="user.email"></span></p>
                <p class="text-lg"><strong>Telepon:</strong> <span x-text="user.phone"></span></p>
                <p class="text-lg"><strong>Alamat:</strong> <span x-text="user.address"></span></p>
            </div>
            <div class="flex items-center justify-center">
                <img :src="'user.profile_image' ?? 'https://via.placeholder.com/150'" alt="Foto Profil"
                    class="w-32 h-32 rounded-full object-cover border">
            </div>
        </div>

        <button @click="isOpen = true"
            class="mt-6 px-5 py-2 bg-blue-500 text-white font-semibold rounded-lg hover:bg-blue-600 transition">
            Edit Profil
        </button>

        <!-- Modal Edit Profil -->
        <div class="fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50" x-show="isOpen" x-cloak>

            <div class="bg-white p-6 rounded-lg shadow-lg w-96">
                <h2 class="text-2xl font-semibold mb-4">Edit Profil</h2>

                <form @submit.prevent="updateProfile()">
                    <label class="block mb-2">Nama:
                        <input type="text" x-model="user.name" class="w-full p-2 border rounded-lg">
                    </label>

                    <label class="block mb-2">Email:
                        <input type="email" value="{{ $adminData['email'] ?? '' }}"
                            class="w-full p-2 border rounded-lg bg-gray-100" disabled>
                    </label>

                    <label class="block mb-2">Telepon:
                        <input type="text" x-model="user.phone" class="w-full p-2 border rounded-lg">
                    </label>

                    <label class="block mb-2">Alamat:
                        <input type="text" x-model="user.address" class="w-full p-2 border rounded-lg">
                    </label>

                    <label class="block mb-4">Foto Profil:
                        <input type="file" @change="handleFileUpload" class="w-full p-2 border rounded-lg">
                    </label>

                    <div class="flex justify-end space-x-3">
                        <button type="button" @click="isOpen = false"
                            class="px-4 py-2 bg-gray-500 text-white rounded-lg">Batal</button>
                        <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg">Simpan</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function profileData() {
            return {
                isOpen: false,
                user: @json($adminData),

                handleFileUpload(event) {
                    let file = event.target.files[0];
                    let reader = new FileReader();
                    reader.onload = () => {
                        this.user.profile_image = reader.result;
                    };
                    reader.readAsDataURL(file);
                },

                updateProfile() {
                    fetch('http://localhost:8080/admin/profile/edit', {
                            method: 'PUT',
                            headers: {
                                "Authorization": "Bearer {{ session('token') }}",
                                "Content-Type": "application/json"
                            },
                            body: JSON.stringify(this.user)
                        })
                        .then(response => {
                            if (response.ok) {
                                alert('Profil berhasil diperbarui');
                                this.isOpen = false;
                            } else {
                                alert('Gagal memperbarui profil');
                            }
                        })
                        .catch(error => console.error('Error:', error));
                }
            }
        }
    </script>

@endsection
