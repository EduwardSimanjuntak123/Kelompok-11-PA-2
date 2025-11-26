import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/view/user/homepageuser.dart';
import 'package:flutter_rentalmotor/view/user/profil/akun.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/customer/cancelBooking_api.dart';
import 'package:flutter_rentalmotor/view/user/ulasan/reviewpage.dart';
import 'package:flutter_rentalmotor/services/vendor/pesanan_extension_service.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/pesanan_header.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/status_banner.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/booking_details_card.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/extension_list.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/action_button.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/chat_vendor_button.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/dialogs/cancel_confirmation_dialog.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/dialogs/extend_request_dialog.dart';

class PesananPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const PesananPage({super.key, required this.booking});

  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  final int _selectedIndex = 1;
  bool _isCancelling = false;
  final bool _hasReviewed = false;
  List<dynamic> _extensions = [];
  bool _loadingExt = true;

  // Blue theme colors
  final Color primaryBlue = Color(0xFF2C567E);

  @override
  void initState() {
    super.initState();
    debugBooking();
    _fetchExtensions();
  }

  void debugBooking() {
    print("=== DEBUG BOOKING DATA ===");
    widget.booking.forEach((key, value) {
      print("$key: $value");
    });
    print("===========================");
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePageUser()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Akun()));
    }
  }

  Future<void> _fetchExtensions() async {
    try {
      final bookingId = widget.booking['id'];
      final extensions =
          await PesananExtensionService.fetchExtensions(bookingId);
      setState(() {
        _extensions = extensions;
        _loadingExt = false;
      });
    } catch (e) {
      print("Error fetching extensions: $e");
      setState(() => _loadingExt = false);
    }
  }

  Future<void> showCancelConfirmation(int bookingId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CancelConfirmationDialog(),
    );

    if (result == true) {
      await cancelBooking(bookingId);
    }
  }

  Future<void> showExtendRequestDialog(int bookingId) async {
    final motor = widget.booking['motor'];
    final int motorId = motor['id'];
    final bookingEndDate = DateTime.parse(widget.booking['end_date']);

    // Fetch unavailable dates
    final unavailableDates =
        await PesananExtensionService.getUnavailableDates(motorId);

    // Default additional days
    int additionalDays = 3;

    // Check if extension is possible
    bool cannotExtend = false;
    for (DateTime date in unavailableDates) {
      for (int i = 1; i <= additionalDays; i++) {
        DateTime extendDate = bookingEndDate.add(Duration(days: i));
        if (date == extendDate) {
          print("Cannot extend because booking exists on: $date");
          cannotExtend = true;
          break;
        }
      }
      if (cannotExtend) break;
    }

    // Show dialog
    await showDialog(
      context: context,
      builder: (context) => ExtendRequestDialog(
        booking: widget.booking,
        unavailableDates: unavailableDates,
        cannotExtend: cannotExtend,
        onSubmit: (additionalDays) async {
          final result = await requestExtensionDays(bookingId, additionalDays);
          final success = result['success'];
          final message = result['message'];

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    success ? Icons.check_circle_outline : Icons.error_outline,
                    color: success ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(success ? 'Berhasil' : 'Gagal'),
                ],
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Tutup'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> requestExtensionDays(
      int bookingId, int additionalDays) async {
    return await PesananExtensionService.requestExtensionDays(
        bookingId, additionalDays);
  }

  Future<void> cancelBooking(int bookingId) async {
    setState(() => _isCancelling = true);

    final success = await BatalkanPesananAPI.cancelBooking(bookingId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pesanan berhasil dibatalkan."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() {
        widget.booking['status'] = 'canceled';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal membatalkan pesanan."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    setState(() => _isCancelling = false);
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final motor = booking['motor'] ?? {};
    final status = booking['status'] ?? '';
    String imageUrl = motor['image'] ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = "${ApiConfig.baseUrl}$imageUrl";
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: primaryBlue, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            "Detail Pesanan",
            style: TextStyle(
              color: primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with motor image
            PesananHeader(
              motorName: motor['name'] ?? '',
              motorBrand: motor['brand'] ?? '',
              motorModel: motor['model'] ?? '',
              imageUrl: imageUrl,
            ),

            // Status Banner
            StatusBanner(status: status),

            // Booking Details Card
            BookingDetailsCard(
              booking: booking,
              primaryBlue: primaryBlue,
            ),

            // Extensions Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Permintaan Perpanjangan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  SizedBox(height: 8),
                  ExtensionList(
                    extensions: _extensions,
                    isLoading: _loadingExt,
                    primaryBlue: primaryBlue,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (status == 'pending') ...[
                    ActionButton(
                      text: "Batalkan Pesanan",
                      bgColor: Colors.red,
                      textColor: Colors.white,
                      onPressed: () {
                        showCancelConfirmation(booking['id']);
                      },
                      icon: Icons.cancel,
                    ),
                    SizedBox(height: 8),
                  ],
                  if (status == 'in use') ...[
                    ActionButton(
                      text: "Ajukan Perpanjangan",
                      bgColor: primaryBlue,
                      textColor: Colors.white,
                      onPressed: () {
                        showExtendRequestDialog(booking['id']);
                      },
                      icon: Icons.date_range,
                    ),
                    SizedBox(height: 8),
                  ],
                  if (status == 'completed' && !_hasReviewed) ...[
                    ActionButton(
                      text: "Berikan Ulasan",
                      bgColor: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReviewPage(bookingId: booking['id']),
                          ),
                        );
                      },
                      icon: Icons.star,
                    ),
                    SizedBox(height: 8),
                  ],
                  ChatVendorButton(
                    vendorId: booking['vendor_Id'] ?? 0,
                    vendorData: {
                      'user_id': booking['vendor_Id'],
                      'shop_name': booking['shop_name'],
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: primaryBlue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: "Beranda"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: "Pesanan"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: "Akun"),
            ],
          ),
        ),
      ),
    );
  }
}
