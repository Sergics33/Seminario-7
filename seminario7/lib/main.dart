import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/check_auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

import 'services/auth_service.dart';
import 'services/products_service.dart';
import 'services/notifications_service.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Productos Firebase',
        initialRoute: 'checking',
        
        scaffoldMessengerKey: NotificationsService.messengerKey, 
        
        routes: {
          'checking': (_) => const CheckAuthScreen(),
          'login'   : (_) => const LoginScreen(),
          'signup'  : (_) => const RegisterScreen(),
          'home'    : (_) => const HomeScreen(),
          'product' : (_) => const ProductScreen(),
        },
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            color: Colors.indigo
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.indigo,
            elevation: 0
          )
        ),
      ),
    );
  }
}