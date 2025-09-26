import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  // Replace Firebase with a local list for demonstration
  final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Sample Item A',
      marketPrice: 150.0,
      ourPrice: 125.0,
      stock: 40,
    ),
    Product(
      id: 'p2',
      name: 'Sample Item B',
      marketPrice: 90.0,
      ourPrice: 85.0,
      stock: 60,
    ),
    Product(
      id: 'p3',
      name: 'Sample Item C',
      marketPrice: 200.0,
      ourPrice: 180.0,
      stock: 25,
    ),
  ];

  List<Product> get products => [..._products];

  // This function no longer needs to be async or call a database
  void fetchProducts() {
    // The data is already here, so we just notify listeners.
    notifyListeners();
  }

  void addProduct(Product product) {
    final newProduct = Product(
      id: DateTime.now().toString(), // Create a temporary unique ID
      name: product.name,
      marketPrice: product.marketPrice,
      ourPrice: product.ourPrice,
      stock: product.stock,
      isOutOfStock: product.isOutOfStock,
    );
    _products.add(newProduct);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final prodIndex = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (prodIndex >= 0) {
      _products[prodIndex] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}