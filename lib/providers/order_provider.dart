import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order.dart' as model;

class OrderProvider with ChangeNotifier {
  final List<model.Order> _pendingOrders = [];
  final List<model.Order> _confirmedOrders = [];
  final List<model.Order> _notOrdered = [];

  List<model.Order> get pendingOrders => [..._pendingOrders];
  List<model.Order> get confirmedOrders => [..._confirmedOrders];
  List<model.Order> get notOrdered => [..._notOrdered];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchPendingOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
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
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          ),
        );
      }
    } catch (error) {
      debugPrint("Error fetching pending orders: $error"); // ADDED FOR DEBUGGING
    }
    notifyListeners();
  }

  Future<void> fetchConfirmedOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'confirmed')
          .orderBy('timestamp', descending: true)
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
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          ),
        );
      }
    } catch (error) {
      debugPrint("Error fetching confirmed orders: $error"); // ADDED FOR DEBUGGING
    }
    notifyListeners();
  }

  Future<void> fetchNotOrdered() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'notOrdered')
          .orderBy('timestamp', descending: true)
          .get();

      _notOrdered.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        _notOrdered.add(
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
            status: 'notOrdered',
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          ),
        );
      }
    } catch (error) {
      debugPrint("Error fetching not ordered items: $error"); // ADDED FOR DEBUGGING
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
          .collection('items')
          .where('name', isEqualTo: productName)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        final productDoc = productSnapshot.docs.first;
        final currentStock = productDoc['stock'];
        await _firestore.collection('items').doc(productDoc.id).update({
          'stock': currentStock - quantity,
        });
      }
    }

    _pendingOrders.removeWhere((o) => o.id == order.id);
    _confirmedOrders.add(order);
    notifyListeners();
  }

  Future<void> markAsNotOrdered(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'notOrdered',
    });
    _pendingOrders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
    _notOrdered.removeWhere((o) => o.id == orderId);
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
          .collection('items')
          .where('name', isEqualTo: productName)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        final productDoc = productSnapshot.docs.first;
        final currentStock = productDoc['stock'];
        await _firestore.collection('items').doc(productDoc.id).update({
          'stock': currentStock + quantity,
        });
      }
    }

    _confirmedOrders.removeWhere((o) => o.id == order.id);
    _pendingOrders.add(order);
    notifyListeners();
  }
}