<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MOTORENT - Rental Motor</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        html,
        body {
            scroll-snap-type: y mandatory;
            overflow-y: scroll;
            height: 100vh;
            margin: 0;
            scroll-behavior: smooth;
        }

        .section {
            scroll-snap-align: ;
            height: 100vh;
        }
    </style>
</head>

<body>
    <!-- Header -->
    <header class="bg-white shadow-md py-4 px-6 flex justify-between items-center fixed top-0 left-0 w-full z-50">
        <div class="flex items-center">
            <img src="{{ asset('logo2.png') }}" alt="Motorrent Logo" class="w-24">
        </div>
        <nav>
            <ul class="flex space-x-6 text-gray-700">
                <li><a href="#home" class="hover:text-orange-500 font-medium">Beranda</a></li>
                <li><a href="#testimoni" class="hover:text-orange-500 font-medium">Ulasan Pengguna</a></li>
                <li><a href="#frame-section" class="hover:text-orange-500 font-medium">Sewa Motor</a></li>
                <li><a href="#footer" class="hover:text-orange-500 font-medium">Tentang Kami</a></li>
            </ul>
        </nav>
        <div class="flex items-center">
            <a href="{{ url('/login') }}"
                class="bg-orange-400 text-white px-4 py-2 rounded-lg mr-2 hover:bg-orange-300 transition">Login</a>
        </div>
    </header>

    <!-- Halaman 1: Hero Section -->

    <body
        style="background-image: url('{{ asset('back1.jpg') }}'); background-size: cover; background-position: center; background-repeat: no-repeat; background-attachment: fixed;">
        <section id="home"
            class="container mx-auto flex flex-col md:flex-row items-center justify-between py-28 px-10">
            <!-- Text -->
            <div class="md:w-1/2 text-left text-black">
                <h1 class="text-[2.5rem] font-bold leading-tight">
                    Nikmati Perjalanan di Toba,<br>
                    Bersama Motor Pilihanmu!
                </h1>
                <p class="mt-3 text-balck-300 text-lg">Perpanjang Sewa Kapan Saja dengan Mudah</p>

                <!-- App Store & Google Play Buttons -->
                <div class="mt-6 flex space-x-4">
                    <!-- App Store -->
                    <a href="#"
                        class="flex items-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg"
                            alt="Apple Logo" class="w-6 h-6 mr-2">
                        <div>
                            <p class="text-xs text-gray-500">Tersedia di</p>
                            <p class="text-lg font-semibold text-black">App Store</p>
                        </div>
                    </a>

                    <!-- Google Play -->
                    <a href="#"
                        class="flex items-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg"
                            alt="Google Play Logo" class="w-6 h-6 mr-2">
                        <div>
                            <p class="text-xs text-gray-500">Tersedia di</p>
                            <p class="text-lg font-semibold text-black">Google Play</p>
                        </div>
                    </a>
                </div>
            </div>
    </body>

    <!-- Gambar Motor -->
    <div class="md:w-1/2 flex justify-end">
        <img src="{{ asset('traced-motor.png') }}" alt="Motorcycle" class="w-full md:w-3/4 drop-shadow-lg">
    </div>
    </section>

    <!-- Halaman 2: Fitur Rental -->
    <section id="features" class="flex items-center justify-center bg-white py-16">
        <div class="flex items-center max-w-6xl px-8">
            <!-- Gambar Motor -->
            <div class="w-1/2 flex justify-center">
                <img src="{{ asset('traced-motor2.png') }}" alt="Motorcycle"
                    class="w-full md:w-[95%] lg:w-full drop-shadow-lg">
            </div>

            <!-- Teks & Fitur -->
            <div class="w-1/2 pl-12">
                <h2 class="text-4xl font-bold text-gray-1100 leading-snug">
                    Sewa motor <span class="text-green-900">lebih mudah dan cepat.</span> Coba sekarang!
                </h2>
                <div class="mt-8 space-y-6">

                    <!-- Fitur 1 -->
                    <div class="flex items-start space-x-5">
                        <div class="bg-orange-400 text-white p-4 rounded-full text-xl">
                            🔍
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-1000 text-lg">Beragam Pilihan Motor</h3>
                            <p class="text-gray-800 text-base">
                                Cari dan bandingkan berbagai jenis motor dari banyak vendor rental yang tersedia di
                                Kabupaten Toba.
                            </p>
                        </div>
                    </div>

                    <!-- Fitur 2 -->
                    <div class="flex items-start space-x-5">
                        <div class="bg-orange-400 text-white p-4 rounded-full text-xl">
                            📱
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-1000 text-lg">Pemesanan Mudah & Aman</h3>
                            <p class="text-gray-800 text-base">
                                Pesan motor langsung melalui aplikasi dengan sistem verifikasi identitas untuk keamanan
                                penyewaan.
                            </p>
                        </div>
                    </div>

                    <!-- Fitur 3 -->
                    <div class="flex items-start space-x-5">
                        <div class="bg-orange-400 text-white p-4 rounded-full text-xl">
                            💬
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-1000 text-lg">Layanan Pelanggan Responsif</h3>
                            <p class="text-gray-800 text-base">
                                Komunikasikan langsung dengan penyedia rental melalui fitur mini chat untuk negosiasi
                                dan janji temu.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Halaman 4: Pilih Motor -->
    <section id="pick-motor" class="relative flex flex-col items-center justify-center h-screen bg-cover bg-center"
        style="background-image: url('{{ asset('rentsection.png') }}');">
        <!-- Judul -->
        <h2 class="absolute top-10 left-1/2 transform -translate-x-1/2 text-4xl font-bold text-white drop-shadow-lg">
            Pilih Motor Anda
        </h2>

        <!-- Gambar Motor -->
        <div class="relative flex items-center justify-center w-full max-w-5xl mt-12">
            <!-- Motor Kiri -->
            <img src="{{ asset('m1.png') }}" alt="Motor Kiri" class="w-1/4 transform -translate-x-6">

            <!-- Motor Tengah -->
            <img src="{{ asset('m2.png') }}" alt="Motor Tengah" class="w-1/4 z-10">

            <!-- Motor Kanan -->
            <img src="{{ asset('m3.png') }}" alt="Motor Kanan" class="w-1/4 transform translate-x-6">
        </div>

        <!-- Indicator Slide -->
        <div class="flex space-x-2 mt-4">
            <span class="w-6 h-1 bg-gray-600 rounded-full"></span>
            <span class="w-6 h-1 bg-gray-300 rounded-full"></span>
            <span class="w-6 h-1 bg-gray-300 rounded-full"></span>
            <span class="w-6 h-1 bg-gray-300 rounded-full"></span>
        </div>

        <!-- Spesifikasi Motor -->
        <div class="flex justify-center space-x-8 text-lg font-medium mt-6 text-white">
            <div class="flex flex-col items-center">
                <img src="{{ asset('speed.png') }}" alt="Speed Icon" class="w-7 h-7 mb-1">
                <p>100 km/jam</p>
            </div>
            <div class="flex flex-col items-center text-2xl">
                <span>🛵</span>
                <p class="text-base mt-1">2 Kursi</p>
            </div>
            <div class="flex flex-col items-center text-2xl">
                <span>⛽</span>
                <p class="text-base mt-1">20 Liter</p>
            </div>
        </div>


        <!-- Harga & Tombol -->
        <div class="flex bg-white shadow-lg rounded-full px-6 py-3 mt-8 space-x-4 items-center">
            <span class="text-green-600 text-2xl font-bold">Rp 150.000<span class="text-gray-600 text-lg">/24
                    jam</span></span>
            <button class="px-4 py-2 bg-gray-200 rounded-md text-gray-700 hover:bg-gray-300 transition">Lihat
                detail</button>
            <button class="px-5 py-2 bg-orange-500 text-white rounded-md hover:bg-orange-600 transition">Sewa
                sekarang</button>
        </div>
    </section>



    <!-- Halaman 4: Testimoni Pelanggan -->
    <section id="testimoni"
        class="flex flex-col items-center justify-center min-h-screen px-10 py-16 bg-cover bg-center"
        style="background-image: url('{{ asset('back2.jpg') }}');">

        <div class="max-w-7xl w-full flex justify-between items-center">
            <!-- Bagian Kiri: Testimoni -->
            <div class="w-1/2">
                <h2 class="text-4xl font-bold text-gray-900">Apa Kata Mereka</h2>
                <p class="text-gray-500 text-lg mt-2">Pendapat pelanggan kami tentang layanan MotoRent</p>

                <div class="bg-white rounded-lg shadow-lg p-6 mt-6 w-[450px]">
                    <p class="italic text-gray-700">
                        MotoRent membuat jalan-jalan di kota jadi bebas stres! Motornya cocok banget untuk jalanan
                        sempit,
                        dan irit bensin juga. Pelayanannya luar biasa, dan proses pengembaliannya cepat tanpa ribet.
                        Dua jempol! 👍👍
                    </p>
                    <div class="mt-4">
                        <h3 class="font-bold text-gray-900 text-lg">Kelompok 11</h3>
                        <p class="text-gray-500">Pencinta Jelajah Kota</p>
                    </div>
                </div>
            </div>

            <!-- Bagian Kanan: Foto Pelanggan (1 Foto Besar dari public) -->
            <div class="w-1/2 flex justify-center relative">
                <div class="relative w-[300px] h-[300px] flex items-center justify-center">
                    <div class="w-64 h-64 rounded-full overflow-hidden shadow-xl border-4 border-white">
                        <img src="11.jpg" alt="Customer Utama" class="w-full h-full object-cover">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Halaman 5: Gambar frame2.png dengan Latar Putih -->
    <section id="frame-section" class="h-screen flex items-center justify-center bg-white">
        <div class="w-[80%] h-[500px] flex items-center justify-center relative">
            <!-- Gambar latar -->
            <img src="{{ asset('frame2.png') }}" alt="Frame 2" class="max-w-full max-h-full">

            <!-- Bagian teks dan tombol download -->
            <div class="absolute left-10 text-white">
                <h2 class="text-4xl font-bold mb-4">
                    Unduh <span class="text-white">motoRent</span> <span class="text-yellow-400">GRATIS</span>
                </h2>
                <p class="text-lg">Untuk pemesanan lebih cepat, mudah, dan penawaran eksklusif</p>
                <!-- App Store & Google Play Buttons -->
                <div class="mt-6 flex space-x-4">
                    <!-- App Store -->
                    <a href="#"
                        class="flex items-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg"
                            alt="Apple Logo" class="w-6 h-6 mr-2">
                        <div>
                            <p class="text-xs text-gray-500">Tersedia di</p>
                            <p class="text-lg font-semibold text-black">App Store</p>
                        </div>
                    </a>

                    <!-- Google Play -->
                    <a href="#"
                        class="flex items-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg"
                            alt="Google Play Logo" class="w-6 h-6 mr-2">
                        <div>
                            <p class="text-xs text-gray-500">Tersedia di</p>
                            <p class="text-lg font-semibold text-black">Google Play</p>
                        </div>
                    </a>
                </div>
            </div>

            <!-- Gambar mobile -->
            <img src="{{ asset('frame1.png') }}" alt="Mobile App Preview" class="absolute right-10 h-[500px]">
        </div>
    </section>

    <!-- footer-->
    <footer id="footer" class="bg-white py-10 px-10 border-t border-gray-200">
        <div class="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-start space-y-8 md:space-y-0">

            <!-- Logo dan Tagline -->
            <div class="md:w-1/3">
                <h1 class="text-3xl font-bold">
                    <span class="text-green-700">MO</span><span class="text-yellow-500">TO</span><span
                        class="text-green-700">RENT</span>
                </h1>
                <p class="text-green-700 mt-2">Sewa Motor Praktis & Terpercaya</p>
            </div>

            <!-- Navigasi -->
            <div class="md:w-1/3">
                <h3 class="font-semibold text-lg text-gray-700">Navigasi</h3>
                <ul class="mt-2 space-y-2 text-gray-600">
                    <li><a href="#home" class="hover:text-green-600 transition">Beranda</a></li>
                    <li><a href="#testimoni" class="hover:text-green-600 transition">Ulasan Pengguna</a></li>
                    <li><a href="#frame-section" class="hover:text-green-600 transition">Sewa Motor</a></li>
                    <li><a href="#footer" class="hover:text-green-600 transition">Tentang Kami</a></li>
                </ul>
            </div>

            <!-- Kontak & Sosial Media -->
            <div class="md:w-1/3">
                <h3 class="font-semibold text-lg text-gray-700">Hubungi Kami</h3>
                <p class="text-gray-600 mt-2">Email: info@motoRent.id</p>
                <p class="text-gray-600">Telepon: +62 812-3456-7890</p>
                <div class="flex space-x-4 mt-4">
                    <a href="https://www.instagram.com/" target="_blank">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png"
                            alt="Instagram" class="h-6">
                    </a>
                    <a href="https://www.tiktok.com/" target="_blank">
                        <img src="https://upload.wikimedia.org/wikipedia/en/a/a9/TikTok_logo.svg" alt="TikTok"
                            class="h-6">
                    </a>
                    <a href="https://www.facebook.com/" target="_blank">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg"
                            alt="Facebook" class="h-6">
                    </a>
                </div>
            </div>
        </div>

        <!-- Copyright -->
        <div class="text-center text-gray-500 text-sm mt-10">
            ©2025 MotoRent. Semua Hak Dilindungi
        </div>
    </footer>

</body>

</html>
