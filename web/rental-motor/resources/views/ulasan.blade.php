@extends('layouts.app')

@section('title', 'Ulasan dan Balasan')

@section('content')
<div class="container mx-auto p-6">
    <h2 class="text-3xl font-bold mb-8 text-center text-gray-800"> Ulasan Pelanggan </h2>

    <div class="bg-gray-100 shadow-xl rounded-lg p-6">
        @php
            // Data ulasan statis (tanpa database)
            $ulasan = [
                ['nama' => 'Budi Santoso', 'rating' => 5, 'komentar' => 'Pelayanan sangat baik!', 'balasan' => 'Terima kasih atas ulasannya!'],
                ['nama' => 'Ani Wijaya', 'rating' => 4, 'komentar' => 'Motor dalam kondisi bagus.', 'balasan' => null],
                ['nama' => 'Joko Susilo', 'rating' => 3, 'komentar' => 'Harap lebih cepat dalam merespons.', 'balasan' => 'Baik, kami akan meningkatkan pelayanan.'],
            ];
        @endphp

        @if(count($ulasan) > 0)
            @foreach ($ulasan as $review)
                <div class="bg-white p-5 shadow-lg rounded-lg mb-6 transition duration-300 hover:scale-105">
                    <!-- Nama Pengguna -->
                    <h3 class="text-lg font-semibold text-blue-700">{{ $review['nama'] }}</h3>

                    <!-- Rating -->
                    <p class="text-yellow-500 flex items-center">
                        @for ($i = 0; $i < $review['rating']; $i++)
                            ⭐
                        @endfor
                        <span class="ml-2 text-gray-700">{{ $review['rating'] }}/5</span>
                    </p>

                    <!-- Ulasan -->
                    <p class="text-gray-700 mt-2 italic">"{{ $review['komentar'] }}"</p>

                    <!-- Balasan Admin -->
                    @if ($review['balasan'])
                        <div class="bg-blue-100 p-4 mt-3 rounded border-l-4 border-blue-500">
                            <p class="text-sm text-blue-700"><strong>Admin:</strong> {{ $review['balasan'] }}</p>
                        </div>
                    @endif

                    <!-- Form Balas Ulasan -->
                    <form action="#" method="POST" class="mt-4">
                        <label class="block text-sm font-medium text-gray-700">Balas Ulasan:</label>
                        <textarea
                            name="balasan"
                            class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent"
                            rows="2"
                            placeholder="Tulis balasan..."
                            required
                        ></textarea>
                        <button type="submit" class="mt-3 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition duration-200">
                            Kirim Balasan (Tidak disimpan)
                        </button>
                    </form>
                </div>
            @endforeach
        @else
            <p class="text-gray-600 text-center text-lg font-medium">Belum ada ulasan dari pelanggan.</p>
        @endif
    </div>
</div>
@endsection
