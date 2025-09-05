// product_api_provider.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiProvider {
  final String baseUrl;
  final Future<String?> Function()? getIdToken;

  ProductApiProvider({required this.baseUrl, this.getIdToken});

  Future<List<ProductModel>> search(
    String query,
    double lat,
    double lng, {
    int limit = 20,
    String language = 'en',
    int? radiusKm,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{
      'q': query,
      'limit': limit.toString(),
      'language': language,
    };
    
    queryParams['lat'] = lat.toString();
    queryParams['lng'] = lng.toString();
    if (radiusKm != null) queryParams['radius_km'] = radiusKm.toString();
    
    final uri = Uri.parse('$baseUrl/products/search').replace(
      queryParameters: queryParams,
    );
    
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

  Future<ProductModel> getById(String id, {String language = 'en'}) async {
    final uri = Uri.parse('$baseUrl/products/$id').replace(
      queryParameters: {'language': language},
    );
    
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = getIdToken != null ? await getIdToken!() : null;
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Get product failed: ${res.statusCode} ${res.body}');
    }
    
    return ProductModel.fromJson(jsonDecode(res.body));
  }
}