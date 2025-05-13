<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>OTP Verification</title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>

<body class="bg-gray-50 min-h-screen flex items-center justify-center p-4">
    <div class="max-w-md w-full bg-gradient-to-br from-white to-blue-50 rounded-2xl shadow-xl overflow-hidden">
        <div class="p-8">
            <!-- Header with animated icon -->
            <div class="text-center mb-8">
                <div class="relative inline-flex items-center justify-center w-16 h-16 mb-4">
                    <div class="absolute inset-0 bg-blue-100 rounded-full animate-pulse"></div>
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 relative text-blue-600" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                </div>
                <h2 class="text-2xl font-bold text-gray-800 mb-2">OTP Verification</h2>
                <p class="text-gray-600">We've sent a 6-digit code to your email</p>
                <p class="text-sm text-gray-500 mt-1">{{ substr($email, 0, 3) . '****' . substr($email, strpos($email, '@')) }}</p>
            </div>

            <!-- Status message -->
            @if (session('status'))
                <div class="bg-green-50 border-l-4 border-green-500 p-4 rounded-lg mb-6 flex items-start">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500 mr-2 mt-0.5"
                        viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd"
                            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                            clip-rule="evenodd" />
                    </svg>
                    <span class="text-green-700">{{ session('status') }}</span>
                </div>
            @endif

            @if ($errors->any())
                <div class="bg-red-50 border-l-4 border-red-500 p-4 rounded-lg mb-6">
                    <div class="flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-500 mr-2" viewBox="0 0 20 20"
                            fill="currentColor">
                            <path fill-rule="evenodd"
                                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                                clip-rule="evenodd" />
                        </svg>
                        <span class="font-medium text-red-700">Please fix these errors:</span>
                    </div>
                    <ul class="mt-2 list-disc list-inside text-sm text-red-600">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <!-- OTP form -->
            <form action="{{ route('otp.verify') }}" method="POST" class="space-y-6">
                @csrf
                <input type="hidden" name="email" value="{{ $email }}">

                <!-- OTP Input -->
                <div class="space-y-2">
                    <label for="otp" class="block text-sm font-medium text-gray-700">Enter 6-digit OTP</label>
                    <div class="flex space-x-2">
                        @for ($i = 1; $i <= 6; $i++)
                            <input type="text" name="otp[]" maxlength="1"
                                class="w-12 h-12 text-center text-2xl font-bold border-2 border-gray-300 rounded-lg focus:border-blue-500 focus:ring-blue-500"
                                oninput="this.value=this.value.replace(/[^0-9]/g,'');if(this.value.length==1){document.getElementById('otp{{ $i+1 }}')?.focus()}">
                        @endfor
                    </div>
                    @error('otp')
                        <p class="text-sm text-red-600">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Resend OTP -->
                <div class="text-center text-sm text-gray-600">
                    Didn't receive code? <button type="button" onclick="resendOtp()" id="resendButton"
                        class="text-blue-600 hover:text-blue-800 font-medium">Resend OTP</button>
                    <span id="countdown" class="hidden text-gray-500">in <span id="timer">60</span> seconds</span>
                </div>

                <!-- Button group -->
                <div class="flex justify-between space-x-4">
                    <!-- Back button -->
                    <button type="button" onclick="window.history.back()"
                        class="flex-1 py-3 px-6 bg-white border border-gray-300 rounded-lg shadow-sm text-gray-700 font-medium hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 transition-all duration-300">
                        <span class="flex items-center justify-center">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                            </svg>
                            Back
                        </span>
                    </button>

                    <!-- Submit button -->
                    <button type="submit"
                        class="flex-1 py-3 px-6 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 rounded-lg shadow-md text-white font-semibold transition-all duration-300 transform hover:scale-[1.02] focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-50">
                        <span class="flex items-center justify-center">
                            Verify OTP
                        </span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Auto focus first OTP input
        document.querySelector('input[name="otp[]"]').focus();

        // Auto move to next input
        document.querySelectorAll('input[name="otp[]"]').forEach((input, index, inputs) => {
            input.addEventListener('input', (e) => {
                if (e.target.value.length === 1 && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
            });

            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && e.target.value.length === 0 && index > 0) {
                    inputs[index - 1].focus();
                }
            });
        });

        // Resend OTP functionality
        function resendOtp() {
            fetch('{{ route('otp.resend') }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    },
                    body: JSON.stringify({
                        email: '{{ $email }}'
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('New OTP has been sent to your email');
                        startCountdown();
                    } else {
                        alert('Failed to resend OTP. Please try again.');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred. Please try again.');
                });
        }

        // Countdown timer
        function startCountdown() {
            const resendButton = document.getElementById('resendButton');
            const countdown = document.getElementById('countdown');
            const timer = document.getElementById('timer');
            
            resendButton.classList.add('hidden');
            countdown.classList.remove('hidden');
            
            let timeLeft = 60;
            const interval = setInterval(() => {
                timeLeft--;
                timer.textContent = timeLeft;
                
                if (timeLeft <= 0) {
                    clearInterval(interval);
                    resendButton.classList.remove('hidden');
                    countdown.classList.add('hidden');
                }
            }, 1000);
        }

        // Start countdown on page load
        window.onload = startCountdown;
    </script>
</body>

</html>