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


    <div x-data="titikLokasiApp({{ Js::from($kecamatans) }}, {{ Js::from($titiklokasis) }})" class="flex min-h-screen">
        <!-- Sidebar Kecamatan -->
        <aside class="w-64 bg-white border-r">
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
                                class="block w-full text-left px-4 py-2 rounded-lg hover:bg-blue-100"
                                :class="{ 'bg-blue-200': activeKecamatan === kecamatan.id_kecamatan }">
                                <span x-text="kecamatan.nama_kecamatan"></span>
                            </button>
                        </template>
                    </nav>
                </template>
            </div>
        </aside>

        <!-- Konten Utama -->
        <div class="flex-1 p-6">
            <template x-if="kecamatans.length === 0">
                <div class="flex flex-col items-center justify-center text-center p-10 bg-white rounded-lg shadow-md">
                    <div class="text-gray-400 text-5xl mb-4">
                        <i class="fas fa-map-marked-alt"></i>
                    </div>
                    <h2 class="text-2xl font-semibold text-gray-700">Tidak Ada Data Kecamatan</h2>
                    <p class="text-gray-600 mt-2">Data kecamatan belum tersedia. Silakan tambahkan data kecamatan terlebih
                        dahulu.</p>
                </div>
            </template>

            <template x-if="kecamatans.length > 0">
                <template x-for="kecamatan in kecamatans" :key="kecamatan.id_kecamatan">
                    <div x-show="activeKecamatan === kecamatan.id_kecamatan">
                        <div class="flex justify-between items-center mb-6">
                            <h1 class="text-2xl font-bold text-gray-800" x-text="kecamatan.nama_kecamatan"></h1>
                            <button @click="openAddModal(kecamatan.id_kecamatan)"
                                class="bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md">
                                Tambah Lokasi
                            </button>
                        </div>

                        <!-- Tabel Lokasi -->
                        <div class="overflow-x-auto bg-white rounded-lg shadow-lg">
                            <table class="min-w-full table-auto text-sm">
                                <thead class="bg-blue-100 text-gray-600">
                                    <tr>
                                        <th class="px-6 py-3 text-left font-medium">Nama Tempat</th>
                                        <th class="px-6 py-3 text-left font-medium">Alamat</th>
                                        <th class="px-6 py-3 text-center font-medium">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-200">
                                    <template x-if="filteredLokasi.length > 0">
                                        <template x-for="lokasi in filteredLokasi" :key="lokasi.id">
                                            <tr>
                                                <td class="px-6 py-4 text-gray-700" x-text="lokasi.place"></td>
                                                <td class="px-6 py-4 text-gray-700" x-text="lokasi.address"></td>
                                                <td class="px-6 py-4 text-center space-x-2">
                                                    <button @click="openEditModal(lokasi)"
                                                        class="bg-yellow-400 hover:bg-yellow-500 text-white py-2 px-4 rounded-lg shadow-md">
                                                        <i class="fas fa-edit"></i>
                                                    </button>
                                                    <button type="button" @click="confirmDelete(lokasi.id)"
                                                        class="bg-red-500 hover:bg-red-600 text-white py-2 px-4 rounded-lg shadow-md">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        </template>
                                    </template>

                                    <template x-if="filteredLokasi.length === 0">
                                        <tr>
                                            <td colspan="3" class="py-12">
                                                <div
                                                    class="flex flex-col items-center justify-center text-center p-6 bg-white rounded-lg">
                                                    <div class="text-gray-400 text-4xl mb-3">
                                                        <i class="fas fa-map-marker-slash"></i>
                                                    </div>
                                                    <h3 class="text-xl font-medium text-gray-700">Belum Ada Titik Lokasi
                                                    </h3>
                                                    <p class="text-gray-500 mt-1">Tidak ada titik lokasi yang tersedia untuk
                                                        kecamatan ini.</p>
                                                    <button @click="openAddModal(activeKecamatan)"
                                                        class="mt-4 bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded-lg shadow-md">
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
            class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden z-50">
            <div class="relative bg-white rounded-lg w-full max-w-md p-6">
                <button type="button" @click="closeAddModal()"
                    class="absolute top-3 right-3 text-gray-400 hover:text-gray-600">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>

                <h2 class="text-2xl font-semibold text-gray-800 mb-4">Tambah Lokasi</h2>
                <form id="form-add-lokasi" method="POST" action="" @submit.prevent="validateAdd">
                    @csrf
                    <input type="hidden" name="district_id" id="district_id_add">

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Nama Tempat</label>
                        <input type="text" name="place" id="place_add"
                            class="mt-1 w-full px-4 py-2 border rounded-md focus:ring-blue-400 focus:outline-none">
                        <div id="place-error" class="text-red-500 text-sm mt-1 hidden">Nama Tempat harus diisi!</div>
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Alamat</label>
                        <input type="text" name="address" id="address_add"
                            class="mt-1 w-full px-4 py-2 border rounded-md focus:ring-blue-400 focus:outline-none">
                        <div id="address-error" class="text-red-500 text-sm mt-1 hidden">Alamat harus diisi!</div>
                    </div>

                    <div class="flex justify-end space-x-2">
                        <button type="button" @click="closeAddModal()"
                            class="px-4 py-2 bg-gray-300 hover:bg-gray-400 text-gray-800 font-semibold rounded-md">
                            Batal
                        </button>
                        <button type="submit"
                            class="px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white font-semibold rounded-md">
                            Simpan
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Modal Edit Lokasi -->
        <div id="modal-edit-lokasi"
            class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden z-50">
            <div class="relative bg-white rounded-lg w-full max-w-md p-6">
                <button type="button" @click="closeEditModal()"
                    class="absolute top-3 right-3 text-gray-400 hover:text-gray-600">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>

                <h2 class="text-2xl font-semibold text-gray-800 mb-4">Edit Lokasi</h2>
                <form id="form-edit-lokasi" method="POST" action="" @submit.prevent="validateEdit">
                    @csrf
                    @method('PUT')

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Nama Tempat</label>
                        <input type="text" name="place" id="place_edit"
                            class="mt-1 w-full px-4 py-2 border rounded-md focus:ring-yellow-400 focus:outline-none">
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Alamat</label>
                        <input type="text" name="address" id="address_edit"
                            class="mt-1 w-full px-4 py-2 border rounded-md focus:ring-yellow-400 focus:outline-none">
                    </div>

                    <div class="flex justify-end space-x-2">
                        <button type="button" @click="closeEditModal()"
                            class="px-4 py-2 bg-gray-300 hover:bg-gray-400 text-gray-800 font-semibold rounded-md">
                            Batal
                        </button>
                        <button type="submit"
                            class="px-4 py-2 bg-yellow-400 hover:bg-yellow-500 text-white font-semibold rounded-md">
                            Update
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function titikLokasiApp(kecamatans, titiklokasis) {
            const hash = parseInt(window.location.hash.substring(1));
            return {
                kecamatans,
                titiklokasis,
                activeKecamatan: Number.isInteger(hash) && kecamatans.some(k => k.id_kecamatan === hash) ?
                    hash : (kecamatans.length ? kecamatans[0].id_kecamatan : null),

                setActive(id) {
                    this.activeKecamatan = id;
                    window.location.hash = id;
                },

                get filteredLokasi() {
                    return this.titiklokasis.filter(l => l.district_id === this.activeKecamatan);
                },

                openAddModal(districtId) {
                    this.setActive(districtId);
                    document.getElementById('district_id_add').value = districtId;
                    document.getElementById('form-add-lokasi').action =
                        window.routeStoreLokasi.replace('__ID__', districtId);
                    document.getElementById('modal-add-lokasi').classList.remove('hidden');
                },

                closeAddModal() {
                    document.getElementById('modal-add-lokasi').classList.add('hidden');
                    ['place', 'address'].forEach(f => {
                        document.getElementById(`${f}-error`).classList.add('hidden');
                        document.getElementById(`${f}_add`).value = '';
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
                },

                closeEditModal() {
                    document.getElementById('modal-edit-lokasi').classList.add('hidden');
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
