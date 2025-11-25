import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> get products => [..._products];

  // Collection name updated to 'products'
  static const String collectionName = 'products';

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
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
      DocumentReference docRef;
      // Use ID if provided (like "watermelonDarkGreen"), otherwise auto-gen
      if (product.id.isNotEmpty) {
        docRef = _firestore.collection(collectionName).doc(product.id);
        await docRef.set(product.toJson());
      } else {
        docRef = await _firestore.collection(collectionName).add(product.toJson());
      }

      final newProduct = Product(
        id: docRef.id,
        englishName: product.englishName,
        hinglishName: product.hinglishName,
        category: product.category,
        imageUrl: product.imageUrl,
        inStock: product.inStock,
        isActive: product.isActive,
        baseUnit: product.baseUnit,
        minOrderQty: product.minOrderQty,
        minOrderUnit: product.minOrderUnit,
        variants: product.variants,
        healthBenefits: product.healthBenefits,
        description: product.description,
        tags: product.tags,
        searchKeywords: product.searchKeywords,
        suitableFor: product.suitableFor,
        emoji: product.emoji,
        timestampAdded: product.timestampAdded,
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
            .collection(collectionName)
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
    if (existingProductIndex < 0) return;

    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();

    try {
      await _firestore.collection(collectionName).doc(productId).delete();
    } catch (error) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      rethrow;
    }
  }
}