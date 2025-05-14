<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verifikasi OTP</title>
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

        #loading-overlay {
            display: none;
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

        <div class="step-indicator">
            <div class="step">1</div>
            <div class="step active">2</div>
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

        <form method="POST" action="{{ route('vendor.otp.verify') }}">
            @csrf
            <input type="hidden" name="email" value="{{ $email }}">
            <div class="mb-3">
                <label for="otp" class="form-label">Kode Verifikasi</label>
                <div class="input-group">
                    <span class="input-group-text">
                        <i class="bi bi-key"></i>
                    </span>
                    <input type="text" name="otp" class="form-control" placeholder="Masukkan 6 digit kode"
                        maxlength="6">
                </div>
                <small class="text-muted">Cek email Anda untuk kode verifikasi</small>
            </div>
            <button type="submit" class="btn btn-primary w-100">
                <i class="bi bi-check-circle me-2"></i>Verifikasi Kode
            </button>
        </form>

        <div class="text-center mt-2">
            <a href="{{ route('vendor.otp.request') }}" class="btn btn-secondary w-100">
                <i class="bi bi-arrow-left-circle me-2"></i>Kembali ke Langkah 1
            </a>
        </div>
    </div>

    <div id="loading-overlay">
        <div class="d-flex justify-content-center align-items-center"
            style="position: fixed; inset: 0; background-color: rgba(255,255,255,0.8); z-index: 9999;">
            <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
                <span class="visually-hidden">Loading...</span>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        document.querySelector("form").addEventListener("submit", function(e) {
            const otpInput = this.querySelector("input[name='otp']");
            const otpValue = otpInput.value.trim();

            if (!/^\d{6}$/.test(otpValue)) {
                e.preventDefault();

                Swal.fire({
                    icon: 'error',
                    title: 'Kode OTP tidak valid',
                    text: 'Kode OTP harus terdiri dari 6 digit angka.',
                    confirmButtonColor: '#6366f1'
                });

                otpInput.focus();
            } else {
                // OTP valid, tampilkan loading
                document.getElementById("loading-overlay").style.display = "block";
            }
        });

        // Loading saat klik tombol navigasi (misalnya "Kembali ke langkah 1")
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
