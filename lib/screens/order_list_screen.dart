import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'order_search.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  OrderListScreenState createState() => OrderListScreenState();
}

class OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).fetchPendingOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: OrderSearchDelegate(orderProvider.pendingOrders),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProvider.fetchPendingOrders(),
        child: orderProvider.pendingOrders.isEmpty
            ? const Center(child: Text('No pending orders.'))
            : ListView.builder(
          itemCount: orderProvider.pendingOrders.length,
          itemBuilder: (ctx, i) {
            final order = orderProvider.pendingOrders[i];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: ${order.customerName}',
                        style:
                        const TextStyle(fontWeight: FontWeight.bold)),
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
                          child: const Text('Not Ordered'),
                          onPressed: () {
                            orderProvider.markAsNotOrdered(order.id);
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
      ),
    );
  }
}