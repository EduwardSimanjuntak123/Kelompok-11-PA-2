@extends('layouts.app')

@section('title', 'Dashboard Admin')

@section('content')
<div class="bg-white shadow-lg rounded-lg p-6">
    <h2 class="text-xl font-bold mb-4">Dashboard Admin</h2>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Menonaktifkan Vendor -->
        <div class="bg-red-100 p-4 rounded-lg shadow-md transform transition duration-300 hover:scale-102">
            <h3 class="font-semibold mb-2">Kelola Vendor</h3>
            <button class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">
                <a href="{{ route('nonaktif') }}">
                Nonaktifkan Akun Vendor
                </a>
            </button>
        </div>

        <!-- Melihat Ulasan -->
        <div class="bg-blue-100 p-4 rounded-lg shadow-md transform transition duration-300 hover:scale-102">
            <h3 class="font-semibold mb-2">Ulasan & Rating</h3>
            <button class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                <a href="{{ route('ulasan') }}">
                    Lihat & Tanggapi Ulasan
                </a>
            </button>
        </div>
    </div>
</div>
@endsection
