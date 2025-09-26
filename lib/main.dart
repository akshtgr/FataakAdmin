import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './providers/product_provider.dart';
import './providers/order_provider.dart';
import './screens/login_screen.dart';
import './screens/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FataakAdminApp());
}

class FataakAdminApp extends StatelessWidget {
  const FataakAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => ProductProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Fataak Admin',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) =>
          auth.isAuthenticated ? const ProductListScreen() : const LoginScreen(),
        ),
      ),
    );
  }
}