// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double marketPrice;
  final double ourPrice;
  int stock;
  bool inStock;
  final String? imageUrl;
  final String unit;
  final String category;
  final bool isFeatured;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;


  Product({
    required this.id,
    required this.name,
    required this.marketPrice,
    required this.ourPrice,
    required this.stock,
    this.inStock = true,
    this.imageUrl,
    required this.unit,
    required this.category,
    this.isFeatured = false,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  // Add these methods
  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'],
      marketPrice: json['market_price'].toDouble(),
      ourPrice: json['our_price'].toDouble(),
      stock: json['stock'],
      inStock: json['in_stock'],
      imageUrl: json['image_url'],
      unit: json['unit'],
      category: json['category'],
      isFeatured: json['is_featured'],
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'market_price': marketPrice,
      'our_price': ourPrice,
      'stock': stock,
      'in_stock': inStock,
      'image_url': imageUrl,
      'unit': unit,
      'category': category,
      'is_featured': isFeatured,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}