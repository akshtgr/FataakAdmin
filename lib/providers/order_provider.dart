import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as model; // Added a prefix

class OrderProvider with ChangeNotifier {
  List<model.Order> _orders = []; // Used the prefix

  List<model.Order> get orders => [..._orders]; // Used the prefix

  final CollectionReference _ordersCollection =
  FirebaseFirestore.instance.collection('orders');

  Future<void> fetchOrders() async {
    try {
      final snapshot =
      await _ordersCollection.where('status', isEqualTo: 'Pending').get();
      _orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return model.Order( // Used the prefix
          id: doc.id,
          customerName: data['customerName'],
          items: List<Map<String, dynamic>>.from(data['items']),
          totalPrice: data['totalPrice'],
          address: data['address'],
          status: data['status'],
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> confirmOrder(model.Order order) async { // Used the prefix
    try {
      // Create a write batch to update multiple documents atomically
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update product stock
      for (var item in order.items) {
        final productRef = FirebaseFirestore.instance
            .collection('products')
            .doc(item['productId']);
        batch.update(productRef, {'stock': FieldValue.increment(-item['quantity'])});
      }

      // Update order status
      final orderRef = _ordersCollection.doc(order.id);
      batch.update(orderRef, {'status': 'Confirmed'});

      await batch.commit();

      fetchOrders();
    } catch (e) {
      print(e);
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
      fetchOrders();
    } catch (e) {
      print(e);
    }
  }
}