// data/models/product.dart
import 'package:equatable/equatable.dart';

// Simple search item for typeahead/search results
class ProductSearchItem extends Equatable {
  final String productId;
  final String innName;
  final String displayName;  // Translated name or inn_name
  final String? form;
  final String? strength;

  const ProductSearchItem({
    required this.productId,
    required this.innName,
    required this.displayName,
    this.form,
    this.strength,
  });

  factory ProductSearchItem.fromJson(Map<String, dynamic> json) => ProductSearchItem(
    productId: json['product_id'],
    innName: json['inn_name'],
    displayName: json['display_name'],
    form: json['form'],
    strength: json['strength'],
  );

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'inn_name': innName,
    'display_name': displayName,
    'form': form,
    'strength': strength,
  };

  // Helper getter for search display
  String get searchDisplayName {
    final parts = <String>[];
    parts.add(displayName);
    if (strength != null) parts.add(strength!);
    if (form != null) parts.add(form!);
    return parts.join(' ');
  }

  @override
  List<Object?> get props => [productId, innName, displayName, form, strength];
}

// Detailed pharmacy location info
class PharmacyLocationInfo extends Equatable {
  final String pharmacyId;
  final String pharmacyName;
  final String pharmacyAddress;
  final String pharmacyCity;
  final String pharmacyCountry;
  final double? lat;
  final double? lng;
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
    this.lat,
    this.lng,
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
    lat: json['lat']?.toDouble(),
    lng: json['lng']?.toDouble(),
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
    'lat': lat,
    'lng': lng,
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

  bool get hasCoordinates => lat != null && lng != null;

  @override
  List<Object?> get props => [
    pharmacyId, pharmacyName, pharmacyAddress, pharmacyCity, 
    pharmacyCountry, lat, lng, priceCents, currency, stockQuantity, lastUpdated
  ];
}

// Package availability info with pharmacy locations
class PackageAvailabilityInfo extends Equatable {
  final String packageId;
  final String? gtin;
  final String? packSize;
  final String? brandName;
  final String? manufacturer;
  final String? countryCode;
  final List<String>? imageUrls;
  final List<PharmacyLocationInfo> pharmacyLocations;

  const PackageAvailabilityInfo({
    required this.packageId,
    this.gtin,
    this.packSize,
    this.brandName,
    this.manufacturer,
    this.countryCode,
    this.imageUrls,
    required this.pharmacyLocations,
  });

  factory PackageAvailabilityInfo.fromJson(Map<String, dynamic> json) => PackageAvailabilityInfo(
    packageId: json['package_id'],
    gtin: json['gtin'],
    packSize: json['pack_size'],
    brandName: json['brand_name'],
    manufacturer: json['manufacturer'],
    countryCode: json['country_code'],
    imageUrls: (json['image_urls'] as List?)
        ?.map((e) => e as String)
        .toList(),
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
    'image_urls': imageUrls,
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

// Detailed product model with full information
class ProductDetailModel extends Equatable {
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

  const ProductDetailModel({
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

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) => ProductDetailModel(
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

  // Convert to search item
  ProductSearchItem toSearchItem() => ProductSearchItem(
    productId: productId,
    innName: innName,
    displayName: displayName,
    form: form,
    strength: strength,
  );

  @override
  List<Object?> get props => [
    productId, innName, displayName, description, atcCode, 
    form, strength, brandNames, availablePackages, language
  ];
}

class PharmacyPackageLine extends Equatable {
  final String packageId;
  final int? priceCents;
  final String? currency;
  final int stockQuantity;
  final String? lastUpdated;
  final String brandName;

  const PharmacyPackageLine({
    required this.packageId,
    this.priceCents,
    this.currency,
    required this.stockQuantity,
    this.lastUpdated,
    required this.brandName,
  });

  factory PharmacyPackageLine.fromJson(Map<String, dynamic> json) => PharmacyPackageLine(
        packageId: json['package_id'],
        priceCents: json['price_cents'],
        currency: json['currency'],
        stockQuantity: json['stock_quantity'],
        lastUpdated: json['last_updated'],
        brandName: json['brand_name'],
      );

  Map<String, dynamic> toJson() => {
        'package_id': packageId,
        'price_cents': priceCents,
        'currency': currency,
        'stock_quantity': stockQuantity,
        'last_updated': lastUpdated,
        'brand_name': brandName,
      };

  @override
  List<Object?> get props => [
        packageId,
        priceCents,
        currency,
        stockQuantity,
        lastUpdated,
        brandName,
      ];
}

class PharmacySearchResult extends Equatable {
  final String pharmacyId;
  final String pharmacyName;
  final String? address;
  final String? city;
  final String? country;
  final double? lat;
  final double? lng;
  final double? distanceKm;
  final int? minPriceCents;
  final int? totalPriceCents;
  final int pkgCount;
  final List<PharmacyPackageLine> packages;

  const PharmacySearchResult({
    required this.pharmacyId,
    required this.pharmacyName,
    this.address,
    this.city,
    this.country,
    this.lat,
    this.lng,
    this.distanceKm,
    this.minPriceCents,
    this.totalPriceCents,
    required this.pkgCount,
    required this.packages,
  });

  factory PharmacySearchResult.fromJson(Map<String, dynamic> json) => PharmacySearchResult(
        pharmacyId: json['pharmacy_id'],
        pharmacyName: json['pharmacy_name'],
        address: json['address'],
        city: json['city'],
        country: json['country'],
        lat: json['lat']?.toDouble(),
        lng: json['lng']?.toDouble(),
        distanceKm: json['distance_km']?.toDouble(),
        minPriceCents: json['min_price_cents'],
        totalPriceCents: json['total_price_cents'],
        pkgCount: json['pkg_count'],
        packages: (json['packages'] as List)
            .map((e) => PharmacyPackageLine.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'pharmacy_id': pharmacyId,
        'pharmacy_name': pharmacyName,
        'address': address,
        'city': city,
        'country': country,
        'lat': lat,
        'lng': lng,
        'distance_km': distanceKm,
        'min_price_cents': minPriceCents,
        'total_price_cents': totalPriceCents,
        'pkg_count': pkgCount,
        'packages': packages.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        pharmacyId,
        pharmacyName,
        address,
        city,
        country,
        lat,
        lng,
        distanceKm,
        minPriceCents,
        totalPriceCents,
        pkgCount,
        packages,
      ];
}

class PharmaciesSearchRequest extends Equatable {
  final List<String> packageIds;
  final double? lat;
  final double? lng;
  final int? radiusKm;
  final bool mustHaveAll;
  final String sortBy;
  final int limit;

  const PharmaciesSearchRequest({
    required this.packageIds,
    this.lat,
    this.lng,
    this.radiusKm = 120,
    this.mustHaveAll = false,
    this.sortBy = "distance",
    this.limit = 20,
  });

  factory PharmaciesSearchRequest.fromJson(Map<String, dynamic> json) => PharmaciesSearchRequest(
    packageIds: List<String>.from(json['package_ids'] ?? []),
    lat: json['lat']?.toDouble(),
    lng: json['lng']?.toDouble(),
    radiusKm: json['radius_km'],
    mustHaveAll: json['must_have_all'],
    sortBy: json['sort_by'],
    limit: json['limit'],
  );

  Map<String, dynamic> toJson() => {
    'package_ids': packageIds,
    'lat': lat,
    'lng': lng,
    'radius_km': radiusKm,
    'must_have_all': mustHaveAll,
    'sort_by': sortBy,
    'limit': limit,
  };

  @override
  List<Object?> get props => [
    packageIds,
    lat,
    lng,
    radiusKm,
    mustHaveAll,
    sortBy,
    limit,
  ];
}

// Legacy aliases for backward compatibility
@Deprecated('Use ProductPackagesModel instead')
typedef ProductModel = ProductSearchItem;