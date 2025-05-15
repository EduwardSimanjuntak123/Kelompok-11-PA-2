import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/view/user/detailMotorVendor/detailmotor.dart';
import 'package:flutter_rentalmotor/widgets/custom_bottom_navbar.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/daftar_pesanan/components/detailpesanan.dart';
import 'package:flutter_rentalmotor/view/user/profil/akun.dart';
import 'package:flutter_rentalmotor/view/user/homepageuser.dart';

class MotorListPage extends StatefulWidget {
  final bool isGuest;

  const MotorListPage({Key? key, required this.isGuest}) : super(key: key);

  @override
  _MotorListPageState createState() => _MotorListPageState();
}

class _MotorListPageState extends State<MotorListPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _motorList = [];
  List<Map<String, dynamic>> _filteredMotorList = [];
  final String baseUrl = ApiConfig.baseUrl;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _selectedType = 'Semua';
  List<String> _typeList = ['Semua', 'Matic', 'Manual', 'Kopling', 'Vespa'];
  // Filter variables
  String _searchQuery = '';
  String _selectedKecamatan = 'Semua';
  List<String> _kecamatanList = ['Semua'];
  String _selectedStatus = 'Semua';
  List<String> _statusList = ['Semua', 'Tersedia', 'Tidak Tersedia'];

  @override
  void initState() {
    super.initState();
    _fetchAllMotors();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
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

  Future<void> _fetchAllMotors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/motor/'));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> data = responseData['data'];

        // Extract unique kecamatan names
        Set<String> kecamatanSet = {'Semua'};
        for (var motor in data) {
          if (motor['vendor'] != null &&
              motor['vendor']['kecamatan'] != null &&
              motor['vendor']['kecamatan']['nama_kecamatan'] != null) {
            kecamatanSet.add(motor['vendor']['kecamatan']['nama_kecamatan']
                .toString()
                .trim());
          }
        }

        setState(() {
          _motorList =
              data.map((motor) => motor as Map<String, dynamic>).toList();
          _filteredMotorList = List.from(_motorList);
          _kecamatanList = kecamatanSet.toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load motors');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage("Gagal mengambil data motor!");
    }
  }

  void _filterMotors() {
    setState(() {
      _filteredMotorList = _motorList.where((motor) {
        // Filter by search query
        final name = motor['name']?.toString().toLowerCase() ?? '';
        final searchMatch =
            _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());

        // Filter by kecamatan
        final kecamatan = motor['vendor']?['kecamatan']?['nama_kecamatan']
                ?.toString()
                .trim() ??
            '';
        final kecamatanMatch =
            _selectedKecamatan == 'Semua' || kecamatan == _selectedKecamatan;

        // Filter by status
        final status = motor['status']?.toString().toLowerCase() ?? '';
        bool statusMatch = true;
        if (_selectedStatus != 'Semua') {
          if (_selectedStatus == 'Tersedia') {
            statusMatch = status == 'available';
          } else if (_selectedStatus == 'Tidak Tersedia') {
            statusMatch = status == 'booked' || status == 'unavailable';
          }
        }

        // Filter by type
        final type = motor['type']?.toString().toLowerCase() ?? '';
        final typeMatch =
            _selectedType == 'Semua' || type == _selectedType.toLowerCase();

        return searchMatch && kecamatanMatch && statusMatch && typeMatch;
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
      _showErrorMessage("Anda harus login untuk mengakses halaman ini.");
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageUser()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetailPesanan()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Akun()),
      );
    }
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
                titlePadding: EdgeInsets.only(
                    left: 55, bottom: 12), // Ditambah dari 50 ke 60
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
                          Icons.motorcycle,
                          color: Color(0xFF1565C0),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Daftar Motor',
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
                    // Background dan decorative elements tetap sama
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
                        'Temukan Motor',
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
                            'Pilih motor terbaik untuk perjalanan Anda',
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
                                _filterMotors();
                              },
                              decoration: InputDecoration(
                                hintText: 'Cari motor...',
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
                              Icon(
                                Icons.motorcycle,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Daftar Motor',
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
                    onPressed: _showFilterDialog,
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
            if (_selectedKecamatan != 'Semua' ||
                _selectedStatus != 'Semua' ||
                _selectedType != 'Semua')
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
                            if (_selectedKecamatan != 'Semua')
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Chip(
                                  label: Text(_selectedKecamatan),
                                  deleteIcon: Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedKecamatan = 'Semua';
                                    });
                                    _filterMotors();
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
                            if (_selectedStatus != 'Semua')
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Chip(
                                  label: Text(_selectedStatus),
                                  deleteIcon: Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedStatus = 'Semua';
                                    });
                                    _filterMotors();
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
                            if (_selectedType != 'Semua')
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Chip(
                                  label: Text(_selectedType),
                                  deleteIcon: Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedType = 'Semua';
                                    });
                                    _filterMotors();
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

            // Motor list
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
                            'Memuat daftar motor...',
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredMotorList.isEmpty
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
                                  Icons.motorcycle_outlined,
                                  size: 64,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada motor ditemukan',
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
                                    _selectedKecamatan = 'Semua';
                                    _selectedStatus = 'Semua';
                                    _selectedType = 'Semua';
                                    _searchQuery = '';
                                  });
                                  _filterMotors();
                                },
                              ),
                            ],
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _filteredMotorList.length,
                              itemBuilder: (context, index) {
                                // Apply staggered animation
                                final itemAnimation =
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      (index / _filteredMotorList.length) * 0.5,
                                      ((index + 1) /
                                                  _filteredMotorList.length) *
                                              0.5 +
                                          0.5,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                );

                                final motor = _filteredMotorList[index];

                                String imageUrl = motor["image"] != null &&
                                        motor["image"].isNotEmpty
                                    ? (motor["image"].startsWith("http")
                                        ? motor["image"]
                                        : "$baseUrl${motor["image"]}")
                                    : "assets/images/default_motor.png";

                                String statusMotor =
                                    motor["status"] ?? "Status Tidak Diketahui";
                                String kecamatan = motor["vendor"]["kecamatan"]
                                            ["nama_kecamatan"]
                                        ?.trim() ??
                                    "Kecamatan Tidak Diketahui";

                                String formattedPrice = "Rp ${motor["price"]}";

                                return FadeTransition(
                                  opacity: itemAnimation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, 0.2),
                                      end: Offset.zero,
                                    ).animate(itemAnimation),
                                    child: _buildMotorCard(
                                      motor["name"] ?? "Nama Tidak Diketahui",
                                      motor["rating"]?.toString() ?? "0",
                                      formattedPrice,
                                      imageUrl,
                                      statusMotor,
                                      kecamatan,
                                      motor,
                                    ),
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
                            'Filter Motor',
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

                  // Status filter
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF1565C0)),
                      SizedBox(width: 8),
                      Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
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
                        value: _selectedStatus,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF1565C0)),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedStatus = newValue;
                            });
                          }
                        },
                        items: _statusList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: value == _selectedStatus
                                    ? Color(0xFF1565C0)
                                    : Colors.black87,
                                fontWeight: value == _selectedStatus
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

                  // Type filter
                  Row(
                    children: [
                      Icon(Icons.category, color: Color(0xFF1565C0)),
                      SizedBox(width: 8),
                      Text(
                        'Tipe Motor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
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
                        value: _selectedType,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF1565C0)),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedType = newValue;
                            });
                          }
                        },
                        items: _typeList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: value == _selectedType
                                    ? Color(0xFF1565C0)
                                    : Colors.black87,
                                fontWeight: value == _selectedType
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Apply button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedKecamatan = 'Semua';
                              _selectedStatus = 'Semua';
                              _selectedType = 'Semua';
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
                            _filterMotors();
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

  Widget _buildMotorCard(
      String title,
      String rating,
      String price,
      String imageUrl,
      String statusMotor,
      String kecamatan,
      Map<String, dynamic> motor) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DetailMotorPage(
                motorId: motor["id"], isGuest: widget.isGuest)));
      },
      child: Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'motor-${motor["id"]}',
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey.shade400,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (motor["status"] ?? "unknown") == "available"
                            ? Colors.green
                            : (motor["status"] ?? "unknown") == "booked"
                                ? Colors.orange
                                : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        () {
                          String status = motor["status"] ?? "unknown";
                          if (status == "available") return "Tersedia";
                          if (status == "unavaiable") return "Sedang Perbaikan";
                          if (status == "booked") return "Sedang Digunakan";
                          return "Tidak Diketahui";
                        }(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            rating,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey.shade600,
                        size: 10,
                      ),
                      SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          kecamatan,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.green.shade200,
                      ),
                    ),
                    child: Text(
                      price,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detail',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 10,
                          ),
                        ],
                      ),
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
