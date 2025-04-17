// lib/models/motor_model.dart

class MotorModel {
  final int id;
  final String name;
  final String brand;
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

  // Method to convert motor model into JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'year': year,
      'price': price,
      'color': color,
      'status': status,
      'type': type,
      'description': description,
      'image': image,
      'rating': rating,
    };
  }
}
