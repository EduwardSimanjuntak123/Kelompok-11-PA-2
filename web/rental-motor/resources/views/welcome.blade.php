<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MOTORENT - Rental Motor</title>

    <!-- Favicon Basic -->
    <link rel="icon" href="/logo2.png" type="image/png">

    <!-- Untuk browser modern -->
    <link rel="icon" type="image/png" sizes="32x32" href="/logo1.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/logo1.png">
    <link rel="apple-touch-icon" href="/logo1.png">

    <!-- Fallback untuk berbagai browser -->
    <link rel="shortcut icon" href="/logo1.png">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet">
    <!-- Swiper CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css" />

    <!-- Swiper JS -->
    <script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>

    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        html,
        body {
            overflow-x: hidden;
            scroll-behavior: smooth;
        }

        /* Responsive scroll-snap only for desktop */
        @media (min-width: 768px) {

            html,
            body {
                scroll-snap-type: y mandatory;
                overflow-y: scroll;
                height: 100vh;
            }

            .section {
                scroll-snap-align: start;
                height: 100vh;
            }
        }

        /* Mobile menu animation */
        #mobile-menu {
            transition: all 0.3s ease;
        }
    </style>
</head>

<body>
    <!-- Header -->
    <header
        class="bg-white shadow-md py-4 px-4 sm:px-6 flex justify-between items-center fixed top-0 left-0 w-full z-50">
        <div class="flex items-center">
            <img src="{{ asset('logo2.png') }}" alt="Motorrent Logo" class="w-20 md:w-24">
        </div>

        <!-- Mobile Menu Button -->
        <button id="mobile-menu-button" class="md:hidden text-gray-700 focus:outline-none">
            <i class="fas fa-bars text-xl"></i>
        </button>

        <!-- Desktop Navigation -->
        <nav class="hidden md:block">
            <ul class="flex space-x-4 lg:space-x-6 text-gray-700">
                <li><a href="#home" class="hover:text-orange-500 font-medium">Beranda</a></li>
                <li><a href="#testimoni" class="hover:text-orange-500 font-medium">Ulasan Pengguna</a></li>
                <li><a href="#frame-section" class="hover:text-orange-500 font-medium">Sewa Motor</a></li>
                <li><a href="#footer" class="hover:text-orange-500 font-medium">Tentang Kami</a></li>
            </ul>
        </nav>

        <!-- Mobile Navigation (hidden by default) -->
        <div id="mobile-menu" class="hidden absolute top-16 left-0 right-0 bg-white shadow-lg py-4 px-6">
            <ul class="flex flex-col space-y-4 text-gray-700">
                <li><a href="#home" class="hover:text-orange-500 font-medium block">Beranda</a></li>
                <li><a href="#testimoni" class="hover:text-orange-500 font-medium block">Ulasan Pengguna</a></li>
                <li><a href="#frame-section" class="hover:text-orange-500 font-medium block">Sewa Motor</a></li>
                <li><a href="#footer" class="hover:text-orange-500 font-medium block">Tentang Kami</a></li>
                <li>
                    <a href="{{ url('/login') }}"
                        class="bg-orange-400 text-white px-4 py-2 rounded-lg hover:bg-orange-300 transition flex items-center justify-center">
                        <i class="fas fa-sign-in-alt mr-2"></i>
                        Login
                    </a>
                </li>
            </ul>
        </div>

        <div class="hidden md:flex items-center">
            <a href="{{ url('/login') }}"
                class="bg-orange-400 text-white px-4 py-2 rounded-lg hover:bg-orange-300 transition flex items-center">
                <i class="fas fa-sign-in-alt mr-2"></i>
                Login
            </a>
        </div>
    </header>

    <!-- Halaman 1: Hero Section -->

    <body
        style="background-image: url('{{ asset('back1.jpg') }}'); background-size: cover; background-position: center; background-repeat: no-repeat; background-attachment: fixed;">
        <section id="home"
            class="container mx-auto flex flex-col md:flex-row items-center justify-between pt-32 pb-16 md:py-28 px-4 md:px-10">
            <!-- Text -->
            <div class="md:w-1/2 text-center md:text-left text-black mb-10 md:mb-0">
                <h1 class="text-3xl md:text-[2.5rem] font-bold leading-tight">
                    Nikmati Perjalanan di Toba,<br>
                    Bersama Motor Pilihanmu!
                </h1>
                <p class="mt-3 text-black-300 text-base md:text-lg">Perpanjang Sewa Kapan Saja dengan Mudah</p>

                <!-- App Store & Google Play Buttons -->
                <div
                    class="mt-6 flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 justify-center md:justify-start">
                    <!-- App Store -->
                    <div
                        class="flex items-center justify-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg"
                            alt="Apple Logo" class="w-6 h-6 mr-2">
                        <div>
                            <p class="text-xs text-gray-500">Tersedia di</p>
                            <p class="text-lg font-semibold text-black">App Store</p>
                        </div>
                    </div>

                    <!-- Google Play -->
                    <div
                        class="flex items-center justify-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg"
                            alt="Google Play Logo" class="w-6 h-6 mr-2">
                        <div>
                            <p class="text-xs text-gray-500">Tersedia di</p>
                            <p class="text-lg font-semibold text-black">Google Play</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Gambar Motor -->
            <div class="md:w-1/2 flex justify-center">
                <img src="{{ asset('traced-motor.png') }}" alt="Motorcycle"
                    class="w-full max-w-md md:w-3/4 drop-shadow-lg">
            </div>
        </section>

        <!-- Halaman 2: Fitur Rental -->
        <section id="features" class="flex items-center justify-center bg-white py-12 md:py-16">
            <div class="flex flex-col md:flex-row items-center max-w-6xl px-4 md:px-8">
                <!-- Gambar Motor -->
                <div class="w-full md:w-1/2 flex justify-center mb-10 md:mb-0">
                    <img src="{{ asset('traced-motor2.png') }}" alt="Motorcycle"
                        class="w-full max-w-xs md:max-w-none md:w-[95%] lg:w-full drop-shadow-lg">
                </div>

                <!-- Teks & Fitur -->
                <div class="w-full md:w-1/2 md:pl-6 lg:pl-12">
                    <h2 class="text-3xl md:text-4xl font-bold text-gray-1100 leading-snug">
                        Sewa motor <span class="text-green-900">lebih mudah dan cepat.</span> Coba sekarang!
                    </h2>
                    <div class="mt-6 md:mt-8 space-y-6">
                        <!-- Fitur 1 -->
                        <div class="flex items-start space-x-4 md:space-x-5">
                            <div class="bg-orange-400 text-white p-3 md:p-4 rounded-full text-lg md:text-xl">
                                🔍
                            </div>
                            <div>
                                <h3 class="font-bold text-gray-1000 text-base md:text-lg">Beragam Pilihan Motor</h3>
                                <p class="text-gray-800 text-sm md:text-base">
                                    Cari dan bandingkan berbagai jenis motor dari banyak vendor rental yang tersedia di
                                    Kabupaten Toba.
                                </p>
                            </div>
                        </div>

                        <!-- Fitur 2 -->
                        <div class="flex items-start space-x-4 md:space-x-5">
                            <div class="bg-orange-400 text-white p-3 md:p-4 rounded-full text-lg md:text-xl">
                                📱
                            </div>
                            <div>
                                <h3 class="font-bold text-gray-1000 text-base md:text-lg">Pemesanan Mudah & Aman</h3>
                                <p class="text-gray-800 text-sm md:text-base">
                                    Pesan motor langsung melalui aplikasi dengan sistem verifikasi identitas untuk
                                    keamanan
                                    penyewaan.
                                </p>
                            </div>
                        </div>

                        <!-- Fitur 3 -->
                        <div class="flex items-start space-x-4 md:space-x-5">
                            <div class="bg-orange-400 text-white p-3 md:p-4 rounded-full text-lg md:text-xl">
                                💬
                            </div>
                            <div>
                                <h3 class="font-bold text-gray-1000 text-base md:text-lg">Layanan Pelanggan Responsif
                                </h3>
                                <p class="text-gray-800 text-sm md:text-base">
                                    Komunikasikan langsung dengan penyedia rental melalui fitur mini chat untuk
                                    negosiasi
                                    dan janji temu.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section id="pick-motor"
            class="relative flex flex-col items-center justify-center min-h-screen px-4 md:px-12 bg-cover bg-center"
            style="background-image: url('{{ asset('rentsection.png') }}');">

            <!-- Judul -->
            <h2
                class="absolute top-16 md:top-10 left-1/2 transform -translate-x-1/2 text-2xl md:text-4xl font-bold text-white drop-shadow-lg text-center w-full px-4">
                Pilih Motor Anda
            </h2>

            <!-- Swiper Slider -->
            <div class="swiper w-full max-w-5xl mt-24 md:mt-28 px-4">
                <div class="swiper-wrapper">
                    <!-- Slide Motor -->
                    @foreach (['m1.png', 'm2.png', 'm3.png', 'scopp.png'] as $img)
                        <div class="swiper-slide swiper-slide-custom flex justify-center">
                            <img src="{{ asset($img) }}" alt="Motor"
                                class="w-4/5 md:w-3/5 object-contain transition-transform duration-300 hover:scale-105" />
                        </div>
                    @endforeach
                </div>
                <div class="swiper-pagination mt-6"></div>
            </div>

            <!-- Spesifikasi Motor -->
            <div
                class="flex flex-wrap justify-center gap-4 md:gap-10 text-white text-center text-sm md:text-base font-medium mt-8 md:mt-12 bg-black/40 rounded-xl px-4 py-4 md:px-6 md:py-6 backdrop-blur-md mx-4">
                <!-- Speed -->
                <div class="flex flex-col items-center px-2">
                    <svg class="h-6 w-6 md:h-8 md:w-8 mb-1 md:mb-2" fill="none" stroke="currentColor"
                        stroke-width="2" viewBox="0 0 24 24">
                        <path d="M12 16v.01" />
                        <path d="M10 12a2 2 0 1 1 4 0m-4 0a2 2 0 0 0 4 0" />
                        <path d="M12 4a8 8 0 1 0 8 8" />
                        <path d="M16 12l2.5 -2.5" />
                    </svg>
                    <p>100 km/jam</p>
                </div>

                <!-- Seat -->
                <div class="flex flex-col items-center px-2">
                    <svg class="h-6 w-6 md:h-8 md:w-8 mb-1 md:mb-2" fill="none" stroke="currentColor"
                        stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M17 20h5v-2a3 3 0 00-5.356-1.857M9 20H4v-2a3 3 0 015.356-1.857M15 11a4 4 0 10-8 0 4 4 0 008 0zm6 0a4 4 0 11-8 0 4 4 0 018 0z" />
                    </svg>
                    <p>2 Kursi</p>
                </div>

                <!-- Fuel -->
                <div class="flex flex-col items-center px-2">
                    <svg class="h-6 w-6 md:h-8 md:w-8 mb-1 md:mb-2" fill="none" stroke="currentColor"
                        stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M9.75 3v4.5m0 0a2.25 2.25 0 004.5 0V3m-4.5 4.5H8.25A2.25 2.25 0 006 9.75v8.25A2.25 2.25 0 008.25 20.25h7.5A2.25 2.25 0 0018 18V9.75a2.25 2.25 0 00-2.25-2.25H14.25" />
                    </svg>
                    <p>20 Liter</p>
                </div>
            </div>

            <!-- Harga (Fleksibel) -->
            <div
                class="flex bg-white shadow-sm rounded-full px-4 md:px-8 py-2 md:py-3 items-center border-2 border-green-400 mt-4 md:mt-6 mx-4">
                <span class="text-green-700 font-bold text-sm md:text-base">
                    <span class="text-green-600">✓</span> Harga Kompetitif
                    <span class="text-gray-600 text-xs md:text-sm font-normal"> & tanpa biaya tersembunyi</span>
                </span>
            </div>
        </section>

        <!-- Halaman 4: Testimoni Pelanggan -->
        <section id="testimoni"
            class="flex flex-col items-center justify-center min-h-screen px-4 md:px-10 py-12 md:py-16 bg-cover bg-center"
            style="background-image: url('{{ asset('back2.jpg') }}');">

            <div class="max-w-7xl w-full flex flex-col md:flex-row justify-between items-center">
                <!-- Bagian Kiri: Testimoni -->
                <div class="w-full md:w-1/2 mb-10 md:mb-0">
                    <h2 class="text-3xl md:text-4xl font-bold text-gray-900 text-center md:text-left">Apa Kata Mereka
                    </h2>
                    <p class="text-gray-500 text-base md:text-lg mt-2 text-center md:text-left">Pendapat pelanggan kami
                        tentang layanan MotoRent</p>

                    <div class="bg-white rounded-lg shadow-lg p-6 mt-6 w-full max-w-md mx-auto md:mx-0 md:w-[450px]">
                        <p class="italic text-gray-700 text-sm md:text-base">
                            MotoRent membuat jalan-jalan di kota jadi bebas stres! Motornya cocok banget untuk jalanan
                            sempit,
                            dan irit bensin juga. Pelayanannya luar biasa, dan proses pengembaliannya cepat tanpa ribet.
                            Dua jempol! 👍👍
                        </p>
                        <div class="mt-4">
                            <h3 class="font-bold text-gray-1000 text-base md:text-lg">Kelompok 11</h3>
                            <p class="text-gray-500 text-sm md:text-base">Pencinta Jelajah Kota</p>
                        </div>
                    </div>
                </div>

                <!-- Bagian Kanan: Foto Pelanggan -->
                <div class="w-full md:w-1/2 flex justify-center relative">
                    <div class="relative w-48 h-48 md:w-64 md:h-64 flex items-center justify-center">
                        <div class="w-full h-full rounded-full overflow-hidden shadow-xl border-4 border-white">
                            <img src="11.jpg" alt="Customer Utama" class="w-full h-full object-cover">
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Halaman 5: Gambar frame2.png dengan Latar Putih -->
        <section id="frame-section"
            class="h-auto md:h-screen flex items-center justify-center bg-white py-12 md:py-0">
            <div
                class="w-full md:w-[80%] h-auto md:h-[500px] flex flex-col md:flex-row items-center justify-center relative px-4 md:px-0">
                <!-- Gambar latar -->
                <img src="{{ asset('frame2.png') }}" alt="Frame 2" class="hidden md:block max-w-full max-h-full">

                <!-- Bagian teks dan tombol download -->
                <div class="md:absolute md:left-12 text-center md:text-left text-black md:text-white mb-8 md:mb-0">
                    <h2 class="text-2xl md:text-4xl font-bold mb-4">
                        Unduh <span class="text-black md:text-white">motoRent</span> <span
                            class="text-yellow-400">GRATIS</span>
                    </h2>
                    <p class="text-sm md:text-lg mb-6">Untuk pemesanan lebih cepat, mudah, dan penawaran eksklusif</p>
                    <!-- App Store & Google Play Buttons -->
                    <div
                        class="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 justify-center md:justify-start">
                        <!-- App Store -->
                        <div
                            class="flex items-center justify-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg"
                                alt="Apple Logo" class="w-6 h-6 mr-2">
                            <div>
                                <p class="text-xs text-gray-500">Tersedia di</p>
                                <p class="text-lg font-semibold text-black">App Store</p>
                            </div>
                        </div>

                        <!-- Google Play -->
                        <div
                            class="flex items-center justify-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg"
                                alt="Google Play Logo" class="w-6 h-6 mr-2">
                            <div>
                                <p class="text-xs text-gray-500">Tersedia di</p>
                                <p class="text-lg font-semibold text-black">Google Play</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Gambar mobile -->
                <img src="{{ asset('frame1.png') }}" alt="Mobile App Preview"
                    class="h-64 md:h-[500px] mt-8 md:mt-0 md:absolute md:right-10">
            </div>
        </section>

        <!-- footer-->
        <footer id="footer" class="bg-white py-8 md:py-10 px-4 md:px-10 border-t border-gray-200">
            <div
                class="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-start space-y-8 md:space-y-0">

                <!-- Logo dan Tagline -->
                <div class="w-full md:w-1/3 text-center md:text-left">
                    <h1 class="text-2xl md:text-3xl font-bold">
                        <span class="text-green-700">MO</span><span class="text-yellow-500">TO</span><span
                            class="text-green-700">RENT</span>
                    </h1>
                    <p class="text-green-700 mt-2 text-sm md:text-base">Sewa Motor Praktis & Terpercaya</p>
                </div>

                <!-- Navigasi -->
                <div class="w-full md:w-1/3 text-center md:text-left">
                    <h3 class="font-semibold text-base md:text-lg text-gray-700">Navigasi</h3>
                    <ul class="mt-2 space-y-1 md:space-y-2 text-gray-600">
                        <li><a href="#home" class="hover:text-green-600 transition text-sm md:text-base">Beranda</a>
                        </li>
                        <li><a href="#testimoni" class="hover:text-green-600 transition text-sm md:text-base">Ulasan
                                Pengguna</a></li>
                        <li><a href="#frame-section" class="hover:text-green-600 transition text-sm md:text-base">Sewa
                                Motor</a></li>
                        <li><a href="#footer" class="hover:text-green-600 transition text-sm md:text-base">Tentang
                                Kami</a></li>
                    </ul>
                </div>

                <!-- Kontak & Sosial Media -->
                <div class="w-full md:w-1/3 text-center md:text-left">
                    <h3 class="font-semibold text-base md:text-lg text-gray-700">Hubungi Kami</h3>
                    <p class="text-gray-600 mt-2 text-sm md:text-base">Email: info@motoRent.id</p>
                    <p class="text-gray-600 text-sm md:text-base">Telepon: +62 812-3456-7890</p>
                    <div class="flex justify-center md:justify-start space-x-4 mt-3 md:mt-4">
                        <a href="https://www.instagram.com/" target="_blank">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png"
                                alt="Instagram" class="h-5 md:h-6">
                        </a>
                        <a href="https://www.tiktok.com/" target="_blank">
                            <img src="https://upload.wikimedia.org/wikipedia/en/a/a9/TikTok_logo.svg" alt="TikTok"
                                class="h-5 md:h-6">
                        </a>
                        <a href="https://www.facebook.com/" target="_blank">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg"
                                alt="Facebook" class="h-5 md:h-6">
                        </a>
                    </div>
                </div>
            </div>

            <!-- Copyright -->
            <div class="text-center text-gray-500 text-xs md:text-sm mt-8 md:mt-10">
                ©2025 MotoRent. Semua Hak Dilindungi
            </div>
        </footer>

    </body>

    <script>
        // Mobile menu toggle
        const mobileMenuButton = document.getElementById('mobile-menu-button');
        const mobileMenu = document.getElementById('mobile-menu');

        mobileMenuButton.addEventListener('click', function() {
            mobileMenu.classList.toggle('hidden');
        });

        // Close mobile menu when clicking outside
        document.addEventListener('click', function(event) {
            if (!mobileMenu.contains(event.target) && !mobileMenuButton.contains(event.target)) {
                mobileMenu.classList.add('hidden');
            }
        });

        // Swiper initialization
        const swiper = new Swiper(".swiper", {
            loop: true,
            centeredSlides: true,
            slidesPerView: 1,
            spaceBetween: 20,
            autoplay: {
                delay: 3000,
                disableOnInteraction: false,
            },
            pagination: {
                el: ".swiper-pagination",
                clickable: true,
            },
            breakpoints: {
                640: {
                    slidesPerView: 2,
                    spaceBetween: 20,
                },
                768: {
                    slidesPerView: 3,
                    spaceBetween: 30,
                }
            },
            on: {
                slideChangeTransitionEnd: function() {
                    updateSlideScaling();
                },
                init: function() {
                    updateSlideScaling();
                }
            }
        });

        function updateSlideScaling() {
            const slides = document.querySelectorAll('.swiper-slide-custom');
            slides.forEach((slide) => {
                slide.classList.remove('scale-110');
                slide.classList.add('scale-90');
            });
            const activeSlide = document.querySelector('.swiper-slide-active');
            if (activeSlide) {
                activeSlide.classList.remove('scale-90');
                activeSlide.classList.add('scale-110');
            }
        }
    </script>

</html>
