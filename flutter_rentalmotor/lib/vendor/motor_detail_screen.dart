import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/vendor/edit_motor_screen.dart';
import 'package:flutter_rentalmotor/models/motor_model.dart';
import 'package:flutter_rentalmotor/services/vendor/vendor_motor_api.dart'; // Add API service for fetching motor data
import 'package:http/http.dart' as http;

class MotorDetailScreen extends StatefulWidget {
  final int motorId;

  const MotorDetailScreen({super.key, required this.motorId});

  @override
  State<MotorDetailScreen> createState() => _MotorDetailScreenState();
}

class _MotorDetailScreenState extends State<MotorDetailScreen> {
  late MotorModel motor; // Create a local variable for motor

  bool isLoading = true; // Initially set loading to true

  @override
  void initState() {
    super.initState();
    motor = MotorModel(
        id: -1,
        name: '',
        brand: '',
        year: 0,
        price: 0,
        description: '',
        image: null,
        status: '',
        rating: 0,
        type: '',
        color: ''); // Initialize motor
    fetchMotorDetail(); // Initialize the local motor variable
  }

  Future<void> fetchMotorDetail() async {
    try {
      VendorMotorApi api = VendorMotorApi();
      motor =
          await api.fetchMotorDetail(widget.motorId); // Fetch motor data by ID

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Function to refresh data from the server
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch updated motor data from the API
      List<dynamic> motorData = await VendorMotorApi().fetchMotorData();

      // Find the updated motor data and create a new MotorModel instance
      final updatedMotor =
          motorData.firstWhere((motor) => motor['id'] == this.motor.id);

      setState(() {
        this.motor = MotorModel.fromJson(
            updatedMotor); // Assign the updated motor to the local variable
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data successfully updated')),
        );
      }
    } catch (e) {
      // If there's an error fetching data, stop loading and show an error message
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Function to delete motor by ID
  Future<void> _deleteMotor() async {
    try {
      VendorMotorApi api = VendorMotorApi();
      await api.deleteMotor(widget.motorId); // Call the delete API with motorId

      // Show success message and navigate back after deleting
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Motor successfully deleted')),
      );

      // Optionally, navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Handle error and show failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Navigate to EditMotorScreen
  void _navigateToEditScreen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: const [
              Icon(Icons.edit, color: Color(0xFF1976D2)),
              SizedBox(width: 10),
              Text("Edit Motor", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Do you want to edit this motor data?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMotorScreen(motor: motor),
                  ),
                ).then((_) => _refreshData()); // Refresh after edit
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
              ),
              child: const Text("Edit", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Confirm Deletion
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 10),
              Text("Delete Motor",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Are you sure you want to delete this motor?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteMotor(); // Delete motor
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child:
                  const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl = ApiConfig.baseUrl;
    final imageUrl = motor.image != null ? '$baseUrl${motor.image}' : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Motor Detail #${motor.id}'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while data is being fetched
          : RefreshIndicator(
              onRefresh: _refreshData, // Trigger refresh when user swipes down
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card with Image
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.motorcycle,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.motorcycle,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),

                            // Motor Info
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          motor.name,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: motor.status.toLowerCase() ==
                                                  'available'
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          motor.status,
                                          style: TextStyle(
                                            color: motor.status.toLowerCase() ==
                                                    'available'
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${motor.brand} (${motor.year})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 24),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${motor.rating}/5",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1976D2)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.monetization_on,
                                            color: Color(0xFF1976D2)),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Rp ${motor.price.toStringAsFixed(0)} / day",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1976D2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Specifications Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Specifications",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("Type: ${motor.type}"),
                              Text("Color: ${motor.color}"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Buttons at the Bottom
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _navigateToEditScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                              ),
                              child: const Text("Edit",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _confirmDelete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Delete",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
