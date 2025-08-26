// domain/repositories/product_repository.dart
import 'package:glovoapotheka/data/models/product.dart';


abstract class ProductRepository {
  Future<List<ProductModel>> search({
    required String query,
    double? lat,
    double? lng,
    int? radiusKm,
    int limit = 20,
    String? sort,
  });

  Future<ProductModel> getById(String id);
}