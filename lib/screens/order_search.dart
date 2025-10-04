import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderSearchDelegate extends SearchDelegate<Order?> {
  final List<Order> orders;

  OrderSearchDelegate(this.orders);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredOrders = query.isEmpty
        ? orders
        : orders
        .where((order) =>
    order.customerName.toLowerCase().contains(query.toLowerCase()) ||
        order.phone.contains(query))
        .toList();

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order.customerName}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Phone: ${order.phone}'),
                Text('Address: ${order.address}'),
                Text('Total: \$${order.totalPrice}'),
                const Divider(),
                ...order.items
                    .map((item) => Text('${item['name']} x${item['quantity']}')),
              ],
            ),
          ),
        );
      },
    );
  }
}