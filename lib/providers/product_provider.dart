// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> get products => [..._products];

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toJson());
      final newProduct = Product(
        id: docRef.id,
        name: product.name,
        marketPrice: product.marketPrice,
        ourPrice: product.ourPrice,
        stock: product.stock,
        isOutOfStock: product.isOutOfStock,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final prodIndex = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (prodIndex >= 0) {
      try {
        await _firestore
            .collection('products')
            .doc(updatedProduct.id)
            .update(updatedProduct.toJson());
        _products[prodIndex] = updatedProduct;
        notifyListeners();
      } catch (error) {
        print(error);
        throw error;
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    final existingProductIndex = _products.indexWhere((p) => p.id == productId);
    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();

    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (error) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      print(error);
      throw error;
    }
  }
}