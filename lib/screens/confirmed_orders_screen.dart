import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class ConfirmedOrdersScreen extends StatefulWidget {
  const ConfirmedOrdersScreen({super.key});

  @override
  State<ConfirmedOrdersScreen> createState() => _ConfirmedOrdersScreenState();
}

class _ConfirmedOrdersScreenState extends State<ConfirmedOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).fetchConfirmedOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmed Orders')),
      body: RefreshIndicator(
        onRefresh: () => orderProvider.fetchConfirmedOrders(),
        child: ListView.builder(
          itemCount: orderProvider.confirmedOrders.length,
          itemBuilder: (ctx, i) {
            final order = orderProvider.confirmedOrders[i];
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
                    ...order.items.map((item) =>
                        Text('${item['name']} x${item['quantity']}')),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Mark as Pending'),
                          onPressed: () {
                            orderProvider.markAsPending(order);
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
      ),
    );
  }
}