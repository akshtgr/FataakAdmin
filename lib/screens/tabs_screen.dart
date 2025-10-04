import 'package:fataak_admin/screens/confirmed_orders_screen.dart';
import 'package:fataak_admin/screens/not_ordered_screen.dart';
import 'package:fataak_admin/screens/order_list_screen.dart';
import 'package:fataak_admin/screens/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ProductListScreen(),
      const OrderListScreen(),
      const ConfirmedOrdersScreen(),
      const NotOrderedScreen(),
    ];

    // Fetch all data needed for badges right away
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.fetchPendingOrders();
    orderProvider.fetchConfirmedOrders();
    orderProvider.fetchNotOrdered();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  Widget _buildBadge(
      {required int count,
        required Color backgroundColor,
        required Widget child}) {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -12, end: -12),
      badgeContent: Text(
        count.toString(),
        style: const TextStyle(
            color: Colors.white, fontSize: 10), // Font size adjusted
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: backgroundColor,
      ),
      showBadge: true,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        iconSize: 22,
        items: [
          BottomNavigationBarItem(
            icon: Consumer<ProductProvider>(
              builder: (_, productData, ch) => _buildBadge(
                count: productData.products.length,
                backgroundColor: const Color(0xFFCF00A2), // COLOR CHANGED HERE
                child: ch!,
              ),
              child: const Icon(Icons.list),
            ),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Consumer<OrderProvider>(
              builder: (_, orderData, ch) => _buildBadge(
                count: orderData.pendingOrders.length,
                backgroundColor: const Color(0xFF0A54EB),
                child: ch!,
              ),
              child: const Icon(Icons.pending_actions),
            ),
            label: 'Pending Orders',
          ),
          BottomNavigationBarItem(
            icon: Consumer<OrderProvider>(
              builder: (_, orderData, ch) => _buildBadge(
                count: orderData.confirmedOrders.length,
                backgroundColor: const Color(0xFF00B813),
                child: ch!,
              ),
              child: const Icon(Icons.check_circle),
            ),
            label: 'Confirmed Orders',
          ),
          BottomNavigationBarItem(
            icon: Consumer<OrderProvider>(
              builder: (_, orderData, ch) => _buildBadge(
                count: orderData.notOrdered.length,
                backgroundColor: const Color(0xFFFF1E00),
                child: ch!,
              ),
              child: const Icon(Icons.cancel),
            ),
            label: 'Not Ordered',
          ),
        ],
      ),
    );
  }
}