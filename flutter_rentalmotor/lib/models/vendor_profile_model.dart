class VendorProfileModel {
  final int id;
  final String name;
  final String shopName;
  final String shopAddress;
  final String email;
  final String? profileImage;
  final String? phone;
  final String? address;
  final String? shopDescription;
  final String? districtName;

  VendorProfileModel({
    required this.id,
    required this.name,
    required this.shopName,
    required this.shopAddress,
    required this.email,
    this.profileImage,
    this.phone,
    this.address,
    this.shopDescription,
    this.districtName,
  });
}
