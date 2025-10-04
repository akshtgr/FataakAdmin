import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double marketPrice;
  final double ourPrice;
  final String priceUnit; // ADDED
  final String unit;
  int stock;
  final String stockUnit; // ADDED
  final String stockLabel; // ADDED
  bool inStock;
  final String category;
  final bool isFeatured;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.marketPrice,
    required this.ourPrice,
    required this.priceUnit, // ADDED
    required this.unit,
    required this.stock,
    required this.stockUnit, // ADDED
    required this.stockLabel, // ADDED
    this.inStock = true,
    required this.category,
    this.isFeatured = false,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) return dateValue.toDate();
      if (dateValue is String) return DateTime.tryParse(dateValue) ?? DateTime.now();
      return DateTime.now();
    }

    return Product(
      id: id,
      name: json['name'] ?? 'No Name',
      imageUrl: json['image_url'] ?? '',
      marketPrice: (json['market_price'] ?? 0).toDouble(),
      ourPrice: (json['our_price'] ?? 0).toDouble(),
      priceUnit: json['price_unit'] ?? 'per kg', // ADDED
      unit: json['unit'] ?? 'kg',
      stock: json['stock'] ?? 0,
      stockUnit: json['stock_unit'] ?? 'kg', // ADDED
      stockLabel: json['stock_label'] ?? 'left', // ADDED
      inStock: json['in_stock'] ?? false,
      category: json['category'] ?? 'Uncategorized',
      isFeatured: json['is_featured'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'market_price': marketPrice,
      'our_price': ourPrice,
      'price_unit': priceUnit, // ADDED
      'unit': unit,
      'stock': stock,
      'stock_unit': stockUnit, // ADDED
      'stock_label': stockLabel, // ADDED
      'in_stock': inStock,
      'category': category,
      'is_featured': isFeatured,
      'tags': tags,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}