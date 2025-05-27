<!-- Modal Tambah Motor -->
<div id="addModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50 z-50 p-4">
    <div class="bg-white rounded-lg shadow-lg w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <!-- Header dengan background biru -->
        <div class="bg-blue-600 text-white p-4 sm:p-5 flex justify-between items-center sticky top-0 z-10">
            <h2 class="text-lg sm:text-xl font-bold">Tambah Motor</h2>
            <button type="button" onclick="closeAddModal()"
                class="text-white hover:text-blue-200 text-2xl leading-none">&times;</button>
        </div>

        <form id="addMotorForm" method="POST" action="{{ route('motor.store') }}" enctype="multipart/form-data"
            class="p-4 sm:p-6">
            @csrf
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="space-y-3">
                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Nama Motor</label>
                        <input name="name" type="text" placeholder="cth: Beat, Vario, dll.."
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                        <small class="text-red-500 text-xs error-message" data-field="name"></small>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Merek Motor</label>
                        <input name="brand" type="text" placeholder="cth: Honda, Yamaha, dll.."
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                        <small class="text-red-500 text-xs error-message" data-field="brand"></small>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Tahun</label>
                        <input name="year" type="number" placeholder="cth: 2020"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base" min="1900"
                            max="{{ date('Y') }}">
                        <small class="text-red-500 text-xs error-message" data-field="year"></small>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Tipe</label>
                        <select name="type" class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                            <option value="">-- Pilih Tipe --</option>
                            <option value="automatic">Matic</option>
                            <option value="manual">Manual</option>
                            <option value="clutch">Kopling</option>
                            <option value="vespa">Vespa</option>
                        </select>
                        <small class="text-red-500 text-xs error-message" data-field="type"></small>
                    </div>
                </div>

                <div class="space-y-3">
                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Warna</label>
                        <input name="color" type="text" placeholder="cth: Merah, Hitam, dll.."
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                        <small class="text-red-500 text-xs error-message" data-field="color"></small>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Harga</label>
                        <input name="price" type="number" placeholder="cth: 150000"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base" min="1000">
                        <small class="text-red-500 text-xs error-message" data-field="price"></small>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Plat Motor</label>
                        <input name="platmotor" type="text" placeholder="cth: B 1234 XYZ"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                        <small class="text-red-500 text-xs error-message" data-field="platmotor"></small>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Deskripsi</label>
                        <textarea name="description" rows="2" placeholder="Deskripsi singkat motor"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base"></textarea>
                        <small class="text-red-500 text-xs error-message" data-field="description"></small>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Gambar Motor</label>
                        <input name="image" type="file"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base file:mr-2 file:py-1 file:px-3 file:rounded file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
                        <small class="text-red-500 text-xs error-message" data-field="image"></small>
                    </div>
                </div>
            </div>

            <div class="flex justify-end gap-3 mt-6">
                <button type="button" onclick="closeAddModal()"
                    class="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition text-sm sm:text-base">
                    Batal
                </button>
                <button type="submit"
                    class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition text-sm sm:text-base">
                    Simpan
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Edit Motor -->
<div id="editModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50 z-50 p-4">
    <div class="bg-white rounded-lg shadow-lg w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <!-- Header dengan background biru -->
        <div class="bg-blue-600 text-white p-4 sm:p-5 flex justify-between items-center sticky top-0 z-10">
            <h2 class="text-lg sm:text-xl font-bold">Edit Motor</h2>
            <button type="button" onclick="closeEditModal()"
                class="text-white hover:text-blue-200 text-2xl leading-none">&times;</button>
        </div>

        <form id="editMotorForm" method="POST" action="" enctype="multipart/form-data" class="p-4 sm:p-6">
            @csrf
            @method('PUT')
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="space-y-3">
                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Nama Motor</label>
                        <input id="editMotorName" name="name" type="text" placeholder="cth: Beat, Vario,.."
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Merek Motor</label>
                        <input id="editMotorBrand" name="brand" type="text" placeholder="cth: Honda,.."
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Tahun</label>
                        <input id="editMotorYear" name="year" type="number" placeholder="cth: 2020"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base" min="1900"
                            max="{{ date('Y') }}">
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Tipe</label>
                        <select id="editMotortype" name="type"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                            <option value="automatic">Matic</option>
                            <option value="manual">Manual</option>
                            <option value="clutch">Kopling</option>
                            <option value="vespa">Vespa</option>
                        </select>
                    </div>
                </div>

                <div class="space-y-3">
                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Warna</label>
                        <input id="editMotorColor" name="color" type="text" placeholder="cth: Merah,.."
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Harga</label>
                        <input id="editMotorPrice" name="price" type="number" placeholder="cth: 150000"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base" min="1000">
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Plat Motor</label>
                        <input id="editMotorPlatMotor" name="platmotor" type="text" placeholder="cth: B 1234 XYZ"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Status</label>
                        <select id="editMotorStatus" name="status"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base">
                            <option value="available">Tersedia</option>
                            <option value="booked">Dibooking</option>
                            <option value="unavailable">Motor Bermasalah</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Deskripsi</label>
                        <textarea id="editMotorDescription" name="description" rows="2" placeholder="Deskripsi singkat motor"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base"></textarea>
                    </div>

                    <div>
                        <label class="block text-sm sm:text-base text-gray-700 mb-1">Gambar Motor</label>
                        <input id="editMotorImage" name="image" type="file"
                            class="w-full p-2 sm:p-3 border rounded-lg text-sm sm:text-base file:mr-2 file:py-1 file:px-3 file:rounded file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
                    </div>
                </div>
            </div>

            <div class="flex justify-end gap-3 mt-6">
                <button type="button" onclick="closeEditModal()"
                    class="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition text-sm sm:text-base">
                    Batal
                </button>
                <button type="submit"
                    class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition text-sm sm:text-base">
                    Simpan
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Hapus Motor -->
<div id="deleteModal"
    class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50 z-50 p-4">
    <div class="bg-white rounded-lg shadow-lg w-full max-w-md">
        <!-- Header dengan background biru -->
        <div class="bg-blue-600 text-white p-4 sm:p-5 flex justify-between items-center">
            <h3 class="text-lg sm:text-xl font-bold">Konfirmasi Hapus</h3>
            <button type="button" onclick="closeDeleteModal()"
                class="text-white hover:text-blue-200 text-2xl leading-none">&times;</button>
        </div>

        <div class="p-4 sm:p-6">
            <p class="mb-4 text-sm sm:text-base">Apakah Anda yakin ingin menghapus motor ini?</p>
            <form id="deleteMotorForm" method="POST" action="">
                @csrf
                @method('DELETE')
                <div class="flex justify-end gap-3">
                    <button type="button" onclick="closeDeleteModal()"
                        class="px-4 py-2 bg-gray-300 text-gray-800 rounded-lg hover:bg-gray-400 transition text-sm sm:text-base">
                        Batal
                    </button>
                    <button type="submit"
                        class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition text-sm sm:text-base">
                        Hapus
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
