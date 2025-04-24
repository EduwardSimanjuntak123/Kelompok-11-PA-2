import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/vendor/detail_transaksi.dart'; // Pastikan untuk mengimpor halaman detail transaksi

class TransactionReportScreen extends StatefulWidget {
  @override
  _TransactionReportScreenState createState() =>
      _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
  bool isLoading = true;
  List<dynamic> transactionList = [];
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchTransactionData();
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
          });
          print("Jumlah transaksi yang diterima: ${transactionList.length}");
        } else {
          print("Data tidak memiliki field 'data' atau bukan list");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Format data tidak valid"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print("Gagal memuat data transaksi. Status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Gagal memuat data transaksi: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Terjadi error saat fetch data transaksi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      print("Selesai mengambil data transaksi.");
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Transaksi',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A567D),
        titleTextStyle: TextStyle(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchTransactionData,
              child: transactionList.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'Tidak ada transaksi tersedia',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: transactionList.length,
                      itemBuilder: (context, index) {
                        var transaction = transactionList[index];

                        var totalPrice = transaction['total_price'];
                        int parsedPrice = 0;
                        if (totalPrice != null) {
                          parsedPrice = (totalPrice is int)
                              ? totalPrice
                              : int.tryParse(totalPrice.toString()) ?? 0;
                        }

                        Color statusColor = transaction['status'] == 'completed'
                            ? const Color.fromARGB(255, 156, 160, 156)
                            : Colors.grey;

                        Color priceColor = transaction['status'] == 'completed'
                            ? Colors.green
                            : Colors.black;

                        String createdAt =
                            formatDate(transaction['created_at']);

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(15),
                            title: Text(
                              'Pelanggan: ${transaction['customer_name'] ?? 'Tidak Diketahui'}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Dibuat pada: $createdAt',
                              style: TextStyle(
                                fontSize: 14,
                                color: statusColor,
                              ),
                            ),
                            trailing: Text(
                              'Rp ${parsedPrice.toString()}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: priceColor),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionDetailScreen(
                                      transaction: transaction),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
