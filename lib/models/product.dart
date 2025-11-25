import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVariant {
  String variantId;
  String label;
  int quantity;
  String quantityUnit;
  double marketPrice;
  double ourPrice;
  int discountPercent;
  bool isDefault;
  String pricingRule;

  ProductVariant({
    required this.variantId,
    required this.label,
    required this.quantity,
    required this.quantityUnit,
    required this.marketPrice,
    required this.ourPrice,
    this.discountPercent = 0,
    this.isDefault = false,
    this.pricingRule = 'manual',
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      variantId: json['variant_id'] ?? '',
      label: json['label'] ?? '',
      quantity: (json['quantity'] ?? 0).toInt(),
      quantityUnit: json['quantity_unit'] ?? '',
      marketPrice: (json['market_price'] ?? 0).toDouble(),
      ourPrice: (json['our_price'] ?? 0).toDouble(),
      discountPercent: (json['discount_percent'] ?? 0).toInt(),
      isDefault: json['is_default'] ?? false,
      pricingRule: json['pricing_rule'] ?? 'manual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'label': label,
      'quantity': quantity,
      'quantity_unit': quantityUnit,
      'market_price': marketPrice,
      'our_price': ourPrice,
      'discount_percent': discountPercent,
      'is_default': isDefault,
      'pricing_rule': pricingRule,
    };
  }
}

class Product {
  String id;
  String englishName;
  String hinglishName;
  String category;
  String imageUrl;
  bool inStock;
  bool isActive;
  String baseUnit;
  int minOrderQty;
  String minOrderUnit;
  List<ProductVariant> variants;
  List<String> healthBenefits;
  String description;
  List<String> tags;
  List<String> searchKeywords;
  List<String> suitableFor; // NEW
  String emoji; // NEW
  DateTime timestampAdded;

  Product({
    required this.id,
    required this.englishName,
    required this.hinglishName,
    required this.category,
    required this.imageUrl,
    required this.inStock,
    required this.isActive,
    required this.baseUnit,
    required this.minOrderQty,
    required this.minOrderUnit,
    required this.variants,
    required this.healthBenefits,
    required this.description,
    required this.tags,
    required this.searchKeywords,
    required this.suitableFor,
    required this.emoji,
    required this.timestampAdded,
  });

  // Helper to get the default variant for display
  ProductVariant get defaultVariant {
    if (variants.isEmpty) {
      return ProductVariant(
        variantId: 'dummy',
        label: 'N/A',
        quantity: 0,
        quantityUnit: '',
        marketPrice: 0,
        ourPrice: 0,
      );
    }
    return variants.firstWhere((v) => v.isDefault, orElse: () => variants.first);
  }

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) return dateValue.toDate();
      if (dateValue is String) return DateTime.tryParse(dateValue) ?? DateTime.now();
      return DateTime.now();
    }

    return Product(
      id: id,
      englishName: json['english_name'] ?? '',
      hinglishName: json['hinglish_name'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      inStock: json['in_stock'] ?? true,
      isActive: json['is_active'] ?? true,
      baseUnit: json['base_unit'] ?? 'g',
      minOrderQty: (json['min_order_qty'] ?? 0).toInt(),
      minOrderUnit: json['min_order_unit'] ?? 'g',
      variants: (json['variants'] as List<dynamic>?)
          ?.map((v) => ProductVariant.fromJson(v))
          .toList() ?? [],
      healthBenefits: List<String>.from(json['health_benefits'] ?? []),
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      searchKeywords: List<String>.from(json['search_keywords'] ?? []),
      suitableFor: List<String>.from(json['suitable_for'] ?? []),
      emoji: json['emoji'] ?? '',
      timestampAdded: parseDate(json['timestamp_added']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'english_name': englishName,
      'hinglish_name': hinglishName,
      'category': category,
      'image_url': imageUrl,
      'in_stock': inStock,
      'is_active': isActive,
      'base_unit': baseUnit,
      'min_order_qty': minOrderQty,
      'min_order_unit': minOrderUnit,
      'variants': variants.map((v) => v.toJson()).toList(),
      'health_benefits': healthBenefits,
      'description': description,
      'tags': tags,
      'search_keywords': searchKeywords,
      'suitable_for': suitableFor,
      'emoji': emoji,
      'timestamp_added': timestampAdded.toIso8601String(),
    };
  }
}