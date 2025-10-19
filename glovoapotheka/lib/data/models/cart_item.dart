class CartItem {
  final String id;
  final String name;
  final int? price; // Price in cents
  final List<String>? imageUrls;
  final String? description;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    this.price,
    this.imageUrls,
    this.description,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? id,
    String? name,
    int? price,
    List<String>? imageUrls,
    String? description,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartGroup {
  final String id;
  List<CartItem> items;

  CartGroup({
    required this.id,
    required this.items,
  });

  double get totalPrice {
    return items
        .where((item) => item.price != null)
        .fold(0.0, (sum, item) => sum + (item.price! / 100));
  }
}