<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class KecamatanController extends Controller
{
    protected $apiBaseUrl;

    public function __construct()
    {
        $this->apiBaseUrl = config('api.base_url');
    }

    public function index()
    {
        $kecamatans = [];

        try {
            $token = session('token', 'TOKEN_KAMU_DI_SINI');
            $response = Http::withToken($token)->timeout(10)->get("{$this->apiBaseUrl}/kecamatan");

            if ($response->successful()) {
                $kecamatans = $response->json();
            } else {
                Log::warning("Gagal mengambil data kecamatan. Status: {$response->status()}");
            }
        } catch (\Exception $e) {
            Log::error("Kesalahan saat mengambil data kecamatan: " . $e->getMessage());
        }

        return view('admin.kecamatan', compact('kecamatans'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_kecamatan' => 'required|string|max:255',
        ]);

        try {
            $token = session('token', 'TOKEN_KAMU_DI_SINI');
            $response = Http::withToken($token)->post("{$this->apiBaseUrl}/kecamatan", $request->only('nama_kecamatan'));

            $this->flashAlert($response->successful(), 'ditambahkan');

            // Setelah berhasil menambah data
            session()->flash('success', true);
            session()->flash('message', '');
            session()->flash('action', 'tambah'); // Untuk tambah, gunakan 'tambah'

            return redirect()->route('admin.kecamatan');
        } catch (\Exception $e) {
            Log::error("Gagal menyimpan kecamatan: " . $e->getMessage());
            $this->flashAlert(false, 'ditambahkan');
            return redirect()->route('admin.kecamatan');
        }
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_kecamatan' => 'required|string|max:255',
        ]);

        try {
            $token = session('token', 'TOKEN_KAMU_DI_SINI');
            $response = Http::withToken($token)->put("{$this->apiBaseUrl}/kecamatan/{$id}", $request->only('nama_kecamatan'));

            // Mengirimkan flash message ke session
            $this->flashAlert($response->successful(), 'diperbarui');

            // Setelah berhasil menambah data
            session()->flash('success', true);
            session()->flash('message', '');
            session()->flash('action', 'edit'); // Untuk tambah, gunakan 'tambah'

            return redirect()->route('admin.kecamatan');
        } catch (\Exception $e) {
            Log::error("Gagal update kecamatan: " . $e->getMessage());
            $this->flashAlert(false, 'diperbarui');
            return redirect()->route('admin.kecamatan');
        }
    }

    protected function flashAlert($success, $action)
    {
        if ($success) {
            session()->flash('success', "Kecamatan berhasil {$action}.");
        } else {
            session()->flash('error', "Kecamatan gagal {$action}.");
        }
    }


    public function destroy($id)
{
    try {
        $token = session('token', 'TOKEN_KAMU_DI_SINI');
        $response = Http::withToken($token)
            ->delete("{$this->apiBaseUrl}/kecamatan/{$id}");

        // Default: success atau gagal_hapus
        if ($response->successful()) {
            session()->flash('success', true);
            session()->flash('action', 'hapus');
            session()->flash('message', '');
        }
        elseif ($response->status() === 409) {
            session()->flash('success', false);
            session()->flash('action', 'gagal_hapus');
            session()->flash('message', 'Data kecamatan tidak dapat dihapus karena masih memiliki titik lokasi.');
        }
        else {
            session()->flash('success', false);
            session()->flash('action', 'gagal_hapus');
            session()->flash('message', 'Data kecamatan tidak dapat dihapus karena masih memiliki titik lokasi. ');
        }

        return redirect()->back();
    } catch (\Exception $e) {
        Log::error("Kesalahan saat menghapus kecamatan: " . $e->getMessage());
        session()->flash('success', false);
        session()->flash('action', 'gagal_hapus');
        session()->flash('message', 'Terjadi exception: gagal menghapus data kecamatan.');
        return redirect()->back();
    }
}



    public function create()
    {
        return view('kecamatan.create');
    }

}
