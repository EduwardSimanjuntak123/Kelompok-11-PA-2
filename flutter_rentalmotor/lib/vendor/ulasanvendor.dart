import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UlasanVendorScreen extends StatefulWidget {
  const UlasanVendorScreen({Key? key}) : super(key: key);

  @override
  State<UlasanVendorScreen> createState() => _UlasanVendorScreenState();
}

class _UlasanVendorScreenState extends State<UlasanVendorScreen> {
  List<dynamic> reviews = [];
  bool isLoading = true;

  final String baseUrl = 'http://192.168.132.159:8080';
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/vendor/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('✅ Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> reviewJson = jsonDecode(response.body);
        setState(() {
          reviews = reviewJson;
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat ulasan: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildReviewCard(dynamic review) {
    final customer = review['customer'];
    final name = customer != null
        ? customer['name'] ?? 'Tidak diketahui'
        : 'Tidak diketahui';
    final rating = review['rating'] ?? 0;
    final reviewText = review['review'] ?? '';
    final profileImage = customer?['profile_image'] ?? '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage('$baseUrl$profileImage')
                  : const AssetImage('assets/images/c2.png') as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reviewText,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ulasan Pengguna',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF2C567E),
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
              ? const Center(child: Text('Belum ada ulasan.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return buildReviewCard(reviews[index]);
                  },
                ),
    );
  }
}
