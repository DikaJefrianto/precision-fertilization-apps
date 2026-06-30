import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/expert_rule_model.dart';
import 'package:http_parser/http_parser.dart';
import '../models/fertilizer_model.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal terhubung ke server"};
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String whatsapp) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': name,
          'email': email,
          'password': password,
          'no_whatsapp': whatsapp,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal terhubung ke server"};
    }
  }

  Future<Map<String, dynamic>> getAdminStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/admin/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal mengambil statistik admin"};
    }
  }

  Future<Map<String, dynamic>> getFarmerStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/dashboard-stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal mengambil data dashboard petani"};
    }
  }

  Future<Map<String, dynamic>> calculateFertilizer({
    required String token,
    required String labelTanah,
    required double n,
    required double p,
    required double k,
    required int hst,
    required double area,
    required String imagePath,
    required String accuracy, 
  }) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${AppConstants.baseUrl}/hitung-dosis'));

      request.headers['Authorization'] = 'Bearer $token';


      request.fields['label_tanah_ai'] = labelTanah;
      request.fields['n_input'] = n.toString();
      request.fields['p_input'] = p.toString();
      request.fields['k_input'] = k.toString();
      request.fields['hst_input'] = hst.toString();
      request.fields['luas_lahan'] = area.toString();
      
      request.fields['accuracy_input'] = accuracy; 

      String ext = imagePath.split('.').last.toLowerCase();
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType('image', ext == 'jpg' || ext == 'jpeg' ? 'jpeg' : ext),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print("Response Backend: ${response.body}");
      
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal melakukan kalkulasi hara: $e"};
    }
  }

  Future<Map<String, dynamic>> getFertilizers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/pupuk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal memuat katalog pupuk"};
    }
  }

  Future<Map<String, dynamic>> getHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/riwayat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal memuat riwayat"};
    }
  }

  Future<Map<String, dynamic>> getExpertRules(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/admin/pakar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal terhubung ke server"};
    }
  }

  Future<Map<String, dynamic>> deleteExpertRule(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/admin/pakar/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal menghapus aturan: $e"};
    }
  }

  Future<Map<String, dynamic>> createRule(String token, ExpertRule rule) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/pakar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(rule.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal menambah aturan: $e"};
    }
  }

  Future<Map<String, dynamic>> updateRule(
      String token, int id, ExpertRule rule) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/admin/pakar/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(rule.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal update aturan: $e"};
    }
  }

  Future<Map<String, dynamic>> createFertilizer(
      String token, Fertilizer f) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/admin/pupuk'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(f.toJson()),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> updateFertilizer(
      String token, int id, Fertilizer f) async {
    final res = await http.put(
      Uri.parse('${AppConstants.baseUrl}/admin/pupuk/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(f.toJson()),
    );
    return jsonDecode(res.body);
  }
  Future<Map<String, dynamic>> deleteFertilizer(String token, int id) async {
    final res = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/admin/pupuk/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal terhubung ke server"};
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      String token, String name, String wa) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/auth/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'nama': name, 'no_whatsapp': wa}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(
      String token, String filePath) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${AppConstants.baseUrl}/auth/upload-photo'));

      request.headers['Authorization'] = 'Bearer $token';

      String ext = filePath.split('.').last.toLowerCase();
      if (ext == 'jpg') ext = 'jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        filePath,
        contentType: MediaType('image', ext),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal upload: $e"};
    }
  }

  Future<Map<String, dynamic>> predictSoilImage(String filePath) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('ttps://dikajefrianto-fertiscan-ai.hf.space/predict'));
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "[Error] Gagal koneksi ke AI Server: $e"};
    }
  }
}