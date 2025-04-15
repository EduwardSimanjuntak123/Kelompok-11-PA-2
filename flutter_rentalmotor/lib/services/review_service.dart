import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewService {
  Future<bool> submitReview(
      int bookingId, int rating, String review, String token) async {
    final url =
        Uri.parse('http://192.168.168.159:8080/customer/review/$bookingId');

    // Create the request body in the correct format
    final requestBody = {
      'rating': rating, // Now, rating is an integer
      'review': review,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token to the request header
      },
      body: json.encode(requestBody), // Send the body as JSON
    );

    // Check if the response indicates the user has already submitted a review
    if (response.statusCode == 200) {
      return true;
    } else {
      // Check if the response body contains the specific error message
      if (response.body
          .contains("Anda sudah memberikan ulasan untuk booking ini")) {
        return false; // Indicate that the review was already submitted
      }
      return false; // Other errors
    }
  }
}
