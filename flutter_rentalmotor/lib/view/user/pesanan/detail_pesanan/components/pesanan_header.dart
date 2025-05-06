import 'package:flutter/material.dart';

class PesananHeader extends StatelessWidget {
  final String motorName;
  final String motorBrand;
  final String motorModel;
  final String imageUrl;

  const PesananHeader({
    Key? key,
    required this.motorName,
    required this.motorBrand,
    required this.motorModel,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Motor Image
        Container(
          height: 240,
          width: double.infinity,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: Icon(Icons.image_not_supported,
                  size: 40, color: Colors.grey[600]),
            ),
          ),
        ),
        // Gradient Overlay
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // Motor Name
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                motorName.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                "$motorBrand $motorModel",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
