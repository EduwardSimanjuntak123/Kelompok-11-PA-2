@extends('layouts.app')

@section('title', 'Ulasan dan Balasan')

@section('content')
    <div class="container mx-auto p-3 sm:p-4 lg:p-6">
        <h2 class="text-2xl sm:text-3xl lg:text-4xl font-extrabold mb-4 sm:mb-6 text-center text-gray-800">Ulasan Pelanggan</h2>

        <div class="bg-gray-100 shadow-xl rounded-lg p-3 sm:p-4 lg:p-6">
            @if (isset($Reviews) && count($Reviews) > 0)
                <div class="space-y-4 sm:space-y-6">
                    @foreach ($Reviews as $review)
                        <div class="bg-white p-3 sm:p-4 lg:p-5 shadow-lg rounded-lg transition duration-300 hover:scale-[1.02]">
                            <!-- Header Section -->
                            <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between mb-3 sm:mb-4">
                                <div class="flex-1">
                                    <!-- Nama Pengguna -->
                                    <h3 class="text-base sm:text-lg font-semibold text-blue-700 mb-2">
                                        {{ isset($review['customer']['name']) && $review['customer']['name'] ? $review['customer']['name'] : 'Anonymous' }}
                                    </h3>

                                    <!-- Rating dengan bintang -->
                                    @php
                                        $rating = (float) $review['rating'];
                                        $fullStars = floor($rating);
                                        $halfStar = $rating - $fullStars >= 0.5 ? 1 : 0;
                                        $emptyStars = 5 - ($fullStars + $halfStar);
                                    @endphp

                                    <div class="flex items-center mb-2 sm:mb-0">
                                        <div class="flex text-yellow-500 mr-2">
                                            @for ($i = 0; $i < $fullStars; $i++)
                                                <i class="fas fa-star text-sm sm:text-base"></i>
                                            @endfor

                                            @if ($halfStar)
                                                <i class="fas fa-star-half-alt text-sm sm:text-base"></i>
                                            @endif

                                            @for ($i = 0; $i < $emptyStars; $i++)
                                                <i class="far fa-star text-sm sm:text-base"></i>
                                            @endfor
                                        </div>
                                        <span class="text-gray-700 text-sm sm:text-base">{{ $review['rating'] }}/5</span>
                                    </div>
                                </div>

                                <!-- Tombol Balas - Mobile: Full width, Desktop: Auto width -->
                                <button type="button"
                                    class="w-full sm:w-auto mt-3 sm:mt-0 bg-blue-600 text-white px-3 sm:px-4 py-2 rounded-lg hover:bg-blue-700 transition duration-200 text-sm sm:text-base"
                                    onclick="openModal('modal-{{ $review['id'] }}')">
                                    <i class="fas fa-reply mr-1 sm:mr-2"></i>Balas Ulasan
                                </button>
                            </div>

                            <!-- Ulasan -->
                            <div class="mb-3 sm:mb-4">
                                <p class="text-gray-700 text-sm sm:text-base italic leading-relaxed">"{{ $review['review'] }}"</p>
                            </div>

                            <!-- Balasan Admin -->
                            @if (!empty($review['vendor_reply']))
                                <div class="bg-blue-50 border-l-4 border-blue-500 p-3 sm:p-4 rounded-r-lg">
                                    <p class="text-sm sm:text-base text-blue-700">
                                        <strong class="font-semibold">Admin:</strong> 
                                        <span class="block sm:inline mt-1 sm:mt-0">{{ $review['vendor_reply'] }}</span>
                                    </p>
                                </div>
                            @endif

                            <!-- Modal Balas Ulasan -->
                            <div id="modal-{{ $review['id'] }}"
                                class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden z-50 p-4">
                                <div class="bg-white rounded-lg shadow-lg w-full max-w-md max-h-[90vh] overflow-y-auto relative">
                                    <!-- Modal Header -->
                                    <div class="flex justify-between items-center p-4 sm:p-6 border-b">
                                        <h2 class="text-lg sm:text-xl font-semibold">Balas Ulasan</h2>
                                        <button type="button" class="text-gray-600 hover:text-gray-800 text-xl sm:text-2xl"
                                            onclick="closeModal('modal-{{ $review['id'] }}')">
                                            &times;
                                        </button>
                                    </div>

                                    <!-- Modal Body -->
                                    <div class="p-4 sm:p-6">
                                        <!-- Review Info -->
                                        <div class="mb-4 p-3 bg-gray-50 rounded-lg">
                                            <p class="text-sm text-gray-600 mb-1">Ulasan dari:</p>
                                            <p class="font-semibold text-gray-800">{{ $review['customer']['name'] ?? 'Anonymous' }}</p>
                                            <p class="text-sm text-gray-700 mt-2 italic">"{{ Str::limit($review['review'], 100) }}"</p>
                                        </div>

                                        <form action="{{ route('reviews.submitReply', ['id' => $review['id']]) }}" method="POST">
                                            @csrf
                                            <div class="mb-4">
                                                <label for="balasan-{{ $review['id'] }}" class="block text-sm font-medium text-gray-700 mb-2">
                                                    Balasan Anda:
                                                </label>
                                                <textarea 
                                                    name="balasan" 
                                                    id="balasan-{{ $review['id'] }}"
                                                    rows="4" 
                                                    class="w-full border border-gray-300 rounded-lg p-3 text-sm sm:text-base focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                                                    placeholder="Tulis balasan Anda..." 
                                                    required></textarea>
                                            </div>
                                            
                                            <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
                                                <button type="button" 
                                                    onclick="closeModal('modal-{{ $review['id'] }}')"
                                                    class="w-full sm:w-auto px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors order-2 sm:order-1">
                                                    Batal
                                                </button>
                                                <button type="submit" 
                                                    class="w-full sm:w-auto px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors order-1 sm:order-2">
                                                    Kirim Balasan
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>
            @else
                <div class="flex flex-col items-center justify-center text-center p-6 sm:p-8 lg:p-10 bg-white rounded-lg shadow-md">
                    <!-- Icon atau Gambar -->
                    <div class="mb-4">
                        <i class="fas fa-comments fa-3x sm:fa-4x text-gray-400"></i>
                    </div>

                    <h2 class="text-xl sm:text-2xl font-semibold text-gray-700 mb-2">Belum Ada Ulasan</h2>
                    <p class="text-gray-600 text-sm sm:text-base">Pelanggan belum memberikan ulasan untuk saat ini. Sabar ya!</p>
                </div>
            @endif
        </div>
    </div>

    <script>
        function openModal(modalId) {
            const modal = document.getElementById(modalId);
            modal.classList.remove('hidden');
            document.body.style.overflow = 'hidden';
            
            // Focus on textarea for better UX
            setTimeout(() => {
                const textarea = modal.querySelector('textarea');
                if (textarea) textarea.focus();
            }, 100);
        }

        function closeModal(modalId) {
            const modal = document.getElementById(modalId);
            modal.classList.add('hidden');
            document.body.style.overflow = 'auto';
            
            // Clear textarea
            const textarea = modal.querySelector('textarea');
            if (textarea) textarea.value = '';
        }

        // Close modal when clicking outside
        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('bg-black') && e.target.classList.contains('bg-opacity-50')) {
                const modals = document.querySelectorAll('[id^="modal-"]');
                modals.forEach(modal => {
                    if (!modal.classList.contains('hidden')) {
                        closeModal(modal.id);
                    }
                });
            }
        });

        // Close modal with Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                const modals = document.querySelectorAll('[id^="modal-"]');
                modals.forEach(modal => {
                    if (!modal.classList.contains('hidden')) {
                        closeModal(modal.id);
                    }
                });
            }
        });
    </script>
@endsection