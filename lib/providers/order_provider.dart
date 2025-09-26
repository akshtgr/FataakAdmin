import 'package:flutter/material.dart';
import '../models/order.dart' as model; // Use a prefix to avoid name conflicts

class OrderProvider with ChangeNotifier {
  // Replace Firebase with a local list for demonstration
  final List<model.Order> _orders = [
    model.Order(
      id: 'o1',
      customerName: 'Jane Smith',
      items: [
        {'name': 'Sample Item A', 'quantity': 1, 'productId': 'p1'},
        {'name': 'Sample Item B', 'quantity': 2, 'productId': 'p2'}
      ],
      totalPrice: 295.0,
      address: '456 Oak Avenue, Someplace',
      status: 'Pending',
    ),
  ];

  List<model.Order> get orders => [..._orders];

  void fetchOrders() {
    // Data is already loaded, just notify
    notifyListeners();
  }

  void confirmOrder(model.Order order) {
    // In this sample, confirming an order just removes it from the list
    _orders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }
}