<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Permintaan OTP</title>
    <!-- Favicon Basic -->
    <link rel="icon" href="/logo2.png" type="image/png">

    <!-- Untuk browser modern -->
    <link rel="icon" type="image/png" sizes="32x32" href="/logo1.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/logo1.png">
    <link rel="apple-touch-icon" href="/logo1.png">

    <!-- Fallback untuk berbagai browser -->
    <link rel="shortcut icon" href="/logo1.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .auth-container {
            max-width: 600px;
            margin: 2rem auto;
            padding: 2rem;
            border-radius: 15px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
            background: white;
        }

        .auth-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .auth-header h2 {
            color: #2a2a2a;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .auth-header i {
            font-size: 2.5rem;
            color: #6366f1;
            margin-bottom: 1rem;
        }

        .form-control:focus {
            border-color: #818cf8;
            box-shadow: 0 0 0 3px rgba(129, 140, 248, 0.25);
        }

        .btn-primary {
            background: #6366f1;
            border: none;
            padding: 0.75rem 1.5rem;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            background: #4f46e5;
            transform: translateY(-1px);
        }

        .step-indicator {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .step {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #e0e7ff;
            color: #6366f1;
            font-weight: 600;
        }

        .step.active {
            background: #6366f1;
            color: white;
        }

        .back-button {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }

        .back-button:hover {
            text-decoration: none;
        }

        #loading-overlay {
            transition: opacity 0.3s ease;
        }
    </style>
</head>

<body style="background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); min-height: 100vh;">
    <div class="auth-container">
        <div class="auth-header">
            <i class="bi bi-shield-lock"></i>
            <h2>Verifikasi Keamanan</h2>
            <p class="text-muted">Lakukan verifikasi OTP dan reset password Anda</p>
        </div>
        @php
            $userRole = session('role', 'guest');
            $userId = session('user_id') ?? null;
        @endphp

        <div class="step-indicator">
            <div class="step active">1</div>
            <div class="step">2</div>
            <div class="step">3</div>
        </div>

        @if (session('success'))
            <div class="alert alert-success d-flex align-items-center">
                <i class="bi bi-check-circle-fill me-2"></i>
                {{ session('success') }}
            </div>
        @elseif(session('error'))
            <div class="alert alert-danger d-flex align-items-center">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                {{ session('error') }}
            </div>
        @endif

        <form method="POST" action="{{ route('vendor.otp.form') }}" class="mb-4">
            @csrf
            <div class="mb-3">
                <label for="email" class="form-label">Alamat Email</label>
                <div class="input-group">
                    <span class="input-group-text">
                        <i class="bi bi-envelope"></i>
                    </span>
                    <input type="email" name="email" class="form-control" placeholder="contoh@email.com" required
                        value="{{ $user['email'] ?? old('email') }}">
                </div>
            </div>
            <button type="submit" class="btn btn-primary w-100">
                <i class="bi bi-send-check me-2"></i>Kirim Kode OTP
            </button>
        </form>

        @if (session('show_otp_form'))
            <div class="mt-4">
                @include('vendor.otp_verify')
            </div>
        @endif

        <div class="text-center mt-2">
            <a href="{{ route('vendor.profile', ['id' => $userId]) }}" class="btn btn-secondary w-100">
                <i class="bi bi-arrow-left-circle me-2"></i>Kembali ke Profil
            </a>
        </div>
    </div>
    <div id="loading-overlay" style="display: none;">
        <div class="d-flex justify-content-center align-items-center"
            style="position: fixed; inset: 0; background-color: rgba(255,255,255,0.8); z-index: 9999;">
            <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
                <span class="visually-hidden">Loading...</span>
            </div>
        </div>
    </div>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Tampilkan loading saat form dikirim
        document.querySelectorAll("form").forEach(form => {
            form.addEventListener("submit", () => {
                document.getElementById("loading-overlay").style.display = "block";
            });
        });

        // Tampilkan loading saat klik tombol dengan class .btn yang menuju halaman lain
        document.querySelectorAll("a.btn, button[type=button]").forEach(el => {
            el.addEventListener("click", e => {
                const href = el.getAttribute("href");
                if (href && href !== "#" && !href.startsWith("javascript")) {
                    document.getElementById("loading-overlay").style.display = "block";
                }
            });
        });
    </script>

</body>

</html>
