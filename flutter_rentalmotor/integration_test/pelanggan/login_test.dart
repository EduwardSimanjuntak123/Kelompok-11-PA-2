import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_rentalmotor/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Pelanggan berhasil login dan masuk ke homepage', (tester) async {
    // 1. Jalankan aplikasi dan tunggu splash
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 6));
    debugPrint('\x1B[32mSelesai menunggu splash screen\x1B[0m');

    // 2. Run flow login
    await tester.runAsync(() async {
      await loginSebagaiPelanggan(
        tester,
        email: 'boasrayhanturnip@gmail.com',
        password: 'password',
      );
    });

    // 3. Tunggu semua animasi & navigasi selesai
    await tester.pumpAndSettle();

    // 4. **Verifikasi** bahwa homepage muncul
    final homepageFinder = find.byKey(const Key('homepageTitle'));
    expect(
      homepageFinder,
      findsOneWidget,
      reason: 'Tidak berhasil navigasi ke halaman utama',
    );
    debugPrint('\x1B[32m[Test] Berhasil menemukan homepageTitle\x1B[0m');
  });
}

/// Reusable login flow
Future<void> performLogin(
  WidgetTester tester, {
  required String email,
  required String password,
  bool isGuest = true,
}) async {
  // 1) Tap guest login jika perlu
  if (isGuest) {
    final guestBtn = find.byKey(const Key('guestLoginButton'));
    expect(guestBtn, findsOneWidget,
        reason: 'Tombol login guest tidak ditemukan');
    await tester.tap(guestBtn);
    await tester.pumpAndSettle();
  }

  // 2) Isi form
  await tester.enterText(find.byKey(const Key('emailField')), email);
  await tester.enterText(find.byKey(const Key('passwordField')), password);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  // 3) Tap login
  final loginBtn = find.byKey(const Key('loginButton'));
  expect(loginBtn, findsOneWidget, reason: 'Tombol login tidak ditemukan');
  await tester.tap(loginBtn);
  await tester.pumpAndSettle();

  // 4) Tunggu popup, lalu tap “Lanjutkan”
  await tester.pump(const Duration(seconds: 1));
  await _waitForAndTap(tester, find.byKey(const Key('lanjutkanButton')));

  // 5) Beri waktu untuk pop + push replacement
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

/// Wrapper khusus pelanggan
Future<void> loginSebagaiPelanggan(
  WidgetTester tester, {
  required String email,
  required String password,
}) =>
    performLogin(tester, email: email, password: password, isGuest: true);

/// Helper: tunggu suatu Finder lalu tap
Future<void> _waitForAndTap(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      return;
    }
  }
  fail('Finder $finder tidak muncul dalam $timeout');
}
