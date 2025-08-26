import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final double rating;
  final int reviewCount;
  final String country;

  Product({
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.country,
  });
}

class DiscountGoods extends StatelessWidget {
  const DiscountGoods({Key? key}) : super(key: key);

  // Simulated product data
  List<Product> get products => [
    Product(name: "Natrol, Kids, Melatonin Gummies, Ages 4+, Raspberry, ...", price: 17.04, rating: 4.5, reviewCount: 18995, country: "Saudi Arabia"),
    Product(name: "Jarrow Formulas, Vegan Mastic Gum, 120 Veggie Capsule...", price: 55.67, rating: 4.5, reviewCount: 12210, country: "Korea, Republic of"),
    Product(name: "Mount Lai, The Amethyst Gua Sha Tool, 1 Tool", price: 39.85, rating: 4.5, reviewCount: 360, country: "Korea, Republic of"),
    Product(name: "Amazing Grass, Greens Blend Superfood, The...", price: 33.70, rating: 4.5, reviewCount: 6150, country: "Hong Kong"),
    Product(name: "Life Extension, Gastro-Ease, 60 Vegetarian Capsules", price: 30.83, rating: 4.5, reviewCount: 3211, country: "China"),
    Product(name: "think, Thinksport, Sunscreen, SPF 50, 6 fl oz (177 ml)", price: 25.49, rating: 4.0, reviewCount: 1481, country: "Canada"),
    Product(name: "NOW Foods, Sports, Arginine & Citrulline, 240 Veg Capsules", price: 33.07, rating: 4.5, reviewCount: 3869, country: "Japan"),
    Product(name: "Doctor's Best, High Absorption CoQ10, 100 mg, 120 Softgels", price: 19.93, rating: 4.5, reviewCount: 49776, country: "Korea, Republic of"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // Fixed height to provide constraints
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F5F0),
            Color(0xFFEAE8E0),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Discounts',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Products section
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: products.map((product) => _buildProductCard(product)).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hollow rectangle instead of product image
          Container(
            height: 120,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
          
          // Product name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Rating
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < product.rating.floor() ? Icons.star : 
                    (index < product.rating ? Icons.star_half : Icons.star_border),
                    size: 14,
                    color: Colors.orange,
                  );
                }),
                const SizedBox(width: 4),
                Text(
                  '${product.reviewCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${product.price.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Country
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              product.country,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}