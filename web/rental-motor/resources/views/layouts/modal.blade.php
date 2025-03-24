<!-- Modal Tambah Motor -->
<div id="addModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
    <div class="bg-white p-6 rounded-lg shadow-lg w-1/3">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Tambah Motor</h2>
        <form id="addMotorForm" method="POST" action="{{ route('motor.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="grid grid-cols-2 gap-4">
                <!-- Kolom Kiri -->
                <div>
                    <label class="block text-gray-700">Nama</label>
                    <input id="addMotorName" name="name" type="text" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Brand</label>
                    <input id="addMotorBrand" name="brand" type="text" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Model</label>
                    <input id="addMotorModel" name="model" type="text" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Tahun</label>
                    <input id="addMotorYear" name="year" type="number" class="w-full border p-2 rounded">
                </div>

                <!-- Kolom Kanan -->
                <div>
                    <label class="block text-gray-700">Warna</label>
                    <input id="addMotorColor" name="color" type="text" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Harga</label>
                    <input id="addMotorPrice" name="price" type="number" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Status</label>
                    <select id="addMotorStatus" name="status" class="w-full border p-2 rounded">
                        <option value="available">Tersedia</option>
                        <option value="booked">Dibooking</option>
                        <option value="unavailable">Bermasalah</option>
                    </select>

                    <label class="block text-gray-700 mt-2">Gambar Motor</label>
                    <input id="addMotorImage" name="image" type="file" class="w-full border p-2 rounded">
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
        <form id="editMotorForm" method="POST" action="/vendor/motor/{{ $motor['id'] }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="grid grid-cols-2 gap-4">
                <!-- Kolom Kiri -->
                <div>
                    <label class="block text-gray-700">Nama</label>
                    <input id="editMotorName" name="name" type="text" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Brand</label>
                    <input id="editMotorBrand" name="brand" type="text" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Model</label>
                    <input id="editMotorModel" name="model" type="text" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Tahun</label>
                    <input id="editMotorYear" name="year" type="number" class="w-full border p-2 rounded">
                </div>

                <!-- Kolom Kanan -->
                <div>
                    <label class="block text-gray-700">Warna</label>
                    <input id="editMotorColor" name="color" type="text" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Harga</label>
                    <input id="editMotorPrice" name="price" type="number" class="w-full border p-2 rounded">

                    <label class="block text-gray-700 mt-2">Status</label>
                    <select id="editMotorStatus" name="status" class="w-full border p-2 rounded">
                        <option value="available">Tersedia</option>
                        <option value="booked">Dibooking</option>
                        <option value="unavailable">Bermasalah</option>
                    </select>

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


<!-- Modal Hapus -->
<div id="deleteModal" class="hidden fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
    <div class="bg-white p-6 rounded-lg shadow-lg w-96">
        <h3 class="text-xl font-bold mb-4">Konfirmasi Hapus</h3>
        <p>Apakah Anda yakin ingin menghapus motor ini?</p>
        <form id="deleteMotorForm" method="POST" action="{{ route('motor.destroy', ':id') }}">
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
