import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiProvider {
  final String baseUrl;
  final Future<String?> Function()? getIdToken; // pass Firebase idToken if needed

  ProductApiProvider({required this.baseUrl, this.getIdToken});

  Future<List<ProductModel>> search(String query, {int limit = 20}) async {
    final uri = Uri.parse('$baseUrl/products/search?q=$query&limit=$limit');
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = getIdToken != null ? await getIdToken!() : null;
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Search failed: ${res.statusCode} ${res.body}');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => ProductModel.fromJson(e)).toList();
  }
}
