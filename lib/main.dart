import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './providers/product_provider.dart';
import './providers/order_provider.dart';
import './screens/tabs_screen.dart';

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
        ChangeNotifierProvider(create: (ctx) => ProductProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Fataak Admin',
        theme: ThemeData(
          primarySwatch: Colors.grey,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white, // ADDED THIS LINE
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
          ),
        ),
        home: const TabsScreen(),
      ),
    );
  }
}