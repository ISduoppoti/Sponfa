// lib/domain/services/popular_products_service.dart

import 'package:flutter/foundation.dart';
import 'package:glovoapotheka/data/models/product.dart';

class PopularProductsService extends ChangeNotifier {

  Future<List<ProductModel>> getPopularProducts() async {
    // Should be fetched from server
    return [];
  }
}