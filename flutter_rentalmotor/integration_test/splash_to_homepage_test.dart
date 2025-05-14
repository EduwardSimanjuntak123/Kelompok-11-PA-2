import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_rentalmotor/main.dart';

void main() {
  // Inisialisasi test binding khusus untuk integration test.
  // Ini memungkinkan Flutter menjalankan test seperti pengguna sungguhan.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mulai test dengan deskripsi: 'navigasi dari splash ke homepage user'
  testWidgets('navigasi dari splash ke homepage user', (tester) async {
    
    // Menjalankan aplikasi secara penuh dari widget utama (MyApp)
    await tester.pumpWidget(const MyApp());

    // Mengecek apakah logo splash screen muncul (berdasarkan key 'splashLogo')
    expect(find.byKey(ValueKey('splashLogo')), findsOneWidget);

    // Menunggu sampai semua animasi dan transisi selesai (maks 6 detik)
    // Ini menunggu splash screen selesai dan navigasi otomatis ke homepage
    await tester.pumpAndSettle(const Duration(seconds: 6));

    // Memastikan bahwa widget dengan key 'homepageTitle' ditemukan,
    // yang menandakan bahwa kita sudah berada di halaman HomePageUser
    expect(find.byKey(ValueKey('homepageTitle')), findsOneWidget);
  });
}
