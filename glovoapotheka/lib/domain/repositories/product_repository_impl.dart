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

  @override
  Future<ProductDetailModel> getProductPackages({
    required String productId,
    String language = 'en',
    double? lat,
    double? lng,
    int? radiusKm,
    bool onlyInStock = true,
  }) {
    return api.getProductPackages(
      productId: productId,
      language: language,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      onlyInStock: onlyInStock,
    );
  }

  @override
  Future<List<PharmacySearchResult>> searchPharma({
    required List<String> packageIds,
    required double lat,
    required double lng,
    int? radiusKm,
    bool mustHaveAll = false,
    String sortBy = "distance",
    int limit = 20
  }) {
    return api.searchPharma(packageIds: packageIds, lat: lat, lng: lng, radiusKm: radiusKm, mustHaveAll: mustHaveAll, sortBy: sortBy, limit: limit);
  }
}
