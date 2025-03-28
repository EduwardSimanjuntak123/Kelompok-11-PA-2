@extends('layouts.app')

@section('title', 'Ulasan dan Balasan')

@section('content')
<div class="container mx-auto p-6">
    <h2 class="text-3xl font-bold mb-8 text-center text-gray-800"> Ulasan Pelanggan </h2>

    <div class="bg-gray-100 shadow-xl rounded-lg p-6">
        @if(isset($Reviews) && count($Reviews) > 0)
            @foreach ($Reviews as $review)
                <div class="bg-white p-5 shadow-lg rounded-lg mb-6 transition duration-300 hover:scale-105">
                    <!-- Nama Pengguna -->
                    <h3 class="text-lg font-semibold text-blue-700">
                        {{ isset($review['customer']['name']) && $review['customer']['name'] ? $review['customer']['name'] : 'Anonymous' }}
                    </h3>

                    <!-- Rating dengan bintang penuh, setengah, dan kosong -->
                    @php
                        $rating = (float) $review['rating'];
                        $fullStars = floor($rating);
                        $halfStar = ($rating - $fullStars) >= 0.5 ? 1 : 0;
                        $emptyStars = 5 - ($fullStars + $halfStar);
                    @endphp

                    <p class="text-yellow-500 flex items-center">
                        @for ($i = 0; $i < $fullStars; $i++)
                            <i class="fas fa-star"></i>
                        @endfor

                        @if ($halfStar)
                            <i class="fas fa-star-half-alt"></i>
                        @endif

                        @for ($i = 0; $i < $emptyStars; $i++)
                            <i class="far fa-star"></i>
                        @endfor

                        <span class="ml-2 text-gray-700">{{ $review['rating'] }}/5</span>
                    </p>

                    <!-- Ulasan -->
                    <p class="text-gray-700 mt-2 italic">"{{ $review['review'] }}"</p>

                    <!-- Balasan Admin -->
                    @if (!empty($review['vendor_reply']))
                        <div class="bg-blue-100 p-4 mt-3 rounded border-l-4 border-blue-500">
                            <p class="text-sm text-blue-700"><strong>Admin:</strong> {{ $review['vendor_reply'] }}</p>
                        </div>
                    @endif

                    <!-- Form Balas Ulasan -->
                    <form action="#" method="POST" class="mt-4">
                        @csrf
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
