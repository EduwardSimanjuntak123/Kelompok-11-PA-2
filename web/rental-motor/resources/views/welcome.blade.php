<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MOTORENT - Rental Motor</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        html, body {
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
            <li><a href="#home" class="hover:text-orange-500 font-medium">Home</a></li>
            <li><a href="#testimoni" class="hover:text-orange-500 font-medium">Why Choose Us</a></li>
            <li><a href="#frame-section" class="hover:text-orange-500 font-medium">Rent</a></li>
            <li><a href="#footer" class="hover:text-orange-500 font-medium">About Us</a></li>
        </ul>
    </nav>
    <div class="flex items-center">
        <a href="{{ url('/login') }}" class="border border-orange-300 text-orange-400 px-4 py-2 rounded-lg mr-2 hover:bg-orange-100 transition">Login</a>
        <button class="bg-orange-500 text-white px-4 py-2 rounded-lg hover:bg-orange-600 transition">Register</button>
    </div>
</header>


    <!-- Halaman 1: Hero Section -->
    <body style="background-image: url('{{ asset('back1.jpg') }}'); background-size: cover; background-position: center; background-repeat: no-repeat;">
        <section id="home" class="container mx-auto flex flex-col md:flex-row items-center justify-between py-28 px-10">
        <!-- Text -->
        <div class="md:w-1/2 text-left text-black">
            <h1 class="text-5xl font-bold leading-tight">
                Drive the Experience:<br>
                Your Journey, Your Motorcycle, in Toba!
            </h1>
            <p class="mt-3 text-balck-300 text-lg">Easy to Extend Rental Hour</p>

            <!-- App Store & Google Play Buttons -->
            <div class="mt-6 flex space-x-4">
                <!-- App Store -->
                <a href="#" class="flex items-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg" alt="Apple Logo" class="w-6 h-6 mr-2">
                    <div>
                        <p class="text-xs text-gray-500">Download on the</p>
                        <p class="text-lg font-semibold text-black">App Store</p>
                    </div>
                </a>

                <!-- Google Play -->
                <a href="#" class="flex items-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" alt="Google Play Logo" class="w-6 h-6 mr-2">
                    <div>
                        <p class="text-xs text-gray-500">GET IT ON</p>
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

    <!-- Halaman 2: Form Pencarian -->
<section id="search" class="flex justify-center items-center bg-white py-6">
    <div class="bg-white shadow-lg rounded-2xl px-6 py-4 flex items-center space-x-4 w-[900px]">
        <!-- Choose a location -->
        <div class="flex items-center bg-gray-100 rounded-lg px-3 py-2 w-1/5">
            <span class="text-gray-600 text-lg">📍</span>
            <select class="bg-transparent focus:outline-none text-gray-700 w-full ml-2">
                <option selected>Choose a location</option>
                <option value="toba">Toba</option>
                <option value="balige">Balige</option>
                <option value="laguboti">Laguboti</option>
            </select>
        </div>

        <!-- Pick-up Date -->
        <div class="flex items-center bg-gray-100 rounded-lg px-3 py-2 w-1/5">
            <span class="text-gray-600 text-lg">📅</span>
            <input type="date" class="bg-transparent focus:outline-none text-gray-700 w-full ml-2">
        </div>

        <!-- Return Date -->
        <div class="flex items-center bg-gray-100 rounded-lg px-3 py-2 w-1/5">
            <span class="text-gray-600 text-lg">📅</span>
            <input type="date" class="bg-transparent focus:outline-none text-gray-700 w-full ml-2">
        </div>

        <!-- Type a motorcycle -->
        <div class="flex items-center bg-gray-100 rounded-lg px-3 py-2 w-1/5">
            <span class="text-gray-600 text-lg">🏍️</span>
            <select class="bg-transparent focus:outline-none text-gray-700 w-full ml-2">
                <option selected>Type a motorcycle</option>
                <option value="honda">Honda</option>
                <option value="yamaha">Yamaha</option>
                <option value="supra">Supra</option>
                <option value="suzuki">Suzuki</option>
                <option value="vespa">Vespa</option>
            </select>
        </div>

        <!-- Search Button -->
        <button class="bg-orange-500 text-white px-6 py-3 rounded-lg hover:bg-orange-600 transition w-1/5">
            Search
        </button>
    </div>
</section>

    </div>
</section>
<!-- Halaman 3: Fitur Rental -->
<section id="features" class="flex items-center justify-center bg-white py-16">
    <div class="flex items-center max-w-6xl px-8">
        <!-- Gambar Motor -->
    <div class="w-1/2 flex justify-center">
        <img src="{{ asset('traced-motor2.png') }}" alt="Motorcycle" class="w-full md:w-[95%] lg:w-full drop-shadow-lg">
    </div>


        <!-- Teks & Fitur -->
        <div class="w-1/2 pl-12">
            <h2 class="text-4xl font-bold text-gray-1100 leading-snug">
                Rent a motorcycle now <span class="text-green-900">in your hand.</span> Try it now!
            </h2>
            <div class="mt-8 space-y-6">
                <!-- Fitur 1 -->
                <div class="flex items-start space-x-5">
                    <div class="bg-orange-400 text-white p-4 rounded-full text-xl">
                        💳
                    </div>
                    <div>
                        <h3 class="font-bold text-gray-1000 text-lg">Flexible Payment Methods</h3>
                        <p class="text-gray-800 text-base">
                            Dukung pembayaran melalui e-wallet dan transfer bank untuk kenyamanan transaksi.
                        </p>
                    </div>
                </div>

                <!-- Fitur 2 -->
                <div class="flex items-start space-x-5">
                    <div class="bg-orange-400 text-white p-4 rounded-full text-xl">
                        🔍
                    </div>
                    <div>
                        <h3 class="font-bold text-gray-1000 text-lg">Various Motorcycle Options</h3>
                        <p class="text-gray-800 text-base">
                            Cari dan bandingkan berbagai jenis motor dari banyak vendor rental yang tersedia di Kabupaten Toba.
                        </p>
                    </div>
                </div>

                <!-- Fitur 3 -->
                <div class="flex items-start space-x-5">
                    <div class="bg-orange-400 text-white p-4 rounded-full text-xl">
                        📱
                    </div>
                    <div>
                        <h3 class="font-bold text-gray-1000 text-lg">Easy & Secure Booking</h3>
                        <p class="text-gray-800 text-base">
                            Pesan motor langsung melalui aplikasi dengan sistem verifikasi identitas untuk keamanan penyewaan.
                        </p>
                    </div>
                </div>

                <!-- Fitur 4 -->
                <div class="flex items-start space-x-5">
                    <div class="bg-orange-400 text-white p-4 rounded-full text-xl">
                        💬
                    </div>
                    <div>
                        <h3 class="font-bold text-gray-1000 text-lg">Quick Customer Support</h3>
                        <p class="text-gray-800 text-base">
                            Komunikasikan langsung dengan penyedia rental melalui fitur mini chat untuk negosiasi dan janji temu.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Halaman 4: Pilih Motor -->
<section id="pick-motor" class="relative flex flex-col items-center justify-center h-screen bg-cover bg-center" style="background-image: url('{{ asset('rentsection.png') }}');">
    <!-- Judul -->
    <h2 class="absolute top-10 left-1/2 transform -translate-x-1/2 text-4xl font-bold text-white drop-shadow-lg">
        Pick Your Motor
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
            <span>🏎️</span>
            <p>300 km/h</p>
        </div>
        <div class="flex flex-col items-center">
            <span>🛵</span>
            <p>2 Seat</p>
        </div>
        <div class="flex flex-col items-center">
            <span>⛽</span>
            <p>20 Liter</p>
        </div>
    </div>

    <!-- Harga & Tombol -->
    <div class="flex bg-white shadow-lg rounded-full px-6 py-3 mt-8 space-x-4 items-center">
        <span class="text-green-600 text-2xl font-bold">Rp 150.000<span class="text-gray-600 text-lg">/24h</span></span>
        <button class="px-4 py-2 bg-gray-200 rounded-md text-gray-700 hover:bg-gray-300 transition">Check details</button>
        <button class="px-5 py-2 bg-orange-500 text-white rounded-md hover:bg-orange-600 transition">Rent now</button>
    </div>
</section>



<!-- Halaman 5: Testimoni Pelanggan -->
<section id="testimoni" class="flex flex-col items-center justify-center min-h-screen px-10 py-16 bg-cover bg-center"
    style="background-image: url('{{ asset('back2.jpg') }}');">

    <div class="max-w-7xl w-full flex justify-between items-center">
        <!-- Bagian Kiri: Testimoni -->
        <div class="w-1/2">
            <h2 class="text-4xl font-bold text-gray-900">What people are saying</h2>
            <p class="text-gray-500 text-lg mt-2">What our lovely customer sold for our service</p>

            <div class="bg-white rounded-lg shadow-lg p-6 mt-6 w-[450px]">
                <p class="italic text-gray-700">
                    MotoRent made exploring the city stress-free! The motorcycle was perfect for navigating tight streets,
                    and its fuel efficiency helped me save money. Excellent service, and the return process was quick and hassle-free.
                    Two thumbs up! 👍👍
                </p>
                <div class="mt-4">
                    <h3 class="font-bold text-gray-900 text-lg">Sophie L</h3>
                    <p class="text-gray-500">City Explorer</p>
                </div>
            </div>
        </div>

        <!-- Bagian Kanan: Foto Pelanggan -->
        <div class="w-1/2 flex justify-center relative">
            <div class="relative w-[350px] h-[350px] flex items-center justify-center">
                <!-- Foto Utama (Tengah) -->
                <div class="absolute w-24 h-24 rounded-full overflow-hidden shadow-lg">
                    <img src="https://randomuser.me/api/portraits/men/45.jpg" alt="Customer 1">
                </div>
                <!-- Foto Sekitar -->
                <div class="absolute w-20 h-20 rounded-full overflow-hidden top-0 left-8 shadow-md">
                    <img src="https://randomuser.me/api/portraits/women/45.jpg" alt="Customer 2">
                </div>
                <div class="absolute w-24 h-24 rounded-full overflow-hidden top-12 right-0 shadow-md">
                    <img src="https://randomuser.me/api/portraits/men/55.jpg" alt="Customer 3">
                </div>
                <div class="absolute w-16 h-16 rounded-full overflow-hidden bottom-10 left-4 shadow-md">
                    <img src="https://randomuser.me/api/portraits/women/33.jpg" alt="Customer 4">
                </div>
                <div class="absolute w-20 h-20 rounded-full overflow-hidden bottom-0 right-12 shadow-md">
                    <img src="https://randomuser.me/api/portraits/men/25.jpg" alt="Customer 5">
                </div>
                <div class="absolute w-14 h-14 rounded-full overflow-hidden bottom-8 left-20 shadow-md">
                    <img src="https://randomuser.me/api/portraits/women/28.jpg" alt="Customer 6">
                </div>
            </div>
        </div>
    </div>
</section>


<!-- Halaman 6: Gambar frame2.png dengan Latar Putih -->
<section id="frame-section" class="h-screen flex items-center justify-center bg-white">
    <div class="w-[80%] h-[500px] flex items-center justify-center relative">
        <!-- Gambar latar -->
        <img src="{{ asset('frame2.png') }}" alt="Frame 2" class="max-w-full max-h-full">

        <!-- Bagian teks dan tombol download -->
        <div class="absolute left-10 text-white">
            <h2 class="text-3xl font-bold">Download motoRent <span class="text-yellow-400">for FREE</span></h2>
            <p class="text-lg">For faster, easier booking and exclusive deals</p>
            <!-- App Store & Google Play Buttons -->
            <div class="mt-6 flex space-x-4">
                <!-- App Store -->
                <a href="#" class="flex items-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg" alt="Apple Logo" class="w-6 h-6 mr-2">
                    <div>
                        <p class="text-xs text-gray-500">Download on the</p>
                        <p class="text-lg font-semibold text-black">App Store</p>
                    </div>
                </a>

                <!-- Google Play -->
                <a href="#" class="flex items-center border border-gray-400 px-4 py-3 rounded-lg shadow-md bg-white hover:bg-gray-200 transition">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" alt="Google Play Logo" class="w-6 h-6 mr-2">
                    <div>
                        <p class="text-xs text-gray-500">GET IT ON</p>
                        <p class="text-lg font-semibold text-black">Google Play</p>
                    </div>
                </a>
            </div>
        </div>

        <!-- Gambar mobile -->
        <img src="{{ asset('frame1.png') }}" alt="Mobile App Preview" class="absolute right-10 h-[500px]">
    </div>
</section>

<footer id="footer" class="bg-white py-8 px-10">
    <div class="max-w-7xl mx-auto flex justify-between items-start">

        <!-- Logo dan Tagline -->
<div class="w-1/4 flex items-center ml-[-10px]">


    <!-- Teks dengan ukuran lebih besar dan warna sesuai logo -->
    <div class="ml-3">
        <h1 class="text-3xl font-bold">
            <span class="text-green-700">MO</span><span class="text-yellow-500">TO</span><span class="text-green-700">RENT</span>
        </h1>
        <p class="text-lg text-green-700 mt-1">Drive Your Dream : Starts Here!</p>
    </div>
</div>

        <!-- Pages -->
        <div class="w-1/6">
            <h3 class="font-semibold text-lg">Pages</h3>
            <ul class="mt-2 space-y-1 text-gray-600">
                <li><a href="#home" class="text-green-500">Home</a></li>
                <li><a href="#testimoni" class="hover:text-orange-500">Why Choose Us</a></li>
                <li><a href="#frame-section" class="hover:text-orange-500">Rent</a></li>
                <li><a href="#footer" class="hover:text-orange-500">About Us</a></li>
            </ul>
        </div>

        <!-- Resources -->
        <div class="w-1/6">
            <h3 class="font-semibold text-lg">Resources</h3>
            <ul class="mt-2 space-y-1 text-gray-600">
                <li><a href="#"class="hover:text-orange-500">Installation Manual</a></li>
                <li><a href="#"class="hover:text-orange-500">Release Note</a></li>
                <li><a href="#"class="hover:text-orange-500">Privacy Policy</a></li>
                <li><a href="#"class="hover:text-orange-500">Download</a></li>
                <li><a href="#"class="hover:text-orange-500">Developer</a></li>
            </ul>
        </div>

        <!-- Brands -->
        <div class="w-1/6">
            <h3 class="font-semibold text-lg">Brands</h3>
            <ul class="mt-2 space-y-1 text-gray-600">
                <li><a href="#"class="hover:text-orange-500">Honda</a></li>
                <li><a href="#"class="hover:text-orange-500">Yamaha</a>
                <li><a href="#"class="hover:text-orange-500">Supra</a>
                <li><a href="#"class="hover:text-orange-500">Suzuki</a>
                <li><a href="#"class="hover:text-orange-500">Vespa</a>
            </ul>
        </div>

        <!-- Subscribe -->
        <div class="w-1/4">
            <h3 class="font-semibold text-lg">Subscribe</h3>
            <div class="flex items-center mt-2 border-b border-gray-400">
                <input type="email" placeholder="Your Email" class="w-full px-2 py-1 text-gray-600 outline-none">
                <button class="bg-orange-500 text-white px-4 py-2 ml-2 rounded">Submit</button>
            </div>
        </div>
    </div>

    <!-- Social Media -->
<div class="max-w-7xl mx-auto mt-6 flex justify-end space-x-4">
    <a href="https://www.facebook.com/" target="_blank">
        <img src="https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg" alt="Facebook" class="h-6">
    </a>
    <a href="https://twitter.com/" target="_blank">
        <img src="https://abs.twimg.com/favicons/twitter.2.ico" alt="X (Twitter)" class="h-6">
    </a>
    <a href="https://www.pinterest.com/" target="_blank">
        <img src="https://upload.wikimedia.org/wikipedia/commons/3/35/Pinterest_Logo.svg" alt="Pinterest" class="h-6">
    </a>
    <a href="https://www.tiktok.com/" target="_blank">
        <img src="https://upload.wikimedia.org/wikipedia/en/a/a9/TikTok_logo.svg" alt="TikTok" class="h-6">
    </a>
    <a href="https://www.instagram.com/" target="_blank">
        <img src="https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png" alt="Instagram" class="h-6">
    </a>
</div>



    <!-- Copyright -->
    <div class="text-center text-gray-500 text-sm mt-4">
        ©2025 RoadTripRent. All Rights Reserved
    </div>
</footer>





</body>
</html>
