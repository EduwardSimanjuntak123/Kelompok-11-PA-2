import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/calendar_extension.dart';

class ExtendRequestDialog extends StatefulWidget {
  final Map<String, dynamic> booking;
  final List<DateTime> unavailableDates;
  final Function(int additionalDays) onSubmit;
  final bool cannotExtend;

  const ExtendRequestDialog({
    Key? key,
    required this.booking,
    required this.unavailableDates,
    required this.onSubmit,
    this.cannotExtend = false,
  }) : super(key: key);

  @override
  _ExtendRequestDialogState createState() => _ExtendRequestDialogState();
}

class _ExtendRequestDialogState extends State<ExtendRequestDialog>
    with SingleTickerProviderStateMixin {
  int additionalDays = 3;
  final TextEditingController _daysController =
      TextEditingController(text: '3');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _daysController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLegendItem(Color color, String text, Color borderColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final primaryColor = const Color(0xFF2C567E);
    final secondaryColor = const Color(0xFF4A89DC);
    final accentColor = const Color(0xFFFFA726);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.8,
            maxWidth: screenSize.width * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.date_range_rounded, color: primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      'Ajukan Perpanjangan',
                      style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CalendarExtension(
                                unavailableDates: widget.unavailableDates,
                                booking: widget.booking,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildLegendItem(Colors.orange[200]!,
                                  "Booking Anda", accentColor),
                              _buildLegendItem(
                                  Colors.red[100]!,
                                  "Tanggal yang sudah di Booking",
                                  Colors.red[300]!),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (widget.cannotExtend)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tidak bisa perpanjang karena tanggal yang diminta sudah berbenturan dengan booking lain.',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          )
                        else ...[
                          Text(
                            'Berapa hari yang ingin ditambahkan?',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _daysController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Jumlah Hari Tambahan',
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: secondaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: secondaryColor, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              setState(() {
                                additionalDays = int.tryParse(value) ?? 1;
                                if (additionalDays < 1) {
                                  additionalDays = 1;
                                  _daysController.text = '1';
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: secondaryColor, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Perpanjangan akan ditambahkan setelah tanggal akhir booking Anda saat ini.',
                                    style: TextStyle(
                                        color: Colors.blue[800], fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!widget.cannotExtend)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onSubmit(additionalDays);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Kirim Permintaan'),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
