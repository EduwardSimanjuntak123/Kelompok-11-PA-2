import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/view/user/detailMotorVendor/datavendor.dart';
import 'package:flutter_rentalmotor/widgets/custom_bottom_navbar.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/daftar_pesanan/components/detailpesanan.dart';
import 'package:flutter_rentalmotor/view/user/profil/akun.dart';
import 'package:flutter_rentalmotor/view/user/homepageuser.dart';

class VendorListPage extends StatefulWidget {
  final bool isGuest;

  const VendorListPage({Key? key, required this.isGuest}) : super(key: key);

  @override
  _VendorListPageState createState() => _VendorListPageState();
}

class _VendorListPageState extends State<VendorListPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _vendorList = [];
  List<Map<String, dynamic>> _filteredVendorList = [];
  final String baseUrl = ApiConfig.baseUrl;
  int _selectedIndex = 0;

  // Filter variables
  String _searchQuery = '';
  String _selectedKecamatan = 'Semua Kecamatan';
  List<String> _kecamatanList = ['Semua Kecamatan'];
  double _minRating = 0.0;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _fetchVendors();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vendor'));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> data = responseData['data'];

        // Extract unique kecamatan names
        Set<String> kecamatanSet = {'Semua Kecamatan'};
        for (var vendor in data) {
          if (vendor['kecamatan'] != null &&
              vendor['kecamatan']['nama_kecamatan'] != null) {
            kecamatanSet
                .add(vendor['kecamatan']['nama_kecamatan'].toString().trim());
          }
        }

        setState(() {
          _vendorList =
              data.map((vendor) => vendor as Map<String, dynamic>).toList();
          _filteredVendorList = List.from(_vendorList);
          _kecamatanList = kecamatanSet.toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load vendors');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage("Gagal mengambil data vendor!");
    }
  }

  void _filterVendors() {
    setState(() {
      _filteredVendorList = _vendorList.where((vendor) {
        // Filter by search query
        final shopName = vendor['shop_name']?.toString().toLowerCase() ?? '';
        final address = vendor['shop_address']?.toString().toLowerCase() ?? '';
        final searchMatch = _searchQuery.isEmpty ||
            shopName.contains(_searchQuery.toLowerCase()) ||
            address.contains(_searchQuery.toLowerCase());

        // Filter by kecamatan
        final kecamatan =
            vendor['kecamatan']?['nama_kecamatan']?.toString().trim() ?? '';
        final kecamatanMatch = _selectedKecamatan == 'Semua Kecamatan' ||
            kecamatan == _selectedKecamatan;

        // Filter by rating
        final rating =
            double.tryParse(vendor['rating']?.toString() ?? '0') ?? 0.0;
        final ratingMatch = rating >= _minRating;

        return searchMatch && kecamatanMatch && ratingMatch;
      }).toList();
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (widget.isGuest && (index == 1 || index == 2)) {
      _showErrorMessage("Anda harus masuk untuk mengakses halaman ini.");
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePageUser()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DetailPesanan()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Akun()));
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _showFilterDialog();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF1565C0).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.filter_alt,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Filter Vendor',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Divider(thickness: 1),

                  // Kecamatan filter
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFF1565C0)),
                        SizedBox(width: 8),
                        Text(
                          'Kecamatan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedKecamatan,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF1565C0)),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedKecamatan = newValue;
                            });
                          }
                        },
                        items: _kecamatanList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: value == _selectedKecamatan
                                    ? Color(0xFF1565C0)
                                    : Colors.black87,
                                fontWeight: value == _selectedKecamatan
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Rating filter
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFF1565C0)),
                        SizedBox(width: 8),
                        Text(
                          'Minimum Rating',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Column(
                    children: [
                      Text(
                        '${_minRating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      Slider(
                        value: _minRating,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: _minRating.toStringAsFixed(1),
                        onChanged: (double value) {
                          setState(() {
                            _minRating = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Apply button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedKecamatan = 'Semua Kecamatan';
                              _minRating = 0.0;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Color(0xFF1565C0)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            _filterVendors();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1565C0),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Terapkan Filter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              elevation: 4,
              backgroundColor: const Color(0xFF1565C0),
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                titlePadding: EdgeInsets.only(left: 55, bottom: 12),
                centerTitle: false,
                title: AnimatedOpacity(
                  opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.store,
                          color: Color(0xFF1565C0),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Daftar Vendor',
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                background: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF1976D2),
                            Color(0xFF0D47A1),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: -20,
                            bottom: -20,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 60,
                      top: 40,
                      child: Text(
                        'Temukan Vendor',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 95.0, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih vendor terbaik untuk kebutuhan Anda',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                                _filterVendors();
                              },
                              decoration: InputDecoration(
                                hintText: 'Cari vendor...',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade400),
                                prefixIcon: Icon(Icons.search,
                                    color: Color(0xFF1565C0)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.store, color: Colors.white, size: 28),
                              SizedBox(width: 8),
                              Text(
                                'Daftar Vendor',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.filter_list, color: Colors.white),
                    ),
                    onPressed: _toggleFilters,
                    tooltip: 'Filter',
                  ),
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            // Active filters display
            if (_selectedKecamatan != 'Semua Kecamatan' || _minRating > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_outlined,
                        color: Color(0xFF1565C0), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_selectedKecamatan != 'Semua Kecamatan')
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Chip(
                                  label: Text(_selectedKecamatan),
                                  deleteIcon: Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedKecamatan = 'Semua Kecamatan';
                                    });
                                    _filterVendors();
                                  },
                                  backgroundColor:
                                      Color(0xFF1565C0).withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                            if (_minRating > 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Chip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                      SizedBox(width: 4),
                                      Text(
                                          '≥ ${_minRating.toStringAsFixed(1)}'),
                                    ],
                                  ),
                                  deleteIcon: Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _minRating = 0;
                                    });
                                    _filterVendors();
                                  },
                                  backgroundColor:
                                      Color(0xFF1565C0).withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Vendor list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF1565C0),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memuat daftar vendor...',
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredVendorList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1565C0).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.store_mall_directory_outlined,
                                  size: 64,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada vendor ditemukan',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Coba ubah filter pencarian Anda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: Icon(Icons.refresh),
                                label: Text('Reset Filter'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1565C0),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedKecamatan = 'Semua Kecamatan';
                                    _minRating = 0;
                                    _searchQuery = '';
                                  });
                                  _filterVendors();
                                },
                              ),
                            ],
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredVendorList.length,
                              itemBuilder: (context, index) {
                                // Apply staggered animation
                                final itemAnimation =
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      (index / _filteredVendorList.length) *
                                          0.5,
                                      ((index + 1) /
                                                  _filteredVendorList.length) *
                                              0.5 +
                                          0.5,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                );

                                final vendor = _filteredVendorList[index];

                                String imageUrl = vendor["user"]
                                                ["profile_image"] !=
                                            null &&
                                        vendor["user"]["profile_image"]
                                            .isNotEmpty
                                    ? '$baseUrl${vendor["user"]["profile_image"]}'
                                    : "assets/images/default_vendor.png";

                                String shopName = vendor["shop_name"] ??
                                    "Nama Toko Tidak Diketahui";
                                String rating =
                                    vendor["rating"]?.toString() ?? "0";
                                String address = vendor["shop_address"] ??
                                    "Alamat Tidak Diketahui";
                                String kecamatan = vendor["kecamatan"]
                                            ["nama_kecamatan"]
                                        ?.toString()
                                        .trim() ??
                                    "Kecamatan Tidak Diketahui";

                                return FadeTransition(
                                  opacity: itemAnimation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, 0.2),
                                      end: Offset.zero,
                                    ).animate(itemAnimation),
                                    child: _buildVendorCard(shopName, rating,
                                        imageUrl, address, kecamatan, vendor),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isGuest: widget.isGuest,
      ),
    );
  }

  Widget _buildVendorCard(String shopName, String rating, String imageUrl,
      String address, String kecamatan, Map<String, dynamic> vendor) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DataVendor(vendorId: vendor["id"]),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(
            color: Colors.blue.shade50,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Hero(
                    tag: 'vendor-${vendor["id"]}',
                    child: Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.store_mall_directory_outlined,
                              color: Colors.grey.shade400,
                              size: 64,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Shop name on image
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Text(
                    shopName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Kecamatan badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          kecamatan,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_city,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.visibility,
                              size: 16, color: Colors.white),
                          label: Text('Lihat Detail'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  DataVendor(vendorId: vendor["id"]),
                            ));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF1565C0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF1565C0).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Color(0xFF1565C0),
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }
}
