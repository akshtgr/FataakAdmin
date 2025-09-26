import 'package:flutter/material.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => [..._products];

  final CollectionReference _productsCollection =
  FirebaseFirestore.instance.collection('products');

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _productsCollection.get();
      _products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'],
          marketPrice: data['marketPrice'],
          ourPrice: data['ourPrice'],
          stock: data['stock'],
          isOutOfStock: data['isOutOfStock'] ?? false,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      // Handle error appropriately
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _productsCollection.add({
        'name': product.name,
        'marketPrice': product.marketPrice,
        'ourPrice': product.ourPrice,
        'stock': product.stock,
        'isOutOfStock': product.isOutOfStock,
      });
      fetchProducts();
    } catch (e) {
      // Handle error appropriately
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productsCollection.doc(product.id).update({
        'name': product.name,
        'marketPrice': product.marketPrice,
        'ourPrice': product.ourPrice,
        'stock': product.stock,
        'isOutOfStock': product.isOutOfStock,
      });
      fetchProducts();
    } catch (e) {
      // Handle error appropriately
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
      fetchProducts();
    } catch (e) {
      // Handle error appropriately
    }
  }
}