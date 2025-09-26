import 'package:flutter/material.dart';
import '../models/order.dart' as model; // Use a prefix to avoid name conflicts

class OrderProvider with ChangeNotifier {
  // The local list is now empty.
  final List<model.Order> _orders = [];

  List<model.Order> get orders => [..._orders];

  void fetchOrders() {
    // This will be connected to Firebase in the future.
    notifyListeners();
  }

  void confirmOrder(model.Order order) {
    _orders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }
}