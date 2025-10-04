import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> get products => [..._products];

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('items').get();
      _products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('items').add(product.toJson());

      // --- THIS IS THE FIX ---
      // The newProduct object now includes all the required fields.
      final newProduct = Product(
        id: docRef.id,
        name: product.name,
        imageUrl: product.imageUrl,
        marketPrice: product.marketPrice,
        ourPrice: product.ourPrice,
        priceUnit: product.priceUnit, // Was missing
        unit: product.unit,
        stock: product.stock,
        stockUnit: product.stockUnit, // Was missing
        stockLabel: product.stockLabel, // Was missing
        inStock: product.inStock,
        category: product.category,
        isFeatured: product.isFeatured,
        tags: product.tags,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final prodIndex = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (prodIndex >= 0) {
      try {
        await _firestore
            .collection('items')
            .doc(updatedProduct.id)
            .update(updatedProduct.toJson());
        _products[prodIndex] = updatedProduct;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    final existingProductIndex = _products.indexWhere((p) => p.id == productId);
    if (existingProductIndex < 0) return; // Guard against invalid index

    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();

    try {
      await _firestore.collection('items').doc(productId).delete();
    } catch (error) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      rethrow;
    }
  }
}