import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/view/vendor/detail_transaksi.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class TransactionReportScreen extends StatefulWidget {
  @override
  _TransactionReportScreenState createState() =>
      _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> transactionList = [];
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Chart data
  List<FlSpot> revenueSpots = [];
  List<FlSpot> transactionSpots = [];
  double maxY = 0;
  double maxX = 6; // Last 7 days

  // Theme colors
  final Color primaryColor = const Color(0xFF1A567D); // Modern indigo
  final Color secondaryColor = const Color(0xFF00BFA5); // Modern teal
  final Color accentColor = const Color(0xFFFF6D00); // Modern orange
  final Color backgroundColor = const Color(0xFFF5F7FA); // Light gray
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF263238); // Dark gray
  final Color textSecondaryColor = const Color(0xFF607D8B); // Blue gray
  final Color successColor = const Color(0xFF4CAF50); // Success green
  final Color warningColor = const Color(0xFFFFC107); // Warning amber
  final Color dangerColor = const Color(0xFFF44336); // Danger red

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    fetchTransactionData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchTransactionData() async {
    setState(() {
      isLoading = true;
    });

    try {
      print("Memulai pengambilan data transaksi...");

      final token = await storage.read(key: "auth_token");
      print("Token ditemukan: $token");

      final String baseUrl = ApiConfig.baseUrl;
      final Uri url = Uri.parse('$baseUrl/transaction/');
      print("Mengirim GET request ke: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            transactionList = data;
            isLoading = false;
          });
          print("Jumlah transaksi yang diterima: ${transactionList.length}");
          _prepareChartData();
          _animationController.forward();
        } else {
          print("Data tidak memiliki field 'data' atau bukan list");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Format data tidak valid"),
                ],
              ),
              backgroundColor: dangerColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(10),
            ),
          );
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Gagal memuat data transaksi. Status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Text("Gagal memuat data transaksi: ${response.statusCode}"),
              ],
            ),
            backgroundColor: dangerColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(10),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Terjadi error saat fetch data transaksi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Error: $e")),
            ],
          ),
          backgroundColor: dangerColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _prepareChartData() {
    // Get the last 7 days
    final now = DateTime.now();
    final dates =
        List.generate(7, (index) => now.subtract(Duration(days: index)));

    // Initialize data for each day
    Map<String, Map<String, dynamic>> dailyData = {};
    for (var date in dates) {
      String dateKey = DateFormat('yyyy-MM-dd').format(date);
      dailyData[dateKey] = {
        'revenue': 0,
        'count': 0,
      };
    }

    // Process transactions
    for (var transaction in transactionList) {
      try {
        // Get transaction date
        String? createdAt = transaction['created_at'];
        if (createdAt == null) continue;

        DateTime transactionDate = DateTime.parse(createdAt);
        String dateKey = DateFormat('yyyy-MM-dd').format(transactionDate);

        // Check if transaction is within the last 7 days
        if (dailyData.containsKey(dateKey)) {
          // Get transaction amount
          var totalPrice = transaction['total_price'];
          int parsedPrice = 0;
          if (totalPrice != null) {
            parsedPrice = (totalPrice is int)
                ? totalPrice
                : int.tryParse(totalPrice.toString()) ?? 0;
          }

          // Update daily data
          dailyData[dateKey]!['revenue'] += parsedPrice;
          dailyData[dateKey]!['count'] += 1;
        }
      } catch (e) {
        print("Error processing transaction for chart: $e");
      }
    }

    // Convert to chart data points
    revenueSpots = [];
    transactionSpots = [];
    maxY = 0;

    // Find max count for better scaling
    double maxCount = 0;
    dailyData.values.forEach((data) {
      if (data['count'] > maxCount) maxCount = data['count'].toDouble();
    });

    // Scale factor for count to make it visible alongside revenue
    double countScaleFactor = maxCount > 0 ? 100000 / maxCount : 100000;

    List<String> sortedDates = dailyData.keys.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      String dateKey = sortedDates[i];
      double x = i.toDouble();
      double revenueY = dailyData[dateKey]!['revenue'].toDouble();
      double countY =
          dailyData[dateKey]!['count'].toDouble() * countScaleFactor;

      revenueSpots.add(FlSpot(x, revenueY));
      transactionSpots.add(FlSpot(x, countY));

      // Update max Y value for scaling
      if (revenueY > maxY) maxY = revenueY;
      if (countY > maxY) maxY = countY;
    }

    // Ensure maxY is not zero
    if (maxY == 0) maxY = 1000000;

    // Add 20% padding to maxY
    maxY = maxY * 1.2;
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final dateTime = DateTime.parse(dateString);
      return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
    } catch (e) {
      return '-';
    }
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return "0";

    // Ensure amount is numeric
    int value;
    if (amount is String) {
      value = int.tryParse(amount) ?? 0;
    } else if (amount is int) {
      value = amount;
    } else if (amount is double) {
      value = amount.toInt();
    } else {
      value = 0;
    }

    final formatter = NumberFormat("#,###", "id_ID");
    return formatter.format(value);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return successColor;
      case 'pending':
        return warningColor;
      case 'cancelled':
        return dangerColor;
      default:
        return textSecondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total income from completed transactions
    int totalIncome = 0;
    int completedCount = 0;
    int pendingCount = 0;

    for (var transaction in transactionList) {
      var status = transaction['status']?.toString().toLowerCase() ?? '';
      var totalPrice = transaction['total_price'];
      int parsedPrice = 0;

      if (totalPrice != null) {
        parsedPrice = (totalPrice is int)
            ? totalPrice
            : int.tryParse(totalPrice.toString()) ?? 0;
      }

      if (status == 'completed') {
        totalIncome += parsedPrice;
        completedCount++;
      } else if (status == 'pending') {
        pendingCount++;
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Laporan Transaksi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchTransactionData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient at the top
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Memuat data transaksi...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchTransactionData,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Cards
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 400) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildSummaryCard(
                                          'Total Pendapatan',
                                          'Rp ${formatCurrency(totalIncome)}',
                                          Icons.monetization_on,
                                          primaryColor,
                                        ),
                                        SizedBox(width: 10),
                                        _buildSummaryCard(
                                          'Transaksi Selesai',
                                          completedCount.toString(),
                                          Icons.check_circle,
                                          successColor,
                                        ),
                                        SizedBox(width: 10),
                                        _buildSummaryCard(
                                          'Transaksi Pending',
                                          pendingCount.toString(),
                                          Icons.pending_actions,
                                          warningColor,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildSummaryCard(
                                          'Total Pendapatan',
                                          'Rp ${formatCurrency(totalIncome)}',
                                          Icons.monetization_on,
                                          primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _buildSummaryCard(
                                          'Transaksi Selesai',
                                          completedCount.toString(),
                                          Icons.check_circle,
                                          successColor,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _buildSummaryCard(
                                          'Transaksi Pending',
                                          pendingCount.toString(),
                                          Icons.pending_actions,
                                          warningColor,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),

                          // Revenue Chart
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Pendapatan 7 Hari Terakhir',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    360
                                                ? 14
                                                : 16,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimaryColor,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Pendapatan',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        360
                                                    ? 10
                                                    : 12,
                                                color: textSecondaryColor,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: accentColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Jumlah',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        360
                                                    ? 10
                                                    : 12,
                                                color: textSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    height: 200,
                                    width:
                                        MediaQuery.of(context).size.width - 32,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16.0, top: 16.0),
                                      child: LineChart(
                                        LineChartData(
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: true,
                                            horizontalInterval: maxY / 5,
                                            verticalInterval: 1,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                strokeWidth: 1,
                                              );
                                            },
                                            getDrawingVerticalLine: (value) {
                                              return FlLine(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            rightTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 30,
                                                interval: 1,
                                                getTitlesWidget: (value, meta) {
                                                  if (value % 1 != 0)
                                                    return const SizedBox
                                                        .shrink();
                                                  final now = DateTime.now();
                                                  final date = now.subtract(
                                                      Duration(
                                                          days: (maxX - value)
                                                              .toInt()));
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      DateFormat('dd/MM')
                                                          .format(date),
                                                      style: TextStyle(
                                                        color:
                                                            textSecondaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                                interval: maxY / 5,
                                                getTitlesWidget: (value, meta) {
                                                  String formattedValue = '';
                                                  if (value >= 1000000) {
                                                    formattedValue =
                                                        '${(value / 1000000).toStringAsFixed(1)}M';
                                                  } else if (value >= 1000) {
                                                    formattedValue =
                                                        '${(value / 1000).toStringAsFixed(0)}K';
                                                  } else {
                                                    formattedValue = value
                                                        .toStringAsFixed(0);
                                                  }
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0),
                                                    child: Text(
                                                      formattedValue,
                                                      style: TextStyle(
                                                        color:
                                                            textSecondaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                            show: false,
                                          ),
                                          minX: 0,
                                          maxX: maxX,
                                          minY: 0,
                                          maxY: maxY,
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: revenueSpots,
                                              isCurved: true,
                                              color: primaryColor,
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (spot, percent,
                                                    barData, index) {
                                                  return FlDotCirclePainter(
                                                    radius: 4,
                                                    color: primaryColor,
                                                    strokeWidth: 2,
                                                    strokeColor: Colors.white,
                                                  );
                                                },
                                              ),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: primaryColor
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            LineChartBarData(
                                              spots: transactionSpots,
                                              isCurved: true,
                                              color: accentColor,
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (spot, percent,
                                                    barData, index) {
                                                  return FlDotCirclePainter(
                                                    radius: 4,
                                                    color: accentColor,
                                                    strokeWidth: 2,
                                                    strokeColor: Colors.white,
                                                  );
                                                },
                                              ),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: accentColor
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Recent Transactions
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transaksi Terbaru',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  transactionList.isEmpty
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.receipt_long,
                                                  size: 48,
                                                  color: textSecondaryColor
                                                      .withOpacity(0.5),
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  'Belum ada transaksi',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: textSecondaryColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: transactionList
                                              .take(5)
                                              .map<Widget>((transaction) {
                                            return _buildTransactionItem(
                                                transaction);
                                          }).toList(),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 110,
        maxWidth: 200,
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: textSecondaryColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    var totalPrice = transaction['total_price'];
    int parsedPrice = 0;
    if (totalPrice != null) {
      parsedPrice = (totalPrice is int)
          ? totalPrice
          : int.tryParse(totalPrice.toString()) ?? 0;
    }

    String status = transaction['status'] ?? 'Unknown';
    Color statusColor = getStatusColor(status);
    String createdAt = formatDate(transaction['created_at']);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 64,
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              radius: 20,
              child: Text(
                (transaction['customer_name'] ?? 'U')
                    .substring(0, 1)
                    .toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['customer_name'] ?? 'Tidak Diketahui',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    createdAt,
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${formatCurrency(parsedPrice)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: status.toLowerCase() == 'completed'
                          ? successColor
                          : textPrimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status.substring(0, 1).toUpperCase() +
                          status.substring(1),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
