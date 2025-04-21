import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

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

        // Check if the response contains a 'data' field that is a list
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
            content: Text("Gagal memuat data transaksi: ${response.statusCode}"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Laporan Transaksi')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transactionList.length,
              itemBuilder: (context, index) {
                var transaction = transactionList[index];

                // Safely handling null and non-numeric 'total_price'
                var totalPrice = transaction['total_price'];
                int parsedPrice = 0;
                if (totalPrice != null) {
                  parsedPrice = (totalPrice is int)
                      ? totalPrice
                      : int.tryParse(totalPrice.toString()) ?? 0;
                }

                return ListTile(
                  title: Text('Pelanggan: ${transaction['customer_name'] ?? 'Tidak Diketahui'}'),
                  subtitle: Text('Status: ${transaction['status'] ?? '-'}'),
                  trailing: Text('Rp $parsedPrice'),
                );
              },
            ),
    );
  }
}
