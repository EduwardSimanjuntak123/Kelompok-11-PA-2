<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password</title>
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
            <div class="step">1</div>
            <div class="step">2</div>
            <div class="step active">3</div>
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

        <form method="POST" action="{{ route('vendor.password.update') }}">
            @csrf
            <!-- Password Lama -->
            <div class="mb-3">
                <label for="old_password" class="form-label">Password Lama</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                    <input type="password" id="old_password" name="old_password" class="form-control"
                        placeholder="••••••••" required>
                    <button class="btn btn-outline-secondary toggle-password" type="button" data-target="old_password">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <!-- Password Baru -->
            <div class="mb-3">
                <label for="new_password" class="form-label">Password Baru</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-shield-lock"></i></span>
                    <input type="password" id="new_password" name="new_password" class="form-control"
                        placeholder="Minimal 8 karakter" required>
                    <button class="btn btn-outline-secondary toggle-password" type="button" data-target="new_password">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-100">
                <i class="bi bi-arrow-repeat me-2"></i>Perbarui Password
            </button>
        </form>

        <div class="text-center mt-4">
            <a href="{{ route('vendor.otp.request') }}" class="btn btn-secondary w-100">
                <i class="bi bi-arrow-left-circle me-2"></i>Kembali
            </a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Handle success message
            @if (session('success'))
                Swal.fire({
                    icon: 'success',
                    title: 'Berhasil!',
                    text: '{{ session('success') }}',
                    confirmButtonColor: '#6366f1',
                    willClose: () => {
                        window.location.href = "{{ route('vendor.profile', ['id' => $userId]) }}";
                    }
                });
            @endif

            // Handle error message
            @if (session('error'))
                Swal.fire({
                    icon: 'error',
                    title: 'Gagal!',
                    text: '{{ session('error') }}',
                    confirmButtonColor: '#6366f1'
                });
            @endif
        });

        document.querySelectorAll('.toggle-password').forEach(button => {
            button.addEventListener('click', function() {
                const targetInput = document.getElementById(this.dataset.target);
                const icon = this.querySelector('i');

                if (targetInput.type === 'password') {
                    targetInput.type = 'text';
                    icon.classList.remove('bi-eye');
                    icon.classList.add('bi-eye-slash');
                } else {
                    targetInput.type = 'password';
                    icon.classList.remove('bi-eye-slash');
                    icon.classList.add('bi-eye');
                }
            });
        });
    </script>
</body>

</html>
