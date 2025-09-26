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
}