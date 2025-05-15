class MotorModel {
  final int id;
  final String name;
  final String plate;
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
    required this.plate,
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
      plate: json['platmotor'] ?? '', // Add this with null check
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plate': plate, // Add this
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
