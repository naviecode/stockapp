import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/core/theme_provider.dart';
import 'package:stockapp/providers/portfolio_provider.dart';
import 'package:stockapp/providers/transaction_provider.dart';

import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/wrapper.dart';
import 'providers/stock_provider.dart'; 
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_navigation.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadUserFromPrefs()),
        ChangeNotifierProvider(create: (_) => StockProvider()..listenStocks()), 
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Stock App',
            theme: themeProvider.themeData, // ✅ lấy theme từ provider
            debugShowCheckedModeBanner: false,
            home: const Wrapper(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/main': (_) => const MainNavigation(),
            },
          );
        },
      ),
    );
  }
}
