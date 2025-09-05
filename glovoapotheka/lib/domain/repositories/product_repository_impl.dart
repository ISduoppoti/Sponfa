import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:glovoapotheka/data/providers/product_api_provider.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiProvider api;
  ProductRepositoryImpl(this.api);

  @override
  Future<List<ProductModel>> search({required String query, required double lat, required double lng, int? radiusKm, int limit = 20, String? sort}) {
    // Forward for MVP; later attach filters as query params
    return api.search(query, lat, lng,  limit: limit);
  }

  @override
  Future<ProductModel> getById(String id) {
    // TODO: call /products/{id}
    throw UnimplementedError();
  }
}
