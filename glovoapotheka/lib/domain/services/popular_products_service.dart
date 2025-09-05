// lib/domain/services/popular_products_service.dart

import 'package:flutter/foundation.dart';
import 'package:glovoapotheka/data/models/product.dart';

class PopularProductsService extends ChangeNotifier {

  List<Product> getPopularProducts() {
    // Should be fetched from server
    return [
      Product(
        imagePath: "assets/images/products/aspirin.svg",
        name: "Aspirin",
        strength: "325mg",
        manufacturer: "Bayer",
        price: 5.99,
        quantity: "100 in stock",
      ),
      Product(
        imagePath: "assets/images/products/otrivin.svg",
        name: "Otrivin",
        strength: "10ml",
        manufacturer: "Bayer",
        price: 7.99,
        quantity: "30 in stock",
      ),
      Product(
        imagePath: "assets/images/products/timoptic.svg",
        name: "Timoptic",
        strength: "5mL",
        manufacturer: "Bayer",
        price: 3.45,
        quantity: "60 in stock",
      ),
      Product(
        imagePath: "assets/images/products/mucosolvan.svg",
        name: "Mucosolvan",
        strength: "30mg",
        manufacturer: "Bayer",
        price: 7.45,
        quantity: "20 in stock",
      ),
      Product(
        imagePath: "assets/images/products/coldrex.svg",
        name: "Coldrex",
        strength: "500mg",
        manufacturer: "Bayer",
        price: 9.49,
        quantity: "50 in stock",
      ),
      Product(
        imagePath: "assets/images/products/norvask.svg",
        name: "Norvasc",
        strength: "5mg",
        manufacturer: "Bayer",
        price: 3.99,
        quantity: "12 in stock",
      ),
    ];
  }
}


/// Product model
class Product {
  final String imagePath;
  final String name;
  final String strength;
  final String manufacturer;
  final double price;
  final String quantity;

  Product({
    required this.imagePath,
    required this.name,
    required this.strength,
    required this.manufacturer,
    required this.price,
    required this.quantity,
  });
}