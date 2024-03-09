import 'package:buscaprodmt/src/pages/login_page.dart';
import 'package:buscaprodmt/src/pages/search_page.dart';
import 'package:buscaprodmt/src/pages/splash_screen_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash',
      routes: {
        'splash': (context) => const SplashScreenPage(),
        'search': (context) => const SearchPage(),
        'login': (context) => const LoginPage(),
      },
    );
  }
}
