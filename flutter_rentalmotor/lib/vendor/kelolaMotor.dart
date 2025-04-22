import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/services/vendor/vendor_motor_api.dart'; // Import VendorMotorApi
import 'package:flutter_rentalmotor/models/motor_model.dart'; // Import MotorModel
import 'package:flutter_rentalmotor/vendor/motor_detail_screen.dart'; // Import MotorDetailScreen
import 'package:flutter_rentalmotor/vendor/CreateMotorScreen.dart'; // Import CreateMotorScreen

class KelolaMotorScreen extends StatefulWidget {
  @override
  _KelolaMotorScreenState createState() => _KelolaMotorScreenState();
}

class _KelolaMotorScreenState extends State<KelolaMotorScreen> {
  bool isLoading = true;
  List<MotorModel> motorList = [];

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
        title: Text('Kelola Motor'),
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
                        title: Text(motor.name),
                        subtitle: Text('Tahun: ${motor.year}'),
                        trailing: Text('Status: ${motor.status}'),
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
