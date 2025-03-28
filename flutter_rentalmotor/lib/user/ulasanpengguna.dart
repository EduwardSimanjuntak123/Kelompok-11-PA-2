import 'package:flutter/material.dart';

class UlasanPenggunaVendorScreen extends StatelessWidget {
  const UlasanPenggunaVendorScreen({Key? key}) : super(key: key);

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
        backgroundColor: const Color(0xFF2C567E), // Warna biru sesuai gambar
        elevation: 2, // Tambahkan sedikit bayangan
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildReviewCard('Boas Rayhan Turnip', 5, 'Pelayanan sangat baik dan motor dalam kondisi bagus!'),
          buildReviewCard('Eduward Simanjuntak', 4, 'Motor cukup nyaman digunakan, hanya saja perlu sedikit perawatan.'),
          buildReviewCard('Grace Yosephine', 4, 'Respon cepat dan unit sesuai dengan deskripsi. Terima kasih!'),
        ],
      ),
    );
  }

  Widget buildReviewCard(String name, int rating, String review) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      color: Colors.white, 
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/c2.png'), // Pastikan path gambar benar
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
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review,
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
}
