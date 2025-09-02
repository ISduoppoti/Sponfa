// data/models/product.dart
import 'package:equatable/equatable.dart';

class PharmacyLocationInfo extends Equatable {
  final String pharmacyId;
  final String pharmacyName;
  final String pharmacyAddress;
  final String pharmacyCity;
  final String pharmacyCountry;
  final int? priceCents;
  final String currency;
  final int stockQuantity;
  final String? lastUpdated;

  const PharmacyLocationInfo({
    required this.pharmacyId,
    required this.pharmacyName,
    required this.pharmacyAddress,
    required this.pharmacyCity,
    required this.pharmacyCountry,
    this.priceCents,
    this.currency = 'EUR',
    required this.stockQuantity,
    this.lastUpdated,
  });

  factory PharmacyLocationInfo.fromJson(Map<String, dynamic> json) => PharmacyLocationInfo(
    pharmacyId: json['pharmacy_id'],
    pharmacyName: json['pharmacy_name'],
    pharmacyAddress: json['pharmacy_address'],
    pharmacyCity: json['pharmacy_city'],
    pharmacyCountry: json['pharmacy_country'],
    priceCents: json['price_cents'],
    currency: json['currency'] ?? 'EUR',
    stockQuantity: json['stock_quantity'],
    lastUpdated: json['last_updated'],
  );

  Map<String, dynamic> toJson() => {
    'pharmacy_id': pharmacyId,
    'pharmacy_name': pharmacyName,
    'pharmacy_address': pharmacyAddress,
    'pharmacy_city': pharmacyCity,
    'pharmacy_country': pharmacyCountry,
    'price_cents': priceCents,
    'currency': currency,
    'stock_quantity': stockQuantity,
    'last_updated': lastUpdated,
  };

  // Helper methods for UI
  String get priceFormatted {
    if (priceCents == null) return 'Price not available';
    final euros = priceCents! / 100;
    return '€${euros.toStringAsFixed(2)}';
  }

  String get fullAddress => '$pharmacyAddress, $pharmacyCity, $pharmacyCountry';

  @override
  List<Object?> get props => [
    pharmacyId, pharmacyName, pharmacyAddress, pharmacyCity, 
    pharmacyCountry, priceCents, currency, stockQuantity, lastUpdated
  ];
}

class PackageAvailabilityInfo extends Equatable {
  final String packageId;
  final String? gtin;
  final String? packSize;
  final String? brandName;
  final String? manufacturer;
  final String? countryCode;
  final List<PharmacyLocationInfo> pharmacyLocations;

  const PackageAvailabilityInfo({
    required this.packageId,
    this.gtin,
    this.packSize,
    this.brandName,
    this.manufacturer,
    this.countryCode,
    required this.pharmacyLocations,
  });

  factory PackageAvailabilityInfo.fromJson(Map<String, dynamic> json) => PackageAvailabilityInfo(
    packageId: json['package_id'],
    gtin: json['gtin'],
    packSize: json['pack_size'],
    brandName: json['brand_name'],
    manufacturer: json['manufacturer'],
    countryCode: json['country_code'],
    pharmacyLocations: (json['pharmacy_locations'] as List)
        .map((e) => PharmacyLocationInfo.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'package_id': packageId,
    'gtin': gtin,
    'pack_size': packSize,
    'brand_name': brandName,
    'manufacturer': manufacturer,
    'country_code': countryCode,
    'pharmacy_locations': pharmacyLocations.map((e) => e.toJson()).toList(),
  };

  // Helper getters for UI
  int? get lowestPrice => pharmacyLocations
      .where((p) => p.priceCents != null)
      .map((p) => p.priceCents!)
      .fold<int?>(null, (min, price) => min == null ? price : (price < min ? price : min));

  String get lowestPriceFormatted {
    final price = lowestPrice;
    if (price == null) return 'Price not available';
    return '€${(price / 100).toStringAsFixed(2)}';
  }

  int get totalStock => pharmacyLocations
      .map((p) => p.stockQuantity)
      .fold(0, (sum, stock) => sum + stock);

  int get pharmacyCount => pharmacyLocations.length;

  String get displayName {
    final parts = <String>[];
    if (brandName != null) parts.add(brandName!);
    if (packSize != null) parts.add(packSize!);
    return parts.isNotEmpty ? parts.join(' - ') : 'Package';
  }

  @override
  List<Object?> get props => [
    packageId, gtin, packSize, brandName, manufacturer, countryCode, pharmacyLocations
  ];
}

class ProductModel extends Equatable {
  final String productId;
  final String innName;
  final String displayName;  // Translated name
  final String? description;  // Translated description
  final String? atcCode;
  final String? form;
  final String? strength;
  final List<String> brandNames;
  final List<PackageAvailabilityInfo> availablePackages;
  final String language;

  const ProductModel({
    required this.productId,
    required this.innName,
    required this.displayName,
    this.description,
    this.atcCode,
    this.form,
    this.strength,
    required this.brandNames,
    required this.availablePackages,
    required this.language,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    productId: json['product_id'],
    innName: json['inn_name'],
    displayName: json['display_name'],
    description: json['description'],
    atcCode: json['atc_code'],
    form: json['form'],
    strength: json['strength'],
    brandNames: List<String>.from(json['brand_names'] ?? []),
    availablePackages: (json['available_packages'] as List)
        .map((e) => PackageAvailabilityInfo.fromJson(e))
        .toList(),
    language: json['language'],
  );

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'inn_name': innName,
    'display_name': displayName,
    'description': description,
    'atc_code': atcCode,
    'form': form,
    'strength': strength,
    'brand_names': brandNames,
    'available_packages': availablePackages.map((e) => e.toJson()).toList(),
    'language': language,
  };

  // Helper getters for UI
  String get searchDisplayName {
    final parts = <String>[];
    parts.add(displayName);
    if (strength != null) parts.add(strength!);
    if (form != null) parts.add(form!);
    return parts.join(' ');
  }

  int? get lowestPrice => availablePackages
      .map((p) => p.lowestPrice)
      .where((price) => price != null)
      .fold<int?>(null, (min, price) => min == null ? price! : (price! < min ? price : min));

  String get lowestPriceFormatted {
    final price = lowestPrice;
    if (price == null) return 'Price not available';
    return '€${(price / 100).toStringAsFixed(2)}';
  }

  int get totalAvailableStock => availablePackages
      .map((p) => p.totalStock)
      .fold(0, (sum, stock) => sum + stock);

  int get totalPharmacies => availablePackages
      .map((p) => p.pharmacyCount)
      .fold(0, (sum, count) => sum + count);

  bool get isAvailable => totalAvailableStock > 0;

  // Get unique cities where this product is available
  List<String> get availableCities {
    final cities = <String>{};
    for (final package in availablePackages) {
      for (final pharmacy in package.pharmacyLocations) {
        cities.add(pharmacy.pharmacyCity);
      }
    }
    return cities.toList()..sort();
  }

  @override
  List<Object?> get props => [
    productId, innName, displayName, description, atcCode, 
    form, strength, brandNames, availablePackages, language
  ];
}