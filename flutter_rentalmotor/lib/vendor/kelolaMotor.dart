import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/services/vendor_motor_api.dart'; // Import VendorMotorApi
import 'package:flutter_rentalmotor/models/motor_model.dart'; // Import MotorModel
import 'package:flutter_rentalmotor/vendor/motor_detail_screen.dart'; // Import MotorDetailScreen
import 'package:flutter_rentalmotor/vendor/CreateMotorScreen.dart'; // Import CreateMotorScreen

class KelolaMotorScreen extends StatefulWidget {
  @override
  _KelolaMotorScreenState createState() => _KelolaMotorScreenState();
}

class _KelolaMotorScreenState extends State<KelolaMotorScreen> {
  bool isLoading = true; // Menentukan status loading
  List<MotorModel> motorList = []; // Menyimpan daftar motor

  // Memanggil API ketika halaman pertama kali dimuat
  @override
  void initState() {
    super.initState();
    fetchMotorData(); // Memanggil fungsi fetchMotorData saat halaman pertama kali dibuka
  }

  // Memanggil fetchMotorData dari VendorMotorApi
  Future<void> fetchMotorData() async {
    try {
      // Membuat objek VendorMotorApi untuk mengakses API
      VendorMotorApi api = VendorMotorApi();

      // Mendapatkan data motor dari API
      List<dynamic> data = await api.fetchMotorData();

      // Mengonversi data Map ke dalam objek MotorModel
      List<MotorModel> motorData = data.map((motorJson) => MotorModel.fromJson(motorJson)).toList();

      // Menyimpan hasil data yang didapat ke dalam state motorList
      setState(() {
        motorList = motorData;
        isLoading = false; // Mengubah status loading menjadi false setelah data diterima
      });
    } catch (e) {
      // Jika terjadi error, tampilkan pesan error menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false; // Menyelesaikan status loading meski ada error
      });
    }
  }

  // Fungsi untuk menangani refresh saat menggulir ke bawah
  Future<void> _handleRefresh() async {
    // Panggil fetchMotorData lagi untuk mendapatkan data terbaru
    await fetchMotorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Motor'), // Judul halaman
      ),
      body: RefreshIndicator(
        // Menambahkan RefreshIndicator untuk swipe-to-refresh
        onRefresh: _handleRefresh, // Fungsi yang dipanggil saat swipe ke bawah
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Menampilkan loading spinner saat menunggu data
            : ListView.builder(
                itemCount: motorList.length, // Menentukan jumlah item yang akan ditampilkan
                itemBuilder: (context, index) {
                  MotorModel motor = motorList[index]; // Mendapatkan objek motor per item
                  return ListTile(
                    title: Text(motor.name), // Nama motor
                    subtitle: Text('Tahun: ${motor.year}'), // Tahun motor
                    trailing: Text('Status: ${motor.status}'), // Status motor
                    onTap: () {
                      // Arahkan ke halaman MotorDetailScreen untuk menampilkan detail motor
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MotorDetailScreen(motor: motor),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      // FloatingActionButton untuk menambah motor
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman CreateMotorScreen untuk menambah motor
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMotorScreen()),
          ).then((_) => fetchMotorData()); // Setelah kembali dari halaman create motor, refresh daftar motor
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: 'Tambah Motor',
      ),
    );
  }
}
