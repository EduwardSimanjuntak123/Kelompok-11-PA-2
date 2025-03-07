import 'package:flutter/material.dart';

class PesananPage extends StatefulWidget {
  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _pesanan = ["HONDA BEAT POP", "YAMAHA NMAX"];
  List<String> _filteredPesanan = [];

  @override
  void initState() {
    super.initState();
    _filteredPesanan = List.from(_pesanan);
  }

  void _filterPesanan(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPesanan = List.from(_pesanan);
      });
    } else {
      setState(() {
        _filteredPesanan = _pesanan.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(hintText: "Cari pesanan..."),
                onChanged: _filterPesanan,
              )
            : Text("Pesanan", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredPesanan = List.from(_pesanan);
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: _filteredPesanan.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_filteredPesanan[index], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text("Automatic/Manual", style: TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      Icon(Icons.battery_alert, size: 16, color: Colors.grey),
                      Text(" 24% Filled", style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 10),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      Text(" 1.3 Km", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Image.asset('images/assets/rev.jpg', width: 100),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("GAOL RENTAL", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("75K/ hari", style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showDetailPesanan(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Text("Detail", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailPesanan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text("Detail Pesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              SizedBox(height: 10),
              Text("Motor: HONDA BEAT POP", style: TextStyle(fontSize: 16)),
              Text("Transmisi: Automatic/Manual"),
              Text("Rental: GAOL RENTAL"),
              Text("Harga: 75K/hari"),
              Text("Jarak: 1.3 Km"),
              Text("Bensin: full filled"),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Tutup", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
