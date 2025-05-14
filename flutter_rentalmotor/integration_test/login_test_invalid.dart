import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_rentalmotor/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login gagal dengan email/password salah', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Tunggu splash screen selesai
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Tap tombol login sebagai guest
    final loginButton = find.byKey(const Key('guestLoginButton'));
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Masukkan email dan password yang salah
    await tester.enterText(
        find.byKey(const Key('emailField')), 'salah@email.com');
    await tester.enterText(
        find.byKey(const Key('passwordField')), 'salahpassword');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Tap tombol login
    final masukButton = find.byKey(const Key('loginButton'));
    expect(masukButton, findsOneWidget);
    await tester.tap(masukButton);
    await tester.pump(const Duration(seconds: 2)); // Menunggu respons API

    // Verifikasi bahwa muncul dialog error atau tidak pindah ke homepage
    expect(find.byKey(const Key('homepageTitle')), findsNothing,
        reason: 'Seharusnya tidak masuk ke homepage dengan login gagal');

    // Coba deteksi apakah muncul AlertDialog dengan pesan error
    expect(find.byType(AlertDialog), findsOneWidget,
        reason: 'Dialog error login tidak muncul');
  });
}
