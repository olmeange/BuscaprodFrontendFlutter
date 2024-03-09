import 'package:buscaprodmt/src/pages/login_page.dart';
import 'package:buscaprodmt/src/pages/search_page.dart';
import 'package:buscaprodmt/src/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  String msg = '';

  @override
  void initState() {
    _pageSelector(context);
    super.initState();
  }

  Future<void> _pageSelector(context) async {
    await _loadSavedText().then((token) {
      FetchItem().verifyToken(token).then((value) {
        switch (value.statusCode) {
          case 1000: //success
            {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SearchPage()));
            }
            break;

          case 1011: //invalid token login again
            {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            }
            break;

          case 1013: // no internet connection
            {
              setState(() {
                msg = 'Sin Conexión a Internet';
              });
            }
            break;

          case 1003: // internal server error
            {
              setState(() {
                msg = 'Servidor no disponible';
              });
            }
            break;

          default:
            {
              //statements;
            }
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/buscador.png', height: 120, width: 120),
                  const SizedBox(height: 25.0),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 20.0),
                  Text(msg,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _loadSavedText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('tkn') ?? '';
  }
}
