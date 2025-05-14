<!DOCTYPE html>
<html>

<head>
    <title>Verifikasi OTP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">
    <div class="container mt-5">
        <h2 class="mb-4">Verifikasi OTP & Reset Password</h2>

        @if (session('success'))
            <div class="alert alert-success">{{ session('success') }}</div>
        @elseif(session('error'))
            <div class="alert alert-danger">{{ session('error') }}</div>
        @endif

        {{-- Form Request OTP --}}
        <form method="POST" action="{{ route('otp.request') }}" class="mb-4">
            @csrf
            <div class="mb-3">
                <label for="email" class="form-label">Alamat Email</label>
                <input type="email" name="email" class="form-control" required
                    value="{{ $user['email'] ?? old('email') }}">
            </div>
            <button type="submit" class="btn btn-primary">Kirim OTP</button>
        </form>

        {{-- Form Verifikasi OTP --}}
        @if (session('show_otp_form') || session('show_reset_form'))
            <form method="POST" action="{{ route('otp.verify') }}" class="mb-4">
                @csrf
                <input type="hidden" name="email" value="{{ $user['email'] ?? old('email') }}">
                <div class="mb-3">
                    <label for="otp" class="form-label">Kode OTP (6 Digit)</label>
                    <input type="text" name="otp" class="form-control" maxlength="6" required>
                </div>
                <button type="submit" class="btn btn-success">Verifikasi OTP</button>
            </form>
        @endif

        {{-- Form Reset Password --}}
        @if (session('show_reset_form'))
            <form method="POST" action="{{ route('otp.reset') }}">
                @csrf
                <div class="mb-3">
                    <label for="old_password" class="form-label">Password Lama</label>
                    <input type="password" name="old_password" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label for="new_password" class="form-label">Password Baru</label>
                    <input type="password" name="new_password" class="form-control" required>
                </div>
                <button type="submit" class="btn btn-warning">Ubah Password</button>
            </form>
        @endif
    </div>
</body>

</html>
