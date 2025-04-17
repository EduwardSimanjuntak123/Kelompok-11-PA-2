<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LOGIN - Rental Motor</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            background: url("{{ asset('back4.jpg') }}") no-repeat center center/cover;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .inner-background {
            background: url("{{ asset('back3.jpg') }}") no-repeat center center/cover;
            width: 95%;
            height: 90%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 5%;
        }

        .text-custom-orange {
            color: #FEA501;
        }

        .error-message {
            color: #dc2626;
            /* Tailwind's red-600 */
            font-size: 0.875rem;
            /* text-sm */
            margin-top: 0.5rem;
            /* mt-2 */
        }
        
    @keyframes fade-right {
        0% {
            opacity: 0;
            transform: translateX(-20px);
        }
        100% {
            opacity: 1;
            transform: translateX(0);
        }
    }

    @keyframes zoom-in {
        0% {
            opacity: 0;
            transform: scale(0.9);
        }
        100% {
            opacity: 1;
            transform: scale(1);
        }
    }

    .animate-fade-right {
        animation: fade-right 1s ease-out forwards;
    }

    .animate-zoom-in {
        animation: zoom-in 1s ease-out forwards;
    }


    </style>
</head>

<body>
    <div class="inner-background">
        <div class="hidden md:flex w-1/2 pr-10 flex-col justify-center animate-fade-right">
            <h1 class="text-4xl font-bold text-[#FEA501] mb-4 leading-tight drop-shadow-lg">
                Portal Resmi Admin & Vendor MotorRent!
            </h1>
            <p class="text-lg text-gray-100 drop-shadow-md">
                Akses sistem pengelolaan rental motor secara efisien dan aman.
            </p>            
        </div>
        
        <!-- Form Login -->
        <div class="bg-white bg-opacity-90 p-8 rounded-lg shadow-2xl w-96 animate-zoom-in">
            <div class="flex justify-center mb-4">
                <img src="{{ asset('logo.jpg') }}" alt="Motorrent Logo" class="w-24">
            </div>
            <h2 class="text-custom-orange text-center font-bold text-lg">MASUKKAN AKUN ANDA</h2>

            @if (session('error'))
                <p class="text-red-500 text-center mt-2">{{ session('error') }}</p>
            @endif
            @if (session('alert'))
                <div class="bg-red-500 text-white text-center p-2 rounded mb-4">
                    {{ session('alert') }}
                </div>
            @endif

            <form action="{{ route('login') }}" method="POST">
                @csrf

                <!-- Input Email -->
                <div class="mt-4">
                    <label class="block text-gray-700 font-semibold">Email</label>
                    <div class="flex items-center border rounded-md px-3 py-2 mt-1 bg-gray-100">
                        <img src="{{ asset('user.png') }}" alt="User Logo" class="w-5 h-5 flex-shrink-0 mr-2">
                        <input type="email" name="email" placeholder="Email"
                            class="w-full bg-transparent focus:outline-none appearance-none">
                    </div>
                    <div class="error-message" id="emailError"></div>
                </div>

                <!-- Input Password -->
                <div class="mt-4">
                    <label class="block text-gray-700 font-semibold">Password</label>
                    <div class="relative flex items-center border rounded-md px-3 py-2 mt-1 bg-gray-100">
                        <img src="{{ asset('eyeslash.svg') }}" alt="Toggle Password" id="togglePassword"
                            class="w-5 h-5 cursor-pointer mr-2">
                        <input type="password" name="password" id="passwordInput" placeholder="Password"
                            class="w-full bg-transparent focus:outline-none pr-2 appearance-none">
                    </div>
                    <div class="error-message" id="passwordError"></div>
                </div>

                <div class="error-message" id="generalError"></div>

                <!-- Script -->
                <script>
                    const togglePassword = document.getElementById('togglePassword');
                    const passwordInput = document.getElementById('passwordInput');
                    let isPasswordVisible = false;

                    togglePassword.addEventListener('click', function() {
                        isPasswordVisible = !isPasswordVisible;
                        passwordInput.type = isPasswordVisible ? 'text' : 'password';
                        togglePassword.src = isPasswordVisible ?
                            "{{ asset('eyesolid.svg') }}" :
                            "{{ asset('eyeslash.svg') }}";
                    });

                    const form = document.querySelector('form');
                    form.addEventListener('submit', function(event) {
                        document.getElementById('emailError').innerText = '';
                        document.getElementById('passwordError').innerText = '';
                        document.getElementById('generalError').innerText = '';

                        const email = document.querySelector('input[name="email"]');
                        const password = document.querySelector('input[name="password"]');
                        let isValid = true;

                        if (email.value.trim() === '') {
                            isValid = false;
                            document.getElementById('emailError').innerText = 'Email tidak boleh kosong.';
                        }

                        if (password.value.trim() === '') {
                            isValid = false;
                            document.getElementById('passwordError').innerText = 'Password tidak boleh kosong.';
                        }

                        if (!isValid) {
                            event.preventDefault();
                            return;
                        }

                        // Simulasi jika kombinasi email dan password salah
                        const isUsernameOrPasswordIncorrect = false;
                        if (isUsernameOrPasswordIncorrect) {
                            document.getElementById('generalError').innerText = 'Incorrect username or password';
                            event.preventDefault();
                        }
                    });
                </script>

                <button type="submit"
                    class="w-full mt-6 bg-[#FEA501] hover:bg-orange-600 text-white font-bold py-2 px-4 rounded-lg transition">
                    LOGIN
                </button>

                <a href="{{ url('/') }}"
                    class="block text-center text-blue-700 font-semibold underline text-base mt-4 hover:text-blue-900">
                    Back
                </a>
            </form>
        </div>
    </div>
</body>

</html>
