import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/utils/status_utils.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/pesanan.dart';
import 'package:intl/intl.dart';

class BookingItem extends StatelessWidget {
  final dynamic item;
  final Animation<double> animation;
  final Color primaryBlue;

  const BookingItem({
    Key? key,
    required this.item,
    required this.animation,
    required this.primaryBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = item['status'] ?? '';
    final isNewBooking = status == 'pending';

    final startDate = DateTime.parse(item['start_date']);
    final endDate = DateTime.parse(item['end_date']);
    final durationDays = endDate.difference(startDate).inDays + 1;

    final dateFormat = DateFormat('dd MMM yyyy');
    final formattedStart = dateFormat.format(startDate);
    final formattedEnd = dateFormat.format(endDate);

    final String? originalImage = item['motor']['image'];
    String imageUrl = originalImage ?? 'https://via.placeholder.com/100';
    if (imageUrl.startsWith('/')) {
      imageUrl = "${ApiConfig.baseUrl}$imageUrl";
    }

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 1),
              ),
            ],
            border: isNewBooking
                ? Border.all(
                    color: Colors.orange,
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: StatusUtils.getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          StatusUtils.getStatusIcon(status),
                          color: StatusUtils.getStatusColor(status),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          StatusUtils.getStatusText(status),
                          style: TextStyle(
                            color: StatusUtils.getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (isNewBooking)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Motor Info and Details
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Motor Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey[500], size: 20),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['motor']['name'] ?? 'Nama tidak ada',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.date_range,
                                  size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$formattedStart - $formattedEnd',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$durationDays hari',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['pickup_location'] ?? 'Lokasi tidak ada',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Rp ${item['motor']['price_per_day']} / hari",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PesananPage(booking: item),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  minimumSize: Size(70, 30),
                                ),
                                child: Text('Detail',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
