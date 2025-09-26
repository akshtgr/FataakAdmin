import 'package:flutter/material.dart'; // Added this import
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  OrderListScreenState createState() => OrderListScreenState();
}

class OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Orders')),
      body: ListView.builder(
        itemCount: orderProvider.orders.length,
        itemBuilder: (ctx, i) {
          final order = orderProvider.orders[i];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${order.customerName}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Address: ${order.address}'),
                  Text('Total: \$${order.totalPrice}'),
                  const Divider(),
                  ...order.items.map(
                          (item) => Text('${item['name']} x${item['quantity']}')),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          orderProvider.cancelOrder(order.id);
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Confirm'),
                        onPressed: () {
                          orderProvider.confirmOrder(order);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}