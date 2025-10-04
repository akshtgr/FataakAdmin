import 'package:flutter/material.dart'; // Corrected import
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'order_search.dart';

class NotOrderedScreen extends StatefulWidget {
  const NotOrderedScreen({super.key});

  @override
  State<NotOrderedScreen> createState() => _NotOrderedScreenState();
}

class _NotOrderedScreenState extends State<NotOrderedScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).fetchNotOrdered();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Ordered'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: OrderSearchDelegate(orderProvider.notOrdered),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProvider.fetchNotOrdered(),
        child: orderProvider.notOrdered.isEmpty
            ? const Center(child: Text('No "not ordered" items.'))
            : ListView.builder(
          itemCount: orderProvider.notOrdered.length,
          itemBuilder: (ctx, i) {
            final order = orderProvider.notOrdered[i];
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
                          child: const Text('Delete Order'),
                          onPressed: () {
                            orderProvider.deleteOrder(order.id);
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