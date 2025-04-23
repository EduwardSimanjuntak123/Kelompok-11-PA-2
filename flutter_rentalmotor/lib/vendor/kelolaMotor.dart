import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/services/vendor/vendor_motor_api.dart'; // Import VendorMotorApi
import 'package:flutter_rentalmotor/models/motor_model.dart'; // Import MotorModel
import 'package:flutter_rentalmotor/vendor/motor_detail_screen.dart'; // Import MotorDetailScreen
import 'package:flutter_rentalmotor/vendor/CreateMotorScreen.dart'; // Import CreateMotorScreen
import 'package:flutter_rentalmotor/config/api_config.dart';

class KelolaMotorScreen extends StatefulWidget {
  @override
  _KelolaMotorScreenState createState() => _KelolaMotorScreenState();
}

class _KelolaMotorScreenState extends State<KelolaMotorScreen> {
  bool isLoading = true;
  List<MotorModel> motorList = [];
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchMotorData();
  }

  // Fetching motor data from the API
  Future<void> fetchMotorData() async {
    try {
      VendorMotorApi api = VendorMotorApi();
      List<dynamic> data = await api.fetchMotorData();
      List<MotorModel> motorData =
          data.map((motorJson) => MotorModel.fromJson(motorJson)).toList();

      setState(() {
        motorList = motorData;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              fetchMotorData(); // Retry fetching motor data
            },
          ),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Handling the refresh action triggered by swipe-down
  Future<void> _handleRefresh() async {
    await fetchMotorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Motor',
            style: TextStyle(fontSize: 22)), // Memperbesar ukuran teks judul
        backgroundColor:
            const Color(0xFF1A567D), // Background AppBar menjadi biru
        titleTextStyle: TextStyle(color: Colors.white),
        // Mengubah warna teks menjadi putih
        iconTheme: IconThemeData(
            color: Colors
                .white), // Mengubah warna ikon (termasuk tombol back) menjadi putih
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : motorList.isEmpty
                ? Center(
                    child: Text(
                      'Motor belum didaftarkan',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: motorList.length,
                    separatorBuilder: (context, index) {
                      return Divider(); // Adds a divider between list items
                    },
                    itemBuilder: (context, index) {
                      MotorModel motor = motorList[index];
                      return ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        leading: motor.image != null
                            ? Image.network(
                                '$baseUrl${motor.image}', // Gambar motor dari URL
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors
                                    .grey), // Gambar default jika tidak ada
                        title: Text(
                          motor.name,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold), // Memperbesar nama motor
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tahun: ${motor.year}',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Deskripsi: ${motor.description}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: Text(
                          'Status: ${motor.status}',
                          style: TextStyle(
                            color: motor.status == 'available'
                                ? Colors.green
                                : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ), // Warna status menjadi hijau jika available
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MotorDetailScreen(
                                  motorId: motor.id), // Passing motor ID
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMotorScreen()),
          ).then((_) => fetchMotorData()); // Refresh after adding a motor
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: 'Tambah Motor',
      ),
    );
  }
}
