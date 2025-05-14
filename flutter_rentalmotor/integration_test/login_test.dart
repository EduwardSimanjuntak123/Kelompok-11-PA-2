import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_rentalmotor/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login user berhasil dan langsung masuk ke homepage',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    // Tunggu splash screen selesai
    await tester.pumpAndSettle(const Duration(seconds: 8));
    debugPrint('\x1B[32m✅ Selesai menunggu splash screen\x1B[0m');

    // Cari dan tap tombol login guest
    final loginButton = find.byKey(const Key('guestLoginButton'));
    expect(loginButton, findsOneWidget,
        reason: '❌ Tombol login guest tidak ditemukan');
    debugPrint('\x1B[32m✅ Tombol login guest ditemukan\x1B[0m');

    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    debugPrint('\x1B[32m✅ Tombol login guest berhasil ditap\x1B[0m');

    // Masukkan email dan password
    await tester.enterText(
        find.byKey(const Key('emailField')), 'rentaledo@email.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password');
    debugPrint('\x1B[32m✅ Email dan password berhasil dimasukkan\x1B[0m');

    // Sembunyikan keyboard
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    debugPrint('\x1B[32m✅ Keyboard berhasil disembunyikan\x1B[0m');

    // Tap tombol login
    final masukButton = find.byKey(const Key('loginButton'));
    expect(masukButton, findsOneWidget,
        reason: '❌ Tombol login tidak ditemukan');
    debugPrint('\x1B[32m✅ Tombol login ditemukan\x1B[0m');

    await tester.tap(masukButton);
    debugPrint('\x1B[34mℹ️ Menunggu proses login...\x1B[0m');

    // Tambah waktu untuk login dan navigasi
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    debugPrint('\x1B[32m✅ Proses login selesai\x1B[0m');

    // Verifikasi berhasil login dan pindah ke homepage
    final homepageTitle = find.byKey(const Key('homepageTitle'));
    if (homepageTitle.evaluate().isNotEmpty) {
      debugPrint('\x1B[32m✅ Berhasil login dan homepageTitle ditemukan\x1B[0m');
    } else {
      debugPrint(
          '\x1B[31m❌ homepageTitle tidak ditemukan. Coba cek apakah key sudah benar\x1B[0m');
    }

    expect(homepageTitle, findsOneWidget,
        reason: '❌ Tidak dapat menemukan judul homepage');
  });
}
