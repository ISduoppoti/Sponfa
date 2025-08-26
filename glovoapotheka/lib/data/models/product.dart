// data/models/product.dart
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;           // UUID from backend
  final String name;         // "Aspirin 500mg"
  final String form;         // "tablet"
  final String strength;     // "500mg"
  final String gtin;         // barcode if we have it
  final int? priceCents;     // price at a specific pharmacy 
  final String? currency;    // currency code
  final String? pharmacyId;  // id of a pharmacy

  const ProductModel({
    required this.id,
    required this.name,
    required this.form,
    required this.strength,
    required this.gtin,
    this.priceCents,
    this.currency,
    this.pharmacyId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    name: json['name'],
    form: json['form'],
    strength: json['strength'],
    gtin: json['gtin'],
    priceCents: json['price_cents'],
    currency: json['currency'],
    pharmacyId: json['pharmacy_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'form': form,
    'strength': strength,
    'gtin': gtin,
    'price_cents': priceCents,
    'currency': currency,
    'pharmacy_id': pharmacyId,
  };

  @override
  List<Object?> get props => [id, name, form, strength, gtin, priceCents, currency, pharmacyId];
}
