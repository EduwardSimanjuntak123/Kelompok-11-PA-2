import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/motor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MotorListScreen(),
    );
  }
}


class MotorListScreen extends StatefulWidget {
  @override
  _MotorListScreenState createState() => _MotorListScreenState();
}

class _MotorListScreenState extends State<MotorListScreen> {
  late Future<List<Motor>> futureMotors;

  @override
  void initState() {
    super.initState();
    futureMotors = ApiService().fetchMotors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Motor")),
      body: FutureBuilder<List<Motor>>(
        future: futureMotors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Tidak ada data motor"));
          }

          List<Motor> motors = snapshot.data!;

          return ListView.builder(
            itemCount: motors.length,
            itemBuilder: (context, index) {
              final motor = motors[index];
              return ListTile(
                title: Text(motor.name),
                subtitle: Text("${motor.brand} - Rp${motor.pricePerDay}/hari"),
                trailing: Text(motor.status),
              );
            },
          );
        },
      ),
    );
  }
}
