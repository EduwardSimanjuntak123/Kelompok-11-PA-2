@extends('layouts.app')

@section('title', 'Ulasan dan Balasan')

@section('content')
    <div class="container mx-auto p-6">
        <h2 class="text-4xl font-extrabold mb-6 text-center text-gray-800">Ulasan Pelanggan</h2>

        <div class="bg-gray-100 shadow-xl rounded-lg p-6">
            @if (isset($Reviews) && count($Reviews) > 0)
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
                            $halfStar = $rating - $fullStars >= 0.5 ? 1 : 0;
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

                        <!-- Tombol Balas yang Memicu Modal -->
                        <button type="button"
                            class="mt-3 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition duration-200"
                            onclick="openModal('modal-{{ $review['id'] }}')">
                            Balas Ulasan
                        </button>

                        <!-- Modal Balas Ulasan -->
                        <div id="modal-{{ $review['id'] }}"
                            class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden">
                            <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-md relative">
                                <h2 class="text-xl font-semibold mb-4">Balas Ulasan</h2>
                                <form action="{{ route('reviews.submitReply', ['id' => $review['id']]) }}" method="POST">
                                    @csrf
                                    {{-- @dd($review['id']) --}}
                                    <textarea name="balasan" rows="4" class="w-full border rounded p-2" placeholder="Tulis balasan..." required></textarea>
                                    <div class="mt-4 flex justify-end">
                                        <button type="button" onclick="closeModal('modal-{{ $review['id'] }}')"
                                            class="bg-gray-500 text-white px-4 py-2 rounded mr-2">
                                            Batal
                                        </button>
                                        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded">
                                            Kirim Balasan
                                        </button>
                                    </div>
                                </form>
                                <!-- Tombol Tutup Modal -->
                                <button type="button" class="absolute top-2 right-2 text-gray-600"
                                    onclick="closeModal('modal-{{ $review['id'] }}')">
                                    &times;
                                </button>
                            </div>
                        </div>
                    </div>
                @endforeach
            @else
                <div class="flex flex-col items-center justify-center text-center p-10 bg-white rounded-lg shadow-md">
                    <!-- Gambar di atas teks -->
                    <img src="{{ asset('no-reviews.jpg') }}" alt="No Reviews" class="w-40 h-40 object-contain mb-4" />

                    <h2 class="text-2xl font-semibold text-gray-700">Belum Ada Ulasan</h2>
                    <p class="text-gray-600 mt-2">Pelanggan belum memberikan ulasan untuk saat ini. Sabar ya!</p>
                </div>
            @endif

        </div>
    </div>
    <script>
        function openModal(modalId) {
            document.getElementById(modalId).classList.remove('hidden');
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.add('hidden');
        }
    </script>
@endsection
