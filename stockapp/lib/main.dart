import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

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
      ],
      child: MaterialApp(
        title: 'Stock App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const Wrapper(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/main': (_) => const MainNavigation(),
        },
      ),
    );
  }
}
