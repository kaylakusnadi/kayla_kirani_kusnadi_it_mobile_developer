import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_model.dart';

class StoreDataSource {
  final String baseUrl = "https://fakestoreapi.com";

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['token'];
      }
      
      final backupResponse = await http.post(
        Uri.parse("https://api.escuelajs.co/api/v1/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": username, "password": password}),
      );
      if (backupResponse.statusCode == 201 || backupResponse.statusCode == 200) {
        return jsonDecode(backupResponse.body)['access_token'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products"));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => ProductModel.fromJson(e)).toList();
      }
      throw Exception();
    } catch (_) {
      // Beralih ke Platzi API secara aman jika server utama timeout atau memblokir CORS browser
      final backupResponse = await http.get(Uri.parse("https://api.escuelajs.co/api/v1/products"));
      if (backupResponse.statusCode == 200) {
        List data = jsonDecode(backupResponse.body);
        return data.map((e) => ProductModel.fromJson(e)).toList();
      }
      return [];
    }
  }
}