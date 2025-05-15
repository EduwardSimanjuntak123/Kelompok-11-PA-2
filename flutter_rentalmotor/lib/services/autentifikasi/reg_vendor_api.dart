import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

const String baseUrl = '${ApiConfig.baseUrl}';

// Fetch data kecamatan
Future<List<Map<String, dynamic>>?> fetchKecamatan() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/kecamatan'));
    print('Response Status Code: ${response.statusCode}');  // Log status code
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Data fetched from server: $data');  // Log response body
      return data.map((e) => {
        'id': e['id_kecamatan'],  // Sesuaikan dengan kunci 'id_kecamatan'
        'name': e['nama_kecamatan'].trim(),  // Sesuaikan dengan kunci 'nama_kecamatan' dan hilangkan karakter "\r\n"
      }).toList();
    } else {
      print('Gagal fetch kecamatan: ${response.body}');  // Log if the request fails
      return null;
    }
  } catch (e) {
    print('Error fetch kecamatan: $e');  // Log any error
    return null;
  }
}

Future<String> registerVendor(Map<String, dynamic> data, XFile profileImage) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/vendor/register'));

    // Tambahkan data form
    request.fields['name'] = data['name'];
    request.fields['email'] = data['email'];
    request.fields['password'] = data['password'];
    request.fields['phone'] = data['phone'];
    request.fields['shop_name'] = data['shop_name'];
    request.fields['shop_address'] = data['shop_address'];
    request.fields['shop_description'] = data['shop_description'];
    request.fields['id_kecamatan'] = data['id_kecamatan'];

    // Tambahkan gambar profil
    var profileImageFile = await http.MultipartFile.fromPath(
      'profile_image',
      profileImage.path,
      contentType: MediaType('image', 'jpeg'), // Atur sesuai dengan tipe gambar yang benar
    );
    request.files.add(profileImageFile);

    // Kirim request
    var response = await request.send();

    // Periksa status kode
    if (response.statusCode == 200) {
      return 'success';  // Registrasi berhasil
    } else if (response.statusCode == 409) {
      // Jika email atau telepon sudah digunakan
      var responseBody = await response.stream.bytesToString();
      var errorResponse = json.decode(responseBody);
      return errorResponse['error'] ?? 'Gagal mendaftar, coba lagi';
    } else {
      var responseBody = await response.stream.bytesToString();
      return 'Gagal mendaftar: ${responseBody}';
    }
  } catch (e) {
    return 'Kesalahan jaringan, coba lagi.';
  }
}
