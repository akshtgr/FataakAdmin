import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order.dart' as model;

class OrderProvider with ChangeNotifier {
  final List<model.Order> _pendingOrders = [];
  final List<model.Order> _confirmedOrders = [];

  List<model.Order> get pendingOrders => [..._pendingOrders];
  List<model.Order> get confirmedOrders => [..._confirmedOrders];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchPendingOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .get();

    _pendingOrders.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      _pendingOrders.add(
        model.Order(
          id: doc.id,
          customerName: data['customerName'],
          phone: data['phone'],
          address: data['address'],
          totalPrice: data['totalAmount'],
          items: (data['items'] as List<dynamic>)
              .map((item) => {
            'name': item['name'],
            'quantity': item['qty'],
          })
              .toList(),
          status: 'Pending',
        ),
      );
    }
    notifyListeners();
  }

  Future<void> fetchConfirmedOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'confirmed')
        .get();

    _confirmedOrders.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      _confirmedOrders.add(
        model.Order(
          id: doc.id,
          customerName: data['customerName'],
          phone: data['phone'],
          address: data['address'],
          totalPrice: data['totalAmount'],
          items: (data['items'] as List<dynamic>)
              .map((item) => {
            'name': item['name'],
            'quantity': item['qty'],
          })
              .toList(),
          status: 'Confirmed',
        ),
      );
    }
    notifyListeners();
  }

  Future<void> confirmOrder(model.Order order) async {
    await _firestore.collection('orders').doc(order.id).update({
      'status': 'confirmed',
    });

    for (var item in order.items) {
      final productName = item['name'];
      final quantity = item['quantity'];

      final productSnapshot = await _firestore
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        final productDoc = productSnapshot.docs.first;
        final currentStock = productDoc['stock'];
        await _firestore.collection('products').doc(productDoc.id).update({
          'stock': currentStock - quantity,
        });
      }
    }

    _pendingOrders.removeWhere((o) => o.id == order.id);
    _confirmedOrders.add(order);
    notifyListeners();
  }

  Future<void> notOrdered(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'notOrdered',
    });
    _pendingOrders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  Future<void> markAsPending(model.Order order) async {
    await _firestore.collection('orders').doc(order.id).update({
      'status': 'pending',
    });

    for (var item in order.items) {
      final productName = item['name'];
      final quantity = item['quantity'];

      final productSnapshot = await _firestore
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        final productDoc = productSnapshot.docs.first;
        final currentStock = productDoc['stock'];
        await _firestore.collection('products').doc(productDoc.id).update({
          'stock': currentStock + quantity,
        });
      }
    }

    _confirmedOrders.removeWhere((o) => o.id == order.id);
    _pendingOrders.add(order);
    notifyListeners();
  }
}