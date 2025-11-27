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

  // Color Palette
  static const Color cBackground = Color(0xFF0F2A1D); // Darkest Green
  static const Color cCard = Color(0xFF375534);       // Dark Green
  static const Color cAccent = Color(0xFF6B9071);     // Medium Green
  static const Color cTextTint = Color(0xFFE3EED4);   // Lightest Green (Tinted White)

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ProductProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Fataak Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: cBackground,

          // Text Theme
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: cTextTint),
            bodyMedium: TextStyle(color: cTextTint),
            titleLarge: TextStyle(color: cTextTint),
            titleMedium: TextStyle(color: cTextTint),
            titleSmall: TextStyle(color: cAccent),
          ),

          colorScheme: const ColorScheme.dark(
            primary: cCard,
            onPrimary: cTextTint,
            secondary: cAccent,
            onSecondary: cBackground,
            surface: cBackground,
            onSurface: cTextTint,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: cBackground,
            foregroundColor: cTextTint,
            elevation: 0,
          ),

          cardTheme: CardThemeData(
            color: cCard,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: cCard,
            foregroundColor: cTextTint,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: cCard,
              foregroundColor: cTextTint,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: cTextTint,
            labelStyle: const TextStyle(color: cBackground),
            hintStyle: const TextStyle(color: cCard),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),

          // Global Scrollbar styling to match Card Color
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(cCard),
            trackColor: WidgetStateProperty.all(Colors.transparent),
            thickness: WidgetStateProperty.all(6.0),
            radius: const Radius.circular(10),
            thumbVisibility: WidgetStateProperty.all(true),
          ),

          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: cBackground,
            selectedItemColor: cTextTint,
            unselectedItemColor: cAccent, // Lighter green for better visibility
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
        ),
        home: const TabsScreen(),
      ),
    );
  }
}