// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double marketPrice;
  final double ourPrice;
  int stock;
  bool isOutOfStock;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.marketPrice,
    required this.ourPrice,
    required this.stock,
    this.isOutOfStock = false,
    this.imageUrl,
  });

  // Add these methods
  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'],
      marketPrice: json['marketPrice'].toDouble(),
      ourPrice: json['ourPrice'].toDouble(),
      stock: json['stock'],
      isOutOfStock: json['isOutOfStock'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'marketPrice': marketPrice,
      'ourPrice': ourPrice,
      'stock': stock,
      'isOutOfStock': isOutOfStock,
      'imageUrl': imageUrl,
    };
  }
}