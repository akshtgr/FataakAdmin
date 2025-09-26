import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/product_provider.dart';
import './providers/order_provider.dart';
import './screens/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization is no longer needed
  runApp(const FataakAdminApp());
}

class FataakAdminApp extends StatelessWidget {
  const FataakAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ProductProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Fataak Admin',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const ProductListScreen(), // Set ProductListScreen as the home
      ),
    );
  }
}