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
                    <a href="{{ route('admin.nonaktif', ['id' => session('user.id')]) }}">
                        Nonaktifkan Akun Vendor
                    </a>
                </button>
            </div>
          
        </div>
    </div>
@endsection
