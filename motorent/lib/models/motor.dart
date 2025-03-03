import 'dart:convert';

class Motor {
  final int id;
  final String name;
  final String brand;
  final int pricePerDay;
  final String status;

  Motor({required this.id, required this.name, required this.brand, required this.pricePerDay, required this.status});

  factory Motor.fromJson(Map<String, dynamic> json) {
    return Motor(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      pricePerDay: json['price_per_day'],
      status: json['status'],
    );
  }
}
