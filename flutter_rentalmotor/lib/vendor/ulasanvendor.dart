import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/services/vendor_review_api.dart';

class UlasanVendorScreen extends StatefulWidget {
  const UlasanVendorScreen({Key? key}) : super(key: key);

  @override
  State<UlasanVendorScreen> createState() => _UlasanVendorScreenState();
}

class _UlasanVendorScreenState extends State<UlasanVendorScreen> {
  List<dynamic> reviews = [];
  bool isLoading = true;
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _isEditing = {}; // Set to track reviews being edited

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final reviewData = await VendorReviewApi.fetchReviews();
      setState(() {
        reviews = reviewData;
        isLoading = false;

        // Reset controller berdasarkan data baru
        _controllers.clear();
        for (var review in reviewData) {
          final id = review['id'].toString();
          final reply = review['vendor_reply'];
          _controllers[id] = TextEditingController(
            text: reply != null ? reply : '',
          );
        }
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Terjadi kesalahan saat memuat data ulasan')),
      );
    }
  }

  Future<void> _submitReply(String reviewId) async {
    final replyText = _controllers[reviewId]?.text.trim();
    if (replyText == null || replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Balasan tidak boleh kosong')),
      );
      return;
    }

    final success = await VendorReviewApi.replyToReview(reviewId, replyText);
    if (success) {
      print('Balasan berhasil dikirim');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil membalas ulasan')),
      );
      fetchReviews(); // Refresh setelah membalas
    } else {
      print('Gagal mengirim balasan');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membalas ulasan')),
      );
    }
  }

  Future<void> _editReply(String reviewId) async {
    final updatedReply = _controllers[reviewId]?.text.trim();
    if (updatedReply == null || updatedReply.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Balasan tidak boleh kosong')),
      );
      return;
    }

    final success = await VendorReviewApi.replyToReview(reviewId, updatedReply);
    if (success) {
      print('Balasan berhasil diperbarui');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil memperbarui balasan')),
      );
      setState(() {
        _isEditing.remove(reviewId); // Reset editing state
      });
      fetchReviews(); // Refresh setelah mengedit balasan
    } else {
      print('Gagal memperbarui balasan');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui balasan')),
      );
    }
  }

  Widget buildReviewCard(dynamic review) {
    final id = review['id'].toString();
    final customer = review['customer'];
    final name = customer?['name'] ?? 'Tidak diketahui';
    final rating = review['rating'] ?? 0;
    final reviewText = review['review'] ?? '';
    final reply = review['vendor_reply'];
    final profileImage = customer?['profile_image'] ?? '';
    final motor = review['motor'];
    final motorImage = motor?['image'];
    final motorName = motor?['name'];

    // Memastikan controller hanya dibuat sekali
    _controllers.putIfAbsent(id, () => TextEditingController());

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 8, // Increased elevation for better shadow
      margin: const EdgeInsets.symmetric(vertical: 10.0), // Increased margin
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage('${VendorReviewApi.baseUrl}$profileImage')
                      : const AssetImage('assets/images/c2.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold)), // Increased font size
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size:
                                20, // Increased icon size for better visibility
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(reviewText,
                style: const TextStyle(fontSize: 16)), // Consistent text size
            const SizedBox(height: 12),
            // Displaying motor image and name
            if (motor != null) ...[
              Image.network(
                '${VendorReviewApi.baseUrl}$motorImage',
                width: 120, // Increased width for better visibility
                height: 120, // Increased height for better visibility
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              Text(
                motorName ?? 'Nama motor tidak tersedia',
                style: const TextStyle(
                    fontSize: 18, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
            const SizedBox(height: 12),
            // Menampilkan balasan jika ada
            if (reply == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controllers[id],
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Tulis balasan Anda...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _submitReply(id),
                    icon: const Icon(Icons.reply),
                    label: const Text('Balas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C567E),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Balasan Anda:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(reply, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            // Tombol untuk mengedit balasan
            Align(
              alignment: Alignment.bottomRight,
              child: reply == null
                  ? const SizedBox()
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (!_isEditing.contains(id)) {
                            _isEditing.add(id);
                            _controllers[id]?.text =
                                reply ?? ''; // Muat balasan untuk diedit
                            print(
                                'Controller updated with reply: ${_controllers[id]?.text}');
                          } else {
                            _editReply(id);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      child: Text(
                        _isEditing.contains(id)
                            ? 'Simpan Balasan'
                            : 'Edit Balasan',
                        style: const TextStyle(color: Colors.white),
                      ),
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
        title: const Text('Ulasan Pengguna',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C567E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
