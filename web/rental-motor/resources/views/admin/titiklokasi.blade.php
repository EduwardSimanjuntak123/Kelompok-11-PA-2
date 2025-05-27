@extends('layouts.app')

@section('title', 'Data Titik Lokasi')

@section('content')
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    @if (session('message'))
        <script>
            Swal.fire({
                icon: 'success',
                title: 'Berhasil!',
                text: '{{ session('message') }}',
                confirmButtonText: 'OK'
            });
        </script>
    @endif

    @if (session('error'))
        <script>
            Swal.fire({
                icon: 'error',
                title: 'Gagal',
                text: '{{ session('error') }}',
                confirmButtonText: 'OK'
            });
        </script>
    @endif

    <div x-data="titikLokasiApp({{ Js::from($kecamatans) }}, {{ Js::from($titiklokasis) }})" class="flex flex-col lg:flex-row min-h-screen">
        <!-- Mobile Header dengan Dropdown Kecamatan -->
        <div class="lg:hidden bg-white border-b p-4">
            <div class="flex justify-between items-center mb-3">
                <h1 class="text-lg font-bold text-gray-800">Data Titik Lokasi</h1>
                <button @click="toggleMobileSidebar()" class="p-2 rounded-md bg-blue-500 text-white">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                    </svg>
                </button>
            </div>
            
            <!-- Mobile Kecamatan Selector -->
            <template x-if="kecamatans.length > 0">
                <select @change="setActive(parseInt($event.target.value))" 
                        class="w-full p-3 border rounded-lg bg-white text-sm"
                        :value="activeKecamatan">
                    <template x-for="kecamatan in kecamatans" :key="kecamatan.id_kecamatan">
                        <option :value="kecamatan.id_kecamatan" x-text="kecamatan.nama_kecamatan"></option>
                    </template>
                </select>
            </template>
        </div>

        <!-- Sidebar Kecamatan (Desktop) -->
        <aside class="hidden lg:block w-64 bg-white border-r">
            <div class="p-4 font-bold text-lg text-left border-b">Kecamatan</div>
            <div class="p-4">
                <template x-if="kecamatans.length === 0">
                    <div class="flex flex-col items-center justify-center text-center p-4 bg-gray-50 rounded-lg">
                        <div class="text-gray-400 text-3xl mb-2">
                            <i class="fas fa-map-marker-alt"></i>
                        </div>
                        <h3 class="text-lg font-medium text-gray-700">Tidak Ada Kecamatan</h3>
                        <p class="text-gray-500 text-sm mt-1">Data kecamatan belum tersedia.</p>
                    </div>
                </template>

                <template x-if="kecamatans.length > 0">
                    <nav class="space-y-2">
                        <template x-for="kecamatan in kecamatans" :key="kecamatan.id_kecamatan">
                            <button @click="setActive(kecamatan.id_kecamatan)"
                                class="block w-full text-left px-4 py-2 rounded-lg hover:bg-blue-100 transition-colors"
                                :class="{ 'bg-blue-200': activeKecamatan === kecamatan.id_kecamatan }">
                                <span x-text="kecamatan.nama_kecamatan"></span>
                            </button>
                        </template>
                    </nav>
                </template>
            </div>
        </aside>

        <!-- Mobile Sidebar Overlay -->
        <div x-show="showMobileSidebar" 
             x-transition:enter="transition-opacity ease-linear duration-300"
             x-transition:enter-start="opacity-0"
             x-transition:enter-end="opacity-100"
             x-transition:leave="transition-opacity ease-linear duration-300"
             x-transition:leave-start="opacity-100"
             x-transition:leave-end="opacity-0"
             @click="closeMobileSidebar()"
             class="lg:hidden fixed inset-0 z-20 bg-black bg-opacity-50"
             style="display: none;">
        </div>

        <div x-show="showMobileSidebar"
             x-transition:enter="transition ease-in-out duration-300 transform"
             x-transition:enter-start="-translate-x-full"
             x-transition:enter-end="translate-x-0"
             x-transition:leave="transition ease-in-out duration-300 transform"
             x-transition:leave-start="translate-x-0"
             x-transition:leave-end="-translate-x-full"
             class="lg:hidden fixed inset-y-0 left-0 z-30 w-64 bg-white shadow-xl"
             style="display: none;">
            <div class="p-4 font-bold text-lg border-b flex justify-between items-center">
                <span>Kecamatan</span>
                <button @click="closeMobileSidebar()" class="text-gray-500 hover:text-gray-700">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
            <div class="p-4">
                <template x-if="kecamatans.length > 0">
                    <nav class="space-y-2">
                        <template x-for="kecamatan in kecamatans" :key="kecamatan.id_kecamatan">
                            <button @click="setActive(kecamatan.id_kecamatan); closeMobileSidebar()"
                                class="block w-full text-left px-4 py-3 rounded-lg hover:bg-blue-100 transition-colors"
                                :class="{ 'bg-blue-200': activeKecamatan === kecamatan.id_kecamatan }">
                                <span x-text="kecamatan.nama_kecamatan"></span>
                            </button>
                        </template>
                    </nav>
                </template>
            </div>
        </div>

        <!-- Konten Utama -->
        <div class="flex-1 p-4 lg:p-6">
            <template x-if="kecamatans.length === 0">
                <div class="flex flex-col items-center justify-center text-center p-6 lg:p-10 bg-white rounded-lg shadow-md">
                    <div class="text-gray-400 text-4xl lg:text-5xl mb-4">
                        <i class="fas fa-map-marked-alt"></i>
                    </div>
                    <h2 class="text-xl lg:text-2xl font-semibold text-gray-700">Tidak Ada Data Kecamatan</h2>
                    <p class="text-gray-600 mt-2 text-sm lg:text-base">Data kecamatan belum tersedia. Silakan tambahkan data kecamatan terlebih dahulu.</p>
                </div>
            </template>

            <template x-if="kecamatans.length > 0">
                <template x-for="kecamatan in kecamatans" :key="kecamatan.id_kecamatan">
                    <div x-show="activeKecamatan === kecamatan.id_kecamatan">
                        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-4 lg:mb-6 gap-3">
                            <h1 class="text-xl lg:text-2xl font-bold text-gray-800" x-text="kecamatan.nama_kecamatan"></h1>
                            <button @click="openAddModal(kecamatan.id_kecamatan)"
                                class="w-full sm:w-auto bg-blue-500 hover:bg-blue-600 text-white font-semibold py-3 px-4 lg:py-2 lg:px-4 rounded-lg shadow-md transition-colors">
                                <i class="fas fa-plus mr-2"></i>Tambah Lokasi
                            </button>
                        </div>

                        <!-- Tabel Lokasi - Mobile Card View -->
                        <div class="block sm:hidden space-y-3">
                            <template x-if="filteredLokasi.length > 0">
                                <div>
                                    <template x-for="lokasi in filteredLokasi" :key="lokasi.id">
                                        <div class="bg-white rounded-lg shadow-md p-4 border">
                                            <div class="mb-3">
                                                <h3 class="font-semibold text-gray-800 text-lg" x-text="lokasi.place"></h3>
                                                <p class="text-gray-600 text-sm mt-1" x-text="lokasi.address"></p>
                                            </div>
                                            <div class="flex gap-2">
                                                <button @click="openEditModal(lokasi)"
                                                    class="flex-1 bg-yellow-400 hover:bg-yellow-500 text-white py-2 px-3 rounded-lg shadow-md transition-colors">
                                                    <i class="fas fa-edit mr-1"></i>Edit
                                                </button>
                                                <button type="button" @click="confirmDelete(lokasi.id)"
                                                    class="flex-1 bg-red-500 hover:bg-red-600 text-white py-2 px-3 rounded-lg shadow-md transition-colors">
                                                    <i class="fas fa-trash-alt mr-1"></i>Hapus
                                                </button>
                                            </div>
                                        </div>
                                    </template>
                                </div>
                            </template>

                            <template x-if="filteredLokasi.length === 0">
                                <div class="flex flex-col items-center justify-center text-center p-8 bg-white rounded-lg shadow-md">
                                    <div class="text-gray-400 text-4xl mb-3">
                                        <i class="fas fa-map-marker-slash"></i>
                                    </div>
                                    <h3 class="text-lg font-medium text-gray-700">Belum Ada Titik Lokasi</h3>
                                    <p class="text-gray-500 mt-1 text-sm">Tidak ada titik lokasi yang tersedia untuk kecamatan ini.</p>
                                    <button @click="openAddModal(activeKecamatan)"
                                        class="mt-4 w-full bg-blue-500 hover:bg-blue-600 text-white font-medium py-3 px-4 rounded-lg shadow-md transition-colors">
                                        <i class="fas fa-plus mr-2"></i>Tambah Lokasi
                                    </button>
                                </div>
                            </template>
                        </div>

                        <!-- Tabel Lokasi - Desktop Table View -->
                        <div class="hidden sm:block overflow-x-auto bg-white rounded-lg shadow-lg">
                            <table class="min-w-full table-auto text-sm">
                                <thead class="bg-blue-100 text-gray-600">
                                    <tr>
                                        <th class="px-4 lg:px-6 py-3 text-left font-medium">Nama Tempat</th>
                                        <th class="px-4 lg:px-6 py-3 text-left font-medium">Alamat</th>
                                        <th class="px-4 lg:px-6 py-3 text-center font-medium">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-200">
                                    <template x-if="filteredLokasi.length > 0">
                                        <template x-for="lokasi in filteredLokasi" :key="lokasi.id">
                                            <tr>
                                                <td class="px-4 lg:px-6 py-4 text-gray-700" x-text="lokasi.place"></td>
                                                <td class="px-4 lg:px-6 py-4 text-gray-700" x-text="lokasi.address"></td>
                                                <td class="px-4 lg:px-6 py-4 text-center space-x-2">
                                                    <button @click="openEditModal(lokasi)"
                                                        class="bg-yellow-400 hover:bg-yellow-500 text-white py-2 px-3 lg:px-4 rounded-lg shadow-md transition-colors">
                                                        <i class="fas fa-edit"></i>
                                                    </button>
                                                    <button type="button" @click="confirmDelete(lokasi.id)"
                                                        class="bg-red-500 hover:bg-red-600 text-white py-2 px-3 lg:px-4 rounded-lg shadow-md transition-colors">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        </template>
                                    </template>

                                    <template x-if="filteredLokasi.length === 0">
                                        <tr>
                                            <td colspan="3" class="py-12">
                                                <div class="flex flex-col items-center justify-center text-center p-6 bg-white rounded-lg">
                                                    <div class="text-gray-400 text-4xl mb-3">
                                                        <i class="fas fa-map-marker-slash"></i>
                                                    </div>
                                                    <h3 class="text-xl font-medium text-gray-700">Belum Ada Titik Lokasi</h3>
                                                    <p class="text-gray-500 mt-1">Tidak ada titik lokasi yang tersedia untuk kecamatan ini.</p>
                                                    <button @click="openAddModal(activeKecamatan)"
                                                        class="mt-4 bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded-lg shadow-md transition-colors">
                                                        <i class="fas fa-plus mr-2"></i>Tambah Lokasi
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </template>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </template>
            </template>
        </div>

        <!-- Modal Tambah Lokasi -->
        <div id="modal-add-lokasi"
            class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden z-50 p-4">
            <div class="relative bg-white rounded-lg w-full max-w-md transform transition-all duration-300 ease-in-out max-h-screen overflow-y-auto">
                <!-- Header dengan Background Biru -->
                <div class="bg-blue-600 text-white rounded-t-lg px-4 lg:px-6 py-4">
                    <div class="flex justify-between items-center">
                        <div>
                            <h2 class="text-xl lg:text-2xl font-bold">Tambah Lokasi</h2>
                            <p class="text-sm text-blue-100 mt-1">Tambahkan lokasi baru</p>
                        </div>
                        <button type="button" @click="closeAddModal()" class="text-white hover:text-blue-200 p-1">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Body Form -->
                <form id="form-add-lokasi" method="POST" action="" @submit.prevent="validateAdd" class="p-4 lg:p-6">
                    @csrf
                    <input type="hidden" name="district_id" id="district_id_add">

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Nama Tempat</label>
                        <input type="text" name="place" id="place_add"
                            class="w-full px-4 py-3 border rounded-md focus:ring-2 focus:ring-blue-400 focus:border-blue-400 transition duration-300 text-base">
                        <div id="place-error" class="text-red-500 text-sm mt-1 hidden">Nama Tempat harus diisi!</div>
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Alamat</label>
                        <input type="text" name="address" id="address_add"
                            class="w-full px-4 py-3 border rounded-md focus:ring-2 focus:ring-blue-400 focus:border-blue-400 transition duration-300 text-base">
                        <div id="address-error" class="text-red-500 text-sm mt-1 hidden">Alamat harus diisi!</div>
                    </div>

                    <!-- Footer -->
                    <div class="border-t border-gray-200 pt-4 lg:pt-6 mt-4 lg:mt-6">
                        <div class="flex flex-col sm:flex-row justify-end gap-2 sm:space-x-2 sm:gap-0">
                            <button type="button" @click="closeAddModal()"
                                class="w-full sm:w-auto px-4 py-3 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded-md font-semibold transition duration-300 order-2 sm:order-1">
                                Batal
                            </button>
                            <button type="submit"
                                class="w-full sm:w-auto px-4 py-3 bg-blue-500 hover:bg-blue-600 text-white rounded-md font-semibold shadow-md transition duration-300 order-1 sm:order-2">
                                Simpan
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Modal Edit Lokasi -->
        <div id="modal-edit-lokasi"
            class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden z-50 p-4">
            <div class="relative bg-white rounded-lg w-full max-w-md transform transition-all duration-300 ease-in-out max-h-screen overflow-y-auto">
                <!-- Header dengan Background Biru -->
                <div class="bg-blue-600 text-white rounded-t-lg px-4 lg:px-6 py-4">
                    <div class="flex justify-between items-center">
                        <div>
                            <h2 class="text-xl lg:text-2xl font-bold">Edit Lokasi</h2>
                            <p class="text-sm text-blue-100 mt-1">Perbarui data lokasi</p>
                        </div>
                        <button type="button" @click="closeEditModal()" class="text-white hover:text-blue-200 p-1">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Body Form -->
                <form id="form-edit-lokasi" method="POST" action="" @submit.prevent="validateEdit"
                    class="p-4 lg:p-6">
                    @csrf
                    @method('PUT')

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Nama Tempat</label>
                        <input type="text" name="place" id="place_edit"
                            class="w-full px-4 py-3 border rounded-md focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400 transition duration-300 text-base">
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Alamat</label>
                        <input type="text" name="address" id="address_edit"
                            class="w-full px-4 py-3 border rounded-md focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400 transition duration-300 text-base">
                    </div>

                    <!-- Footer -->
                    <div class="border-t border-gray-200 pt-4 lg:pt-6 mt-4 lg:mt-6">
                        <div class="flex flex-col sm:flex-row justify-end gap-2 sm:space-x-2 sm:gap-0">
                            <button type="button" @click="closeEditModal()"
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

        <script>
            function titikLokasiApp(kecamatans, titiklokasis) {
                const hash = parseInt(window.location.hash.substring(1));
                return {
                    kecamatans,
                    titiklokasis,
                    showMobileSidebar: false,
                    activeKecamatan: Number.isInteger(hash) && kecamatans.some(k => k.id_kecamatan === hash) ?
                        hash : (kecamatans.length ? kecamatans[0].id_kecamatan : null),

                    setActive(id) {
                        this.activeKecamatan = id;
                        window.location.hash = id;
                    },

                    toggleMobileSidebar() {
                        this.showMobileSidebar = !this.showMobileSidebar;
                    },

                    closeMobileSidebar() {
                        this.showMobileSidebar = false;
                    },

                    get filteredLokasi() {
                        return this.titiklokasis.filter(l => l.district_id === this.activeKecamatan);
                    },

                    openAddModal(districtId) {
                        this.setActive(districtId);

                        // Set action form dan district_id
                        document.getElementById('district_id_add').value = districtId;
                        document.getElementById('form-add-lokasi').action =
                            window.routeStoreLokasi.replace('__ID__', districtId);

                        // Reset input dan error
                        ['place', 'address'].forEach(f => {
                            document.getElementById(`${f}_add`).value = '';
                            document.getElementById(`${f}-error`).classList.add('hidden');
                        });

                        // Tampilkan modal
                        document.getElementById('modal-add-lokasi').classList.remove('hidden');
                        document.body.style.overflow = 'hidden'; // Prevent background scroll
                    },

                    closeAddModal() {
                        document.getElementById('modal-add-lokasi').classList.add('hidden');
                        document.body.style.overflow = 'auto'; // Restore background scroll

                        // Reset input dan error
                        ['place', 'address'].forEach(f => {
                            document.getElementById(`${f}_add`).value = '';
                            document.getElementById(`${f}-error`).classList.add('hidden');
                        });
                    },

                    validateAdd() {
                        let valid = true;
                        ['place', 'address'].forEach(f => {
                            const input = document.getElementById(`${f}_add`);
                            const err = document.getElementById(`${f}-error`);
                            if (!input.value.trim()) {
                                err.classList.remove('hidden');
                                valid = false;
                            } else {
                                err.classList.add('hidden');
                            }
                        });
                        if (!valid) return;

                        const form = document.getElementById('form-add-lokasi');
                        const data = new FormData(form);
                        fetch(form.action, {
                                method: 'POST',
                                body: data,
                                headers: {
                                    'Accept': 'application/json',
                                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute(
                                        'content')
                                }
                            })
                            .then(res => res.ok ? res.json() : Promise.reject(res))
                            .then(res => {
                                if (res.success) {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Berhasil!',
                                        text: 'Lokasi berhasil ditambahkan.',
                                        confirmButtonText: 'OK'
                                    }).then(() => {
                                        window.location.reload();
                                    });
                                }
                            })
                            .catch(err => {
                                console.error(err);
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Gagal',
                                    text: 'Gagal menambah lokasi',
                                    confirmButtonText: 'OK'
                                });
                            });
                    },

                    openEditModal(loc) {
                        document.getElementById('place_edit').value = loc.place;
                        document.getElementById('address_edit').value = loc.address;
                        document.getElementById('form-edit-lokasi').action = `/admin/titiklokasi/${loc.id}`;
                        document.getElementById('modal-edit-lokasi').classList.remove('hidden');
                        document.body.style.overflow = 'hidden'; // Prevent background scroll
                    },

                    closeEditModal() {
                        document.getElementById('modal-edit-lokasi').classList.add('hidden');
                        document.body.style.overflow = 'auto'; // Restore background scroll
                    },

                    validateEdit() {
                        const form = document.getElementById('form-edit-lokasi');
                        const data = new FormData(form);
                        data.append('_method', 'PUT');

                        fetch(form.action, {
                                method: 'POST',
                                body: data,
                                headers: {
                                    'Accept': 'application/json',
                                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute(
                                        'content')
                                }
                            })
                            .then(res => res.ok ? res.json() : Promise.reject(res))
                            .then(res => {
                                if (res.success) {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Berhasil!',
                                        text: 'Lokasi berhasil perbaharui.',
                                        confirmButtonText: 'OK'
                                    }).then(() => {
                                        window.location.reload();
                                    });
                                }
                            })
                            .catch(err => {
                                console.error(err);
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error',
                                    text: 'Gagal menambah lokasi',
                                });
                            });
                    },

                    confirmDelete(id) {
                        Swal.fire({
                            title: 'Yakin ingin menghapus?',
                            text: 'Data lokasi ini akan dihapus permanen.',
                            icon: 'warning',
                            showCancelButton: true,
                            confirmButtonColor: '#dc2626',
                            cancelButtonColor: '#6b7280',
                            confirmButtonText: 'Ya, Hapus!',
                            cancelButtonText: 'Batal'
                        }).then(result => {
                            if (!result.isConfirmed) return;

                            const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

                            fetch(`/admin/titiklokasi/${id}`, {
                                    method: 'DELETE',
                                    headers: {
                                        'Accept': 'application/json',
                                        'X-CSRF-TOKEN': token
                                    }
                                })
                                .then(async res => {
                                    const json = await res.json().catch(() => ({}));
                                    if (res.ok && json.success) {
                                        Swal.fire({
                                            icon: 'success',
                                            title: 'Berhasil!',
                                            text: 'Lokasi berhasil dihapus.',
                                            confirmButtonText: 'OK'
                                        }).then(() => {
                                            window.location.reload();
                                        });
                                    } else {
                                        const msg = json.message || 'Gagal hapus lokasi';
                                        return Promise.reject(msg);
                                    }
                                })
                                .catch(err => {
                                    console.error('Delete error:', err);
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Gagal',
                                        text: 'Gagal menambah lokasi',
                                        confirmButtonText: 'OK'
                                    });
                                });
                        });
                    }
                };
            }

            window.routeStoreLokasi = "{{ route('titiklokasi.store', ['id_kecamatan' => '__ID__']) }}";
        </script>
    @endsection