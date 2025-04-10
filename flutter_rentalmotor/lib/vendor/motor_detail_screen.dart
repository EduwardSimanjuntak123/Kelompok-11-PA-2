import 'package:flutter/material.dart';

class MotorDetailScreen extends StatelessWidget {
  final MotorModel motor;

  const MotorDetailScreen({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    final imageUrl = motor.image != null
        ? 'http://192.168.132.159:8080${motor.image}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(motor.name),
        backgroundColor: const Color(0xFF1A567D),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.motorcycle,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motor.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${motor.brand} ${motor.model} (${motor.year})',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Harga: Rp ${motor.price.toStringAsFixed(0)} / hari",
                    style:
                        const TextStyle(fontSize: 16, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text("${motor.rating}/5"),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tipe: ${motor.type}",
                          style: const TextStyle(fontSize: 16)),
                      Text("Warna: ${motor.color}",
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Status: ${motor.status}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text("Deskripsi",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(motor.description, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model motor langsung di bawah
class MotorModel {
  final int id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String color;
  final String status;
  final String type;
  final String description;
  final String? image;
  final double rating;

  MotorModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.color,
    required this.status,
    required this.type,
    required this.description,
    required this.image,
    required this.rating,
  });

  factory MotorModel.fromJson(Map<String, dynamic> json) {
    return MotorModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      price: (json['price'] as num).toDouble(),
      color: json['color'],
      status: json['status'],
      type: json['type'],
      description: json['description'] ?? '',
      image: json['image'],
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
