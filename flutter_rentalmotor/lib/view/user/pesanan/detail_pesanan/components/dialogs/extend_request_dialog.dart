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
    _daysController.text = additionalDays.toString();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initialize fade animation after controller is created
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _daysController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxDialogHeight = screenSize.height * 0.8;
    final maxDialogWidth = screenSize.width * 0.9;

    final primaryColor = const Color(0xFF2C567E);
    final secondaryColor = const Color(0xFF4A89DC);
    final backgroundColor = Colors.white;
    final accentColor = const Color(0xFFFFA726);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        backgroundColor: backgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxDialogHeight,
            maxWidth: maxDialogWidth,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Ajukan Perpanjangan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Calendar
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
                              child: FractionallySizedBox(
                                widthFactor: 1.3,
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: CalendarExtension(
                                      unavailableDates: widget.unavailableDates,
                                      booking: widget.booking,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Legend
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

                          // Warning if cannot extend
                          if (widget.cannotExtend)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.error_outline,
                                        color: Colors.red, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tidak bisa perpanjang karena tanggal yang diminta sudah berbenturan dengan booking lain.',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Input for additional days
                          if (!widget.cannotExtend) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Berapa hari yang ingin ditambahkan?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
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
                              child: TextField(
                                controller: _daysController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Jumlah Hari Tambahan',
                                  labelStyle: TextStyle(color: secondaryColor),
                                  hintText: 'Masukkan jumlah hari',
                                  fillColor: Colors.white,
                                  filled: true,
                                  prefixIcon: Icon(Icons.calendar_today,
                                      color: secondaryColor),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: secondaryColor, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
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
                                        color: Colors.blue[800],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  if (!widget.cannotExtend)
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onSubmit(additionalDays);
                            },
                            child: const Text(
                              'Kirim Permintaan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
