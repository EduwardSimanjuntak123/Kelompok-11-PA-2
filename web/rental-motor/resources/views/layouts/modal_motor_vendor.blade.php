<!-- Modal Tambah Motor -->
<div id="addModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
    <div class="bg-white p-6 rounded-lg shadow-lg w-1/3">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Tambah Motor</h2>
        <form id="addMotorForm" method="POST" action="{{ route('motor.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-gray-700">Nama Motor</label>
                    <input name="name" type="text" placeholder="cth: Beat, Vario, dll.."
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                    <small class="text-red-500 text-sm error-message" data-field="name"></small>

                    <label class="block text-gray-700 mt-2">Merek Motor</label>
                    <input name="brand" type="text" placeholder="cth: Honda, Yamaha, dll.."
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                    <small class="text-red-500 text-sm error-message" data-field="brand"></small>

                    <label class="block text-gray-700 mt-2">Tahun</label>
                    <input name="year" type="number" placeholder="cth: 2020"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500" min="1900"
                        max="{{ date('Y') }}">
                    <small class="text-red-500 text-sm error-message" data-field="year"></small>

                    <label class="block text-gray-700 mt-2">Tipe</label>
                    <select name="type" class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                        <option value="">-- Pilih Tipe --</option>
                        <option value="matic">Matic</option>
                        <option value="manual">Manual</option>
                        <option value="kopling">Kopling</option>
                        <option value="vespa">Vespa</option>
                    </select>
                    <small class="text-red-500 text-sm error-message" data-field="type"></small>
                </div>

                <div>
                    <label class="block text-gray-700">Warna</label>
                    <input name="color" type="text" placeholder="cth: Merah, Hitam, dll.."
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                    <small class="text-red-500 text-sm error-message" data-field="color"></small>

                    <label class="block text-gray-700 mt-2">Harga</label>
                    <input name="price" type="number" placeholder="cth: 150000"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500" min="1000">
                    <small class="text-red-500 text-sm error-message" data-field="price"></small>

                    <label class="block text-gray-700 mt-2">Plat Motor</label>
                    <input name="platmotor" type="text" placeholder="cth: B 1234 XYZ"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                    <small class="text-red-500 text-sm error-message" data-field="platmotor"></small>

                    <label class="block text-gray-700 mt-2">Deskripsi</label>
                    <textarea name="description" rows="3" placeholder="Deskripsi singkat motor"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500"></textarea>
                    <small class="text-red-500 text-sm error-message" data-field="description"></small>

                    <label class="block text-gray-700 mt-2">Gambar Motor</label>
                    <input name="image" type="file"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                    <small class="text-red-500 text-sm error-message" data-field="image"></small>
                </div>
            </div>

            <div class="flex justify-end gap-2 mt-4">
                <button type="button" onclick="closeAddModal()"
                    class="px-4 py-2 bg-gray-500 text-white rounded">Batal</button>
                <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded">Simpan</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Edit Motor -->
<div id="editModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
    <div class="bg-white p-6 rounded-lg shadow-lg w-1/3">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Edit Motor</h2>
        <form id="editMotorForm" method="POST" action="" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-gray-700">Nama Motor</label>
                    <input id="editMotorName" name="name" type="text" placeholder="cth: Beat, Vario,.."
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">

                    <label class="block text-gray-700 mt-2">Merek Motor</label>
                    <input id="editMotorBrand" name="brand" type="text" placeholder="cth: Honda,.."
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">

                    <label class="block text-gray-700 mt-2">Tahun</label>
                    <input id="editMotorYear" name="year" type="number" placeholder="cth: 2020"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500" min="1900"
                        max="{{ date('Y') }}">

                    <label class="block text-gray-700 mt-2">Tipe</label>
                    <select id="editMotortype" name="type"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                        <option value="matic">Matic</option>
                        <option value="manual">Manual</option>
                        <option value="kopling">Kopling</option>
                        <option value="vespa">Vespa</option>
                    </select>
                </div>

                <div>
                    <label class="block text-gray-700">Warna</label>
                    <input id="editMotorColor" name="color" type="text" placeholder="cth: Merah,.."
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">

                    <label class="block text-gray-700 mt-2">Harga</label>
                    <input id="editMotorPrice" name="price" type="number" placeholder="cth: 150000"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500" min="1000">

                    <label class="block text-gray-700 mt-2">Plat Motor</label>
                    <input id="editMotorPlatMotor" name="platmotor" type="text" placeholder="cth: B 1234 XYZ"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">

                    <label class="block text-gray-700 mt-2">Status</label>
                    <select id="editMotorStatus" name="status"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                        <option value="available">Tersedia</option>
                        <option value="booked">Dibooking</option>
                        <option value="unavailable">Motor Bermasalah</option>
                    </select>

                    <label class="block text-gray-700 mt-2">Deskripsi</label>
                    <textarea id="editMotorDescription" name="description" rows="3" placeholder="Deskripsi singkat motor"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500"></textarea>

                    <label class="block text-gray-700 mt-2">Gambar Motor</label>
                    <input id="editMotorImage" name="image" type="file"
                        class="w-full border p-2 rounded placeholder:text-sm placeholder-gray-500">
                </div>
            </div>

            <div class="flex justify-end gap-2 mt-4">
                <button type="button" onclick="closeEditModal()"
                    class="px-4 py-2 bg-gray-500 text-white rounded">Batal</button>
                <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded">Simpan</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Hapus Motor -->
<div id="deleteModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
    <div class="bg-white p-6 rounded-lg shadow-lg w-96">
        <h3 class="text-xl font-bold mb-4">Konfirmasi Hapus</h3>
        <p>Apakah Anda yakin ingin menghapus motor ini?</p>
        <form id="deleteMotorForm" method="POST" action="">
            @csrf
            @method('DELETE')
            <div class="flex justify-end mt-4">
                <button type="button" onclick="closeDeleteModal()"
                    class="px-4 py-2 bg-gray-300 rounded mr-2">Batal</button>
                <button type="submit" class="px-4 py-2 bg-red-500 text-white rounded">Hapus</button>
            </div>
        </form>
    </div>
</div>
