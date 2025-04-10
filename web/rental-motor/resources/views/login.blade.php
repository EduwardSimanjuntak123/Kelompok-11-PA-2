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
            justify-content: flex-end;
            padding-right: 5%;
        }

        .text-custom-orange {
            color: #FEA501;
        }
    </style>
</head>

<body>
    <div class="inner-background">
        <div class="bg-white bg-opacity-90 p-8 rounded-lg shadow-2xl w-96">
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

                <div class="mt-4">
                    <label class="block text-gray-700 font-semibold">Email</label>
                    <div class="flex items-center border rounded-md px-3 py-2 mt-1 bg-gray-100">
                        <img src="{{ asset('user.png') }}" alt="User Logo" class="w-5 h-5 flex-shrink-0 mr-2">
                        <input type="email" name="email" placeholder="Email"
                            class="w-full bg-transparent focus:outline-none" required>
                    </div>
                </div>

                <div class="mt-4">
                    <label class="block text-gray-700 font-semibold">Password</label>
                    <div class="flex items-center border rounded-md px-3 py-2 mt-1 bg-gray-100">
                        <img src="{{ asset('eyeslash.svg') }}" alt="Toggle Password" id="togglePassword"
                            class="w-5 h-5 cursor-pointer mr-2">
                        <input type="password" name="password" id="passwordInput" placeholder="Password"
                            class="w-full bg-transparent focus:outline-none" required>
                    </div>
                </div>

                <script>
                    const togglePassword = document.getElementById('togglePassword');
                    const passwordInput = document.getElementById('passwordInput');
                    let isPasswordVisible = false;

                    togglePassword.addEventListener('click', function () {
                        isPasswordVisible = !isPasswordVisible;
                        passwordInput.type = isPasswordVisible ? 'text' : 'password';

                        // Ganti ikon jika perlu
                        togglePassword.src = isPasswordVisible
                            ? "{{ asset('eyesolid.svg') }}"
                            : "{{ asset('eyeslash.svg') }}";
                    });
                </script>


                <button type="submit"
                    class="w-full mt-6 bg-[#FEA501] hover:bg-orange-600 text-white font-bold py-2 px-4 rounded-lg transition">
                    LOGIN
                </button>

                <a href="{{ url('/') }}" class="block text-center text-blue-700 font-semibold underline text-base mt-4 hover:text-blue-900">
                    Back
                </a>

            </form>
        </div>
    </div>
</body>

</html>
