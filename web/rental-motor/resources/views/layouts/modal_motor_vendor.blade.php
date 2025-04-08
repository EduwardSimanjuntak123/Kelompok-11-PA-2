<!-- Modal Tambah Motor (rating dihapus) -->
<div id="addModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
    <div class="bg-white p-6 rounded-lg shadow-lg w-1/3">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Tambah Motor</h2>
        <form id="addMotorForm" method="POST" action="{{ route('motor.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-gray-700">Nama</label>
                    <input name="name" type="text" class="w-full border p-2 rounded" required autofocus>

                    <label class="block text-gray-700 mt-2">Brand</label>
                    <input name="brand" type="text" class="w-full border p-2 rounded" required>

                    <label class="block text-gray-700 mt-2">Model</label>
                    <input name="model" type="text" class="w-full border p-2 rounded" required>

                    <label class="block text-gray-700 mt-2">Tahun</label>
                    <input name="year" type="number" class="w-full border p-2 rounded" min="1900"
                        max="{{ date('Y') }}" required>

                    <label class="block text-gray-700 mt-2">Tipe</label>
                    <input name="type" type="text" class="w-full border p-2 rounded" required>
                </div>

                <div>
                    <label class="block text-gray-700">Warna</label>
                    <input name="color" type="text" class="w-full border p-2 rounded" required>

                    <label class="block text-gray-700 mt-2">Harga</label>
                    <input name="price" type="number" class="w-full border p-2 rounded" min="1000" required>

                    <label class="block text-gray-700 mt-2">Status</label>
                    <select name="status" class="w-full border p-2 rounded" required>
                        <option value="available">Tersedia</option>
                        <option value="booked">Dibooking</option>
                        <option value="unavailable">Bermasalah</option>
                    </select>

                    <label class="block text-gray-700 mt-2">Deskripsi</label>
                    <textarea name="description" rows="3" class="w-full border p-2 rounded" required></textarea>

                    <label class="block text-gray-700 mt-2">Gambar Motor</label>
                    <input name="image" type="file" class="w-full border p-2 rounded">
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

<!-- Modal Edit Motor (rating dihapus) -->
<div id="editModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
    <div class="bg-white p-6 rounded-lg shadow-lg w-1/3">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Edit Motor</h2>
        <form id="editMotorForm" method="POST" action="" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-gray-700">Nama</label>
                    <input id="editMotorName" name="name" type="text" class="w-full border p-2 rounded" required>

                    <label class="block text-gray-700 mt-2">Brand</label>
                    <input id="editMotorBrand" name="brand" type="text" class="w-full border p-2 rounded" required>

                    <label class="block text-gray-700 mt-2">Model</label>
                    <input id="editMotorModel" name="model" type="text" class="w-full border p-2 rounded" required>

                    <label class="block text-gray-700 mt-2">Tahun</label>
                    <input id="editMotorYear" name="year" type="number" class="w-full border p-2 rounded"
                        min="1900" max="{{ date('Y') }}" required>

                    <label class="block text-gray-700 mt-2">Tipe</label>
                    <input id="editMotorType" name="type" type="text" class="w-full border p-2 rounded" required>
                </div>

                <div>
                    <label class="block text-gray-700">Warna</label>
                    <input id="editMotorColor" name="color" type="text" class="w-full border p-2 rounded"
                        required>

                    <label class="block text-gray-700 mt-2">Harga</label>
                    <input id="editMotorPrice" name="price" type="number" class="w-full border p-2 rounded"
                        min="1000" required>

                    <label class="block text-gray-700 mt-2">Status</label>
                    <select id="editMotorStatus" name="status" class="w-full border p-2 rounded" required>
                        <option value="available">Tersedia</option>
                        <option value="booked">Dibooking</option>
                        <option value="unavailable">Bermasalah</option>
                    </select>

                    <label class="block text-gray-700 mt-2">Deskripsi</label>
                    <textarea id="editMotorDescription" name="description" rows="3" class="w-full border p-2 rounded" required></textarea>

                    <label class="block text-gray-700 mt-2">Gambar Motor</label>
                    <input id="editMotorImage" name="image" type="file" class="w-full border p-2 rounded">
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
