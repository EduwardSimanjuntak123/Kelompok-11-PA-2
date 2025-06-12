<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MOTORENT - Rental Motor</title>

    <!-- Favicon Basic -->
    <link rel="icon" href="/test.png" type="image/png">

    <!-- Font Awesome for better icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

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

        /* Google Play Store button responsive styles */
        .play-store-btn {
            min-width: 140px;
            max-width: 200px;
        }

        @media (max-width: 640px) {
            .play-store-btn {
                min-width: 120px;
                max-width: 160px;
            }
        }

        /* Testimonial card styles */
        .testimonial-card {
            transition: all 0.3s ease;
        }

        .testimonial-card:hover {
            transform: translateY(-5px);
        }

        /* Service icon styles */
        .service-icon {
            transition: all 0.3s ease;
        }

        .service-icon:hover {
            transform: scale(1.1);
        }
    </style>
</head>

<body>
    <!-- Header -->
    <header
        class="bg-white shadow-md py-3 sm:py-4 px-4 sm:px-6 flex justify-between items-center fixed top-0 left-0 w-full z-50">
        <div class="flex items-center">
            <img src="logo2.png" alt="Motorrent Logo" class="w-16 sm:w-20 md:w-24">
        </div>

        <!-- Mobile Menu Button -->
        <button id="mobile-menu-button" class="md:hidden text-gray-700 focus:outline-none">
            <i class="fas fa-bars text-xl"></i>
        </button>

        <!-- Desktop Navigation -->
        <nav class="hidden md:block">
            <ul class="flex space-x-4 lg:space-x-6 text-gray-700">
                <li><a href="#home" class="hover:text-orange-500 font-medium text-sm lg:text-base">Beranda</a></li>
                <li><a href="#testimoni" class="hover:text-orange-500 font-medium text-sm lg:text-base">Ulasan
                        Pengguna</a></li>
                <li><a href="#frame-section" class="hover:text-orange-500 font-medium text-sm lg:text-base">Sewa
                        Motor</a></li>
            </ul>
        </nav>

        <!-- Mobile Navigation (hidden by default) -->
        <div id="mobile-menu" class="hidden absolute top-16 left-0 right-0 bg-white shadow-lg py-4 px-6">
            <ul class="flex flex-col space-y-4 text-gray-700">
                <li><a href="#home" class="hover:text-orange-500 font-medium block">Beranda</a></li>
                <li><a href="#testimoni" class="hover:text-orange-500 font-medium block">Ulasan Pengguna</a></li>
                <li><a href="#frame-section" class="hover:text-orange-500 font-medium block">Sewa Motor</a></li>
                <li><a href="#footer" class="hover:text-orange-500 font-medium block">Kontak</a></li>
                <li>
                    <a href="/login"
                        class="bg-orange-400 text-white px-4 py-2 rounded-lg hover:bg-orange-300 transition flex items-center justify-center">
                        <i class="fas fa-sign-in-alt mr-2"></i>
                        Login
                    </a>
                </li>
            </ul>
        </div>

        <div class="hidden md:flex items-center">
            <a href="/login"
                class="bg-orange-400 text-white px-3 lg:px-4 py-2 rounded-lg hover:bg-orange-300 transition flex items-center text-sm lg:text-base">
                <i class="fas fa-sign-in-alt mr-2"></i>
                Login
            </a>
        </div>
    </header>

    <!-- Halaman 1: Hero Section -->

    <body
        style="background-image: url('back1.jpg'); background-size: cover; background-position: center; background-repeat: no-repeat; background-attachment: fixed;">
        <section id="home"
            class="container mx-auto flex flex-col md:flex-row items-center justify-between pt-24 sm:pt-28 md:pt-32 pb-12 md:pb-16 px-4 md:px-10">
            <!-- Text -->
            <div class="md:w-1/2 text-center md:text-left text-black mb-8 md:mb-0">
                <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-[2.5rem] font-bold leading-tight">
                    Nikmati Perjalanan di Toba,<br>
                    Bersama Motor Pilihanmu!
                </h1>
                <p class="mt-3 text-black-300 text-sm sm:text-base md:text-lg">Perpanjang Sewa Kapan Saja dengan Mudah
                </p>

                <!-- Google Play Button - Responsive -->
                <div class="mt-6 flex justify-center md:justify-start">
                    <div
                        class="flex items-center border border-gray-400 px-3 sm:px-4 py-2 sm:py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition play-store-btn">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg"
                            alt="Google Play Logo" class="w-5 h-5 sm:w-6 sm:h-6 mr-2 flex-shrink-0">
                        <div class="min-w-0">
                            <p class="text-xs text-gray-500">Tersedia di</p>
                            <p class="text-sm sm:text-lg font-semibold text-black">Play Store</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Gambar Motor -->
            <div class="md:w-1/2 flex justify-center">
                <img src="traced-motor.png" alt="Motorcycle"
                    class="w-full max-w-xs sm:max-w-md md:w-3/4 drop-shadow-lg">
            </div>
        </section>

        <!-- Halaman 2: Fitur Rental -->
        <section id="features" class="flex items-center justify-center bg-white py-12 md:py-16">
            <div class="flex flex-col md:flex-row items-center max-w-6xl px-4 md:px-8">
                <!-- Gambar Motor -->
                <div class="w-full md:w-1/2 flex justify-center mb-8 md:mb-0">
                    <img src="traced-motor2.png" alt="Motorcycle"
                        class="w-full max-w-sm sm:max-w-md md:max-w-none md:w-[95%] lg:w-full drop-shadow-lg">
                </div>

                <!-- Teks & Fitur -->
                <div class="w-full md:w-1/2 md:pl-6 lg:pl-12">
                    <h2
                        class="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-1100 leading-snug text-center md:text-left">
                        Sewa motor <span class="text-green-900">lebih mudah dan cepat.</span> Coba sekarang!
                    </h2>
                    <div class="mt-6 md:mt-8 space-y-4 sm:space-y-6">
                        <!-- Fitur 1 -->
                        <div class="flex items-start space-x-3 sm:space-x-4 md:space-x-5">
                            <div
                                class="service-icon bg-orange-400 text-white p-2 sm:p-3 md:p-4 rounded-full flex-shrink-0 flex items-center justify-center w-10 h-10 sm:w-12 sm:h-12 md:w-14 md:h-14">
                                <i class="fas fa-motorcycle text-xl sm:text-2xl md:text-3xl"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-gray-1000 text-sm sm:text-base md:text-lg">Beragam Pilihan
                                    Motor</h3>
                                <p class="text-gray-800 text-xs sm:text-sm md:text-base">
                                    Cari dan bandingkan berbagai jenis motor dari banyak vendor rental yang tersedia di
                                    Kabupaten Toba.
                                </p>
                            </div>
                        </div>

                        <!-- Fitur 2 -->
                        <div class="flex items-start space-x-3 sm:space-x-4 md:space-x-5">
                            <div
                                class="service-icon bg-orange-400 text-white p-2 sm:p-3 md:p-4 rounded-full flex-shrink-0 flex items-center justify-center w-10 h-10 sm:w-12 sm:h-12 md:w-14 md:h-14">
                                <i class="fas fa-mobile-alt text-xl sm:text-2xl md:text-3xl"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-gray-1000 text-sm sm:text-base md:text-lg">Pemesanan Mudah &
                                    Aman</h3>
                                <p class="text-gray-800 text-xs sm:text-sm md:text-base">
                                    Pesan motor langsung melalui aplikasi dengan sistem verifikasi identitas untuk
                                    keamanan penyewaan.
                                </p>
                            </div>
                        </div>

                        <!-- Fitur 3 - Improved icon -->
                        <div class="flex items-start space-x-3 sm:space-x-4 md:space-x-5">
                            <div
                                class="service-icon bg-orange-400 text-white p-2 sm:p-3 md:p-4 rounded-full flex-shrink-0 flex items-center justify-center w-10 h-10 sm:w-12 sm:h-12 md:w-14 md:h-14">
                                <i class="fas fa-headset text-xl sm:text-2xl md:text-3xl"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-gray-1000 text-sm sm:text-base md:text-lg">Layanan Pelanggan
                                    Responsif</h3>
                                <p class="text-gray-800 text-xs sm:text-sm md:text-base">
                                    Komunikasikan langsung dengan penyedia rental melalui fitur mini chat untuk
                                    negosiasi dan janji temu.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section id="pick-motor"
            class="relative flex flex-col items-center justify-center min-h-screen px-4 md:px-12 bg-cover bg-center"
            style="background-image: url('rentsection.png');">

            <!-- Judul -->
            <h2
                class="absolute top-12 sm:top-16 md:top-10 left-1/2 transform -translate-x-1/2 text-xl sm:text-2xl md:text-4xl font-bold text-white drop-shadow-lg text-center w-full px-4">
                Pilih Motor Anda
            </h2>

            <!-- Swiper Slider -->
            <div class="swiper w-full max-w-5xl mt-20 sm:mt-24 md:mt-28 px-4">
                <div class="swiper-wrapper">
                    <!-- Slide Motor 1 -->
                    <div class="swiper-slide swiper-slide-custom flex justify-center" data-motor-id="1">
                        <img src="m1.png" alt="Motor"
                            class="w-4/5 md:w-3/5 object-contain transition-transform duration-300 hover:scale-105" />
                    </div>
                    <!-- Slide Motor 2 -->
                    <div class="swiper-slide swiper-slide-custom flex justify-center" data-motor-id="2">
                        <img src="m2.png" alt="Motor"
                            class="w-4/5 md:w-3/5 object-contain transition-transform duration-300 hover:scale-105" />
                    </div>
                    <!-- Slide Motor 3 -->
                    <div class="swiper-slide swiper-slide-custom flex justify-center" data-motor-id="3">
                        <img src="m3.png" alt="Motor"
                            class="w-4/5 md:w-3/5 object-contain transition-transform duration-300 hover:scale-105" />
                    </div>
                    <!-- Slide Motor 4 -->
                    <div class="swiper-slide swiper-slide-custom flex justify-center" data-motor-id="4">
                        <img src="scopp.png" alt="Motor"
                            class="w-4/5 md:w-3/5 object-contain transition-transform duration-300 hover:scale-105" />
                    </div>
                </div>
                <div class="swiper-pagination mt-4 sm:mt-6"></div>
            </div>

            <!-- Spesifikasi Motor - Updated without CC -->
            <div id="motor-specs"
                class="flex flex-wrap justify-center gap-4 sm:gap-6 md:gap-10 text-white text-center text-xs sm:text-sm md:text-base font-medium mt-6 sm:mt-8 md:mt-12 bg-black/40 rounded-xl px-4 py-4 sm:px-6 sm:py-6 md:px-8 md:py-8 backdrop-blur-md mx-4">
                <!-- Speed -->
                <div class="flex flex-col items-center px-2 sm:px-3">
                    <i class="fas fa-tachometer-alt text-lg sm:text-xl md:text-2xl mb-2"></i>
                    <p id="motor-speed">100 km/jam</p>
                    <span class="text-xs opacity-75">Kecepatan</span>
                </div>

                <!-- Seat -->
                <div class="flex flex-col items-center px-2 sm:px-3">
                    <i class="fas fa-users text-lg sm:text-xl md:text-2xl mb-2"></i>
                    <p id="motor-seats">2 Kursi</p>
                    <span class="text-xs opacity-75">Kapasitas</span>
                </div>

                <!-- Fuel -->
                <div class="flex flex-col items-center px-2 sm:px-3">
                    <i class="fas fa-gas-pump text-lg sm:text-xl md:text-2xl mb-2"></i>
                    <p id="motor-fuel">20 Liter</p>
                    <span class="text-xs opacity-75">Tangki</span>
                </div>
            </div>

            <!-- Harga (Fleksibel) -->
            <div
                class="flex bg-white shadow-sm rounded-full px-3 sm:px-4 md:px-8 py-2 md:py-3 items-center border-2 border-green-400 mt-4 md:mt-6 mx-4">
                <span class="text-green-700 font-bold text-xs sm:text-sm md:text-base">
                    <span class="text-green-600">✓</span> Harga Kompetitif
                    <span class="text-gray-600 text-xs font-normal"> & tanpa biaya tersembunyi</span>
                </span>
            </div>
        </section>

        <!-- Halaman 4: Testimoni Pelanggan - Improved with multiple testimonials -->
        <section id="testimoni"
            class="flex flex-col items-center justify-center min-h-screen px-4 md:px-10 py-12 md:py-16 bg-cover bg-center"
            style="background-image: url('back2.jpg');">
            <div class="max-w-7xl w-full">
                <h2 class="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 text-center">Apa Kata Mereka</h2>
                <p class="text-gray-500 text-sm sm:text-base md:text-lg mt-2 text-center">Pendapat pelanggan kami
                    tentang layanan MotoRent</p>

                <!-- Testimonial Cards -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-8">
                    <!-- Testimonial 1 -->
                    <div class="testimonial-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center">
                        <div class="w-20 h-20 rounded-full overflow-hidden border-4 border-orange-400 mb-4">
                            <img src="11.jpg" alt="Customer 1" class="w-full h-full object-cover">
                        </div>
                        <p class="italic text-gray-700 text-center mb-4">
                            MotoRent membuat jalan-jalan di kota jadi bebas stres! Motornya cocok banget untuk jalanan
                            sempit, dan irit bensin juga. Pelayanannya luar biasa!
                        </p>
                        <div class="mt-auto">
                            <h3 class="font-bold text-gray-900 text-center">Kelompok 11</h3>
                            <p class="text-gray-500 text-sm text-center">Pencinta Jelajah Kota</p>
                            <div class="flex justify-center mt-2">
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Testimonial 2 -->
                    <div class="testimonial-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center">
                        <div class="w-20 h-20 rounded-full overflow-hidden border-4 border-orange-400 mb-4">
                            <img src="pria.jpg" alt="Customer 2" class="w-full h-full object-cover">
                        </div>
                        <p class="italic text-gray-700 text-center mb-4">
                            Saya sangat puas dengan layanan MotoRent. Proses pemesanan sangat mudah dan motor yang
                            disediakan dalam kondisi prima. Akan menggunakan lagi!
                        </p>
                        <div class="mt-auto">
                            <h3 class="font-bold text-gray-900 text-center">Kevin De Brune</h3>
                            <p class="text-gray-500 text-sm text-center">Wisatawan</p>
                            <div class="flex justify-center mt-2">
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star-half-alt text-yellow-400"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Testimonial 3 -->
                    <div class="testimonial-card bg-white rounded-lg shadow-lg p-6 flex flex-col items-center">
                        <div class="w-20 h-20 rounded-full overflow-hidden border-4 border-orange-400 mb-4">
                            <img src="Traveling.jpg" alt="Customer 3" class="w-full h-full object-cover">
                        </div>
                        <p class="italic text-gray-700 text-center mb-4">
                            Harga terjangkau dan kualitas motor sangat baik. Customer service sangat responsif dan
                            membantu. Rekomendasi untuk liburan di Toba!
                        </p>
                        <div class="mt-auto">
                            <h3 class="font-bold text-gray-900 text-center">Van Persie</h3>
                            <p class="text-gray-500 text-sm text-center">Traveler</p>
                            <div class="flex justify-center mt-2">
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                                <i class="fas fa-star text-yellow-400"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Halaman 5: Gambar frame2.png sebagai background -->
        <section id="frame-section" class="w-full flex items-center justify-center bg-white py-12">
            <div class="w-full max-w-6xl flex flex-col md:flex-row items-center justify-between px-4 md:px-8 bg-no-repeat bg-center bg-contain md:bg-cover"
                style="background-image: url('frame2.png'); background-size: contain; background-position: center;">

                <!-- Konten teks -->
                <div class="w-full md:w-1/2 text-center md:text-left text-black md:text-white mb-8 md:mb-0 z-10">
                    <h2 class="text-2xl sm:text-3xl md:text-4xl font-bold mb-4">
                        Unduh <span class="text-black md:text-white">MotoRent</span> <span
                            class="text-yellow-400">GRATIS</span>
                    </h2>
                    <p class="text-sm sm:text-base md:text-lg">
                        Untuk pemesanan lebih cepat, mudah, dan penawaran eksklusif
                    </p>
                </div>

                <!-- Gambar mobile -->
                <div class="w-full md:w-1/2 flex justify-center md:justify-end z-10">
                    <img src="frame1.png" alt="Mobile App Preview"
                        class="h-48 sm:h-64 md:h-80 lg:h-[450px] object-contain">
                </div>
            </div>
        </section>



        <!-- Footer - Updated with centered layout and logo image -->
        <footer id="footer" class="bg-white py-8 md:py-12 px-4 md:px-10 border-t border-gray-200">
            <div class="max-w-4xl mx-auto text-center">
                <!-- Logo dan Tagline - Centered -->
                <div class="mb-6">
                    <img src="logo2.png" alt="MotoRent Logo" class="w-20 sm:w-24 md:w-28 mx-auto mb-3">
                    <p class="text-green-700 text-sm sm:text-base md:text-lg font-medium">Sewa Motor Praktis &
                        Terpercaya</p>
                </div>

                <!-- Kontak & Sosial Media - Centered -->
                <div class="mb-6">
                    <h3 class="font-semibold text-base sm:text-lg md:text-xl text-gray-700 mb-4">Hubungi Kami</h3>
                    <div class="space-y-2">
                        <p class="text-gray-600 text-sm sm:text-base">
                            <i class="fas fa-envelope text-orange-400 mr-2"></i>Email: info@motoRent.id
                        </p>
                        <p class="text-gray-600 text-sm sm:text-base">
                            <i class="fas fa-phone-alt text-orange-400 mr-2"></i>Telepon: +62 812-3456-7890
                        </p>
                    </div>

                    <!-- Social Media Icons -->
                    <div class="flex justify-center space-x-6 mt-4">
                        <a href="https://www.instagram.com/" target="_blank"
                            class="text-orange-400 hover:text-orange-500 transition transform hover:scale-110">
                            <i class="fab fa-instagram text-2xl sm:text-3xl"></i>
                        </a>
                        <a href="https://www.tiktok.com/" target="_blank"
                            class="text-orange-400 hover:text-orange-500 transition transform hover:scale-110">
                            <i class="fab fa-tiktok text-2xl sm:text-3xl"></i>
                        </a>
                        <a href="https://www.facebook.com/" target="_blank"
                            class="text-orange-400 hover:text-orange-500 transition transform hover:scale-110">
                            <i class="fab fa-facebook text-2xl sm:text-3xl"></i>
                        </a>
                    </div>
                </div>

                <!-- Copyright -->
                <div class="border-t border-gray-200 pt-6">
                    <p class="text-gray-500 text-xs sm:text-sm">
                        ©2025 MotoRent. Semua Hak Dilindungi
                    </p>
                </div>
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

        // Motor specifications data - Updated without CC
        const motorData = [{
                id: 1,
                speed: "100 km/jam",
                seats: "2 Kursi",
                fuel: "20 Liter"
            },
            {
                id: 2,
                speed: "120 km/jam",
                seats: "2 Kursi",
                fuel: "15 Liter"
            },
            {
                id: 3,
                speed: "90 km/jam",
                seats: "2 Kursi",
                fuel: "12 Liter"
            },
            {
                id: 4,
                speed: "80 km/jam",
                seats: "2 Kursi",
                fuel: "10 Liter"
            }
        ];

        // Function to update motor specifications
        function updateMotorSpecs(motorId) {
            const motor = motorData.find(m => m.id === motorId);
            if (motor) {
                document.getElementById('motor-speed').textContent = motor.speed;
                document.getElementById('motor-seats').textContent = motor.seats;
                document.getElementById('motor-fuel').textContent = motor.fuel;
            }
        }

        // Swiper initialization with improved functionality
        const swiper = new Swiper(".swiper", {
            loop: true,
            centeredSlides: true,
            slidesPerView: 1,
            spaceBetween: 20,
            autoplay: {
                delay: 4000,
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

                    // Get the active slide and update motor specs
                    const activeSlide = document.querySelector('.swiper-slide-active');
                    if (activeSlide) {
                        const motorId = parseInt(activeSlide.getAttribute('data-motor-id'));
                        updateMotorSpecs(motorId);
                    }
                },
                slideChange: function() {
                    // Also update on slide change for immediate feedback
                    const activeSlide = document.querySelector('.swiper-slide-active');
                    if (activeSlide) {
                        const motorId = parseInt(activeSlide.getAttribute('data-motor-id'));
                        updateMotorSpecs(motorId);
                    }
                },
                init: function() {
                    updateSlideScaling();
                    // Initialize with the first motor's specs
                    updateMotorSpecs(1);
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
