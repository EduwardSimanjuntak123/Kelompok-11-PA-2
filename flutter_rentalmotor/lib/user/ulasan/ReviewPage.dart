import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/services/customer/review_service.dart';

class ReviewPage extends StatefulWidget {
  final int bookingId;

  const ReviewPage({Key? key, required this.bookingId}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;

  // Blue theme colors
  final Color primaryBlue = Color(0xFF2C567E);

  // Flutter secure storage instance
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Function to get the auth token
  Future<String?> _getAuthToken() async {
    return await _storage.read(key: "auth_token");
  }

  // Use the ReviewService to submit the review
  Future<void> submitReview() async {
    if (_reviewController.text.isEmpty) {
      // If review is empty, show a message and return early
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ulasan tidak boleh kosong.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Get the auth token
    final token = await _getAuthToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Token tidak ditemukan. Harap login kembali.")),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Convert rating to an integer before sending
    final intRating = _rating.toInt(); // Convert the rating to an integer

    // Call ReviewService to post the review
    final reviewService = ReviewService();
    final success = await reviewService.submitReview(
        widget.bookingId, intRating, _reviewController.text, token);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Review berhasil dikirim."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context); // Go back after submitting
    } else {
      // Handle the case where the user has already submitted a review
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anda sudah memberikan ulasan untuk booking ini"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Berikan Ulasan"),
        backgroundColor: primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Slider
            Text(
              "Rating:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            // Review TextField
            Text(
              "Review:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tulis ulasan Anda...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : submitReview,
              child: _isSubmitting
                  ? CircularProgressIndicator()
                  : Text("Kirim Ulasan"),
            ),
          ],
        ),
      ),
    );
  }
}
