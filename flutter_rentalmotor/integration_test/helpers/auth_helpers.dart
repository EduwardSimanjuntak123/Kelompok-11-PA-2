import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

/// Fungsi utama reusable untuk login
Future<void> performLogin(
  WidgetTester tester, {
  required String email,
  required String password,
  bool isGuest = true,
  Key guestLoginKey = const Key('guestLoginButton'),
  Key emailFieldKey = const Key('emailField'),
  Key passwordFieldKey = const Key('passwordField'),
  Key loginButtonKey = const Key('loginButton'),
  Key homepageKey = const Key('homepageTitle'),
}) async {
  if (isGuest) {
    final guestLoginButton = find.byKey(guestLoginKey);
    expect(guestLoginButton, findsOneWidget,
        reason: 'Tombol login guest tidak ditemukan');
    await tester.tap(guestLoginButton);
    await tester.pumpAndSettle();
  }

  await tester.enterText(find.byKey(emailFieldKey), email);
  await tester.enterText(find.byKey(passwordFieldKey), password);

  debugPrint('\x1B[32m[LOGIN] Email dan password berhasil dimasukkan\x1B[0m');

  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  final loginButton = find.byKey(loginButtonKey);
  expect(loginButton, findsOneWidget, reason: 'Tombol login tidak ditemukan');
  await tester.tap(loginButton);
  await tester.pumpAndSettle();
  debugPrint('\x1B[32m[LOGIN] Tombol login berhasil ditekan\x1B[0m');
  await tester.pumpAndSettle(const Duration(seconds: 2));
  debugPrint('[INFO] Menunggu dialog muncul...');
  await handleSuccessDialog(tester);

  await tester.pump(const Duration(seconds: 2));

  await tester.pumpAndSettle();

  expect(find.byKey(homepageKey), findsOneWidget,
      reason: 'Tidak menemukan homepage setelah login');
  debugPrint(
      '\x1B[32m[LOGIN] Berhasil login dan masuk ke halaman utama\x1B[0m');
}

/// Ekstensi untuk menunggu elemen ditemukan
extension PumpUntilFoundExtension on WidgetTester {
  Future<bool> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration step = const Duration(milliseconds: 200),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      await pump(step);
      if (any(finder)) return true;
    }
    return false;
  }
}

/// Login sebagai pelanggan
Future<void> loginSebagaiPelanggan(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await performLogin(tester, email: email, password: password, isGuest: true);
}

/// Login sebagai vendor
Future<void> loginSebagaiVendor(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await performLogin(tester, email: email, password: password, isGuest: false);
}

/// Fungsi untuk menangani dialog sukses login
/// Fungsi untuk menangani dialog sukses login hanya dengan strategi 1
Future<void> handleSuccessDialog(WidgetTester tester) async {
  debugPrint('[INFO] Menangani dialog sukses login...');

  // Tunggu agar dialog sempat muncul
  await tester.pumpAndSettle(Duration(seconds: 2));

  // Cari dialog
  final dialogFinder = find.byKey(const Key('successDialog'));
  expect(dialogFinder, findsOneWidget, reason: 'Dialog sukses tidak muncul');

  // Cari tombol lanjutkan
  final lanjutkanBtn = find.byKey(const Key('lanjutkanButton'));
  expect(lanjutkanBtn, findsOneWidget,
      reason: 'Tombol Lanjutkan tidak ditemukan');

  await tester.ensureVisible(lanjutkanBtn);
  await tester.tap(lanjutkanBtn);
  debugPrint('[SUKSES] Tombol lanjutkan ditekan');

  // Tunggu navigasi
  await tester.pumpAndSettle(const Duration(seconds: 1));
}
