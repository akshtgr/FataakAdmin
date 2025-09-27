// lib/models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double marketPrice;
  final double ourPrice;
  int stock;
  bool inStock;
  final String unit;
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
    required this.stock,
    this.inStock = true,
    required this.unit,
    required this.category,
    this.isFeatured = false,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'],
      imageUrl: json['image_url'],
      marketPrice: json['market_price'].toDouble(),
      ourPrice: json['our_price'].toDouble(),
      stock: json['stock'],
      inStock: json['in_stock'],
      unit: json['unit'],
      category: json['category'],
      isFeatured: json['is_featured'],
      tags: List<String>.from(json['tags']),
      // --- FIX STARTS HERE ---
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      // --- FIX ENDS HERE ---
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'market_price': marketPrice,
      'our_price': ourPrice,
      'stock': stock,
      'in_stock': inStock,
      'unit': unit,
      'category': category,
      'is_featured': isFeatured,
      'tags': tags,
      'created_at': Timestamp.fromDate(createdAt), // Storing as Timestamp
      'updated_at': Timestamp.fromDate(updatedAt), // Storing as Timestamp
    };
  }
}